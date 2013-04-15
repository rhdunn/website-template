module Jekyll

  class HtAccessFile < StaticFile
    def write(dest)
      dest_path = destination(dest)
      File.open(dest_path, 'w') do |f|
        if @site.config['indices']
          f.write('Options +Indexes')
        else
          f.write('Options -Indexes')
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
