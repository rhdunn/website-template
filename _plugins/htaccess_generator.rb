module Jekyll

  class HtAccessFile < StaticFile
    def write(dest)
      metadata = []
      @site.pages.each do |p|
        if p.output_ext == '.html' and p.data['rdf']
          rdf = p.url.clone.sub('.html', '.rdf')
          url = p.basename.clone.sub('$\/', '')
          metadata << { 'canonical' => url , 'html' => p.url , 'rdf' => rdf }
        end
      end

      dest_path = destination(dest)
      File.open(dest_path, 'w') do |f|
        if @site.config['indices']
          f.write("# Enable directory listing\n")
          f.write("Options +Indexes\n")
        else
          f.write("# Disable directory listing\n")
          f.write("Options -Indexes\n")
        end
        f.write("\n")
        f.write("# Disable multiviews\n")
        f.write("Options -MultiViews\n")
        f.write("\n")
        f.write("# Custom mimetypes\n")
        f.write("AddType application/rdf+xml .rdf\n")
        f.write("\n")
        f.write("# Enable mod_rewrite\n")
        f.write("RewriteEngine On\n")
        f.write("\n")
        if !metadata.empty?
          f.write("# Rewrite rule to serve HTML content from the vocabulary URI if requested\n")
          f.write("RewriteCond %{HTTP_ACCEPT} !application/rdf\+xml.*(text/html|application/xhtml\+xml)\n")
          f.write("RewriteCond %{HTTP_ACCEPT} text/html [OR]\n")
          f.write("RewriteCond %{HTTP_ACCEPT} application/xhtml\+xml [OR]\n")
          f.write("RewriteCond %{HTTP_USER_AGENT} ^Mozilla/.*\n")
          metadata.each do |item|
            f.write("RewriteRule ^#{item['canonical']}$ #{item['html']} [R=303]\n")
          end
          f.write("\n")
          f.write("# Rewrite rule to serve RDF/XML content from the vocabulary URI if requested\n")
          f.write("RewriteCond %{HTTP_ACCEPT} application/rdf\+xml\n")
          metadata.each do |item|
            f.write("RewriteRule ^#{item['canonical']}$ #{item['rdf']} [R=303]\n")
          end
          f.write("\n")
          f.write("# Rewrite rule to serve the RDF/XML content from the vocabulary URI by default\n")
          metadata.each do |item|
            f.write("RewriteRule ^#{item['canonical']}$ #{item['rdf']} [R=303]\n")
          end
        end
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
