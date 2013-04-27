# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

module Jekyll

  class HtAccessFile < StaticFile
    def write(dest)
      dest_path = destination(dest)
      File.open(dest_path, 'w') do |f|
        f.write("AddType application/rdf+xml .rdf\n")
        f.write("\n")
        if @site.config['error_pages']
          @site.config['error_pages'].each do |error, page|
            f.write("ErrorDocument #{error} #{page}\n")
          end
          f.write("\n")
        end
        f.write("RewriteEngine On\n")
        f.write("\n")
        f.write("# Redirect X.html to X\n")
        f.write("RewriteCond %{THE_REQUEST} ^(GET|HEAD)\\ /.+\\.html\\ HTTP\n")
        f.write("RewriteRule ^(.+)\\.html$ http://%{HTTP_HOST}/$1 [R=301,L]\n")
        f.write("\n")
        f.write("# If RDF/XML is requested, try X.rdf\n")
        f.write("RewriteCond %{HTTP_ACCEPT} application/rdf\\+xml\n")
        f.write("RewriteCond %{REQUEST_FILENAME}.rdf -f\n")
        f.write("RewriteRule ^.+$ %{REQUEST_FILENAME}.rdf [L]\n")
        f.write("\n")
        f.write("# If X does not exist, try X.html\n")
        f.write("RewriteCond %{REQUEST_FILENAME} !-f\n")
        f.write("RewriteCond %{REQUEST_FILENAME}.html -f\n")
        f.write("RewriteRule ^.+$ %{REQUEST_FILENAME}.html [L]\n")
      end
    end
  end

  class HtAccessGenerator < Generator
    safe true

    def generate(site)
      site.static_files << HtAccessFile.new(site, site.dest, '/', '.htaccess')
    end
  end
end
