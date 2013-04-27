# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

module Jekyll

  class SitemapTextFile < StaticFile
    def initialize(site, base, dir, name, urlset)
      super(site, base, dir, name)
      @urlset = urlset
    end

    def write(dest)
      dest_path = destination(dest)
      File.open(dest_path, 'w') do |f|
        @urlset.each do |item|
          f.write("#{item['url']}\n")
        end
      end
    end
  end

  class SitemapGenerator < Generator
    safe true

    def generate(site)
      error_pages = []
      if site.config['error_pages']
        site.config['error_pages'].each do |error, page|
          error_pages << page
        end
      end

      urlset = []
      site.pages.each do |page|
        if !error_pages.include? page.url
          url = "#{site.config['url']}#{page.url.sub('.html', '')}"
          urlset << {'url' => url}
        end
      end
      site.posts.each do |post|
        url = "#{site.config['url']}#{post.url.sub('.html', '')}"
        urlset << {'url' => url}
      end
      site.static_files << SitemapTextFile.new(site, site.dest, '/', 'sitemap.txt', urlset)
    end
  end
end
