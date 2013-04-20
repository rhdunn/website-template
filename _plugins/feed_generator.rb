# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'cgi'

module Jekyll

  class FeedItem
    attr_accessor :title , :link , :pubdate , :description

    def initialize(post, converter)
      if post.data['project']
        project = post.data['project']
        @title = "#{project} #{post.data['title']} released"
      else
        @title = post.data['title']
      end

      @link = post.url.clone.sub('.html', '')
      @pubdate = post.date
      @description = CGI.escapeHTML(converter.convert(post.content))
    end
  end

  class Feed
    attr_accessor :title , :description , :language , :pubdate , :copyright , :items

    def initialize(site, page)
      if page.data['layout'] == 'project'
        categories = ['release']
        project = page.data['title']
      else
        categories = page.data['categories']
      end
      converter = Jekyll::Converters::Markdown.new(site.config)

      if page.data['title']
        @title = page.data['title']
      else
        @title = site.config['title']
      end

      @description = page.data['description']
      @language = site.config['language']
      @pubdate = site.time
      @copyright = "Copyright (C) #{site.config['start_year']}-#{site.time.year} #{site.config['author']['name']}"
      @items = []
      site.posts.each do |post|
        if !(categories & post.categories).empty? and project == post.data['project']
          @items << FeedItem.new(post, converter)
        end
      end
    end
  end

  class Rss2File < StaticFile
    def initialize(site, base, dir, name, feed)
      super(site, base, dir, name)
      @baseurl = site.config['url']
      @feed = feed
      @timefmt = "%a, %d %b %Y %H:%M:%S %z"
    end

    def write(dest)
      dest_path = destination(dest)
      File.open(dest_path, 'w') do |f|
        ret = []
        ret << "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        ret << "<rss version=\"2.0\">"
        ret << "	<channel>"
        ret << "		<title>#{@feed.title}</title>"
        ret << "		<link>#{@baseurl}#{@name}</link>" # Q: What should this point to???
        ret << "		<description>#{@feed.description}</description>"
        ret << "		<language>#{@feed.language}</language>"
        ret << "		<pubDate>#{@feed.pubdate.strftime(@timefmt)}</pubDate>"
        ret << "		<lastBuildDate>#{@feed.pubdate.strftime(@timefmt)}</lastBuildDate>"
        ret << "		<copyright>#{@feed.copyright}</copyright>"
        @feed.items.each do |item|
          ret << "		<item>"
          ret << "			<title>#{item.title}</title>"
          ret << "			<link>#{@baseurl}#{item.link}</link>"
          ret << "			<pubDate>#{item.pubdate.strftime(@timefmt)}</pubDate>"
          ret << "			<guid>#{@baseurl}#{item.link}</guid>"
          ret << "			<description>#{item.description}</description>"
          ret << "		</item>"
        end
        ret << "	</channel>"
        ret << "</rss>"
        f.write(ret.join("\n"))
      end
    end
  end

  class FeedGenerator < Generator
    safe true

    EXTENSIONS = {
      'rss2' => '.rss',
    }

    def generate(site)
      site.pages.each do |page|
        self.process(page, site)
      end
    end

    def process(page, site)
      if page.output_ext == '.html' and page.data['feeds']
        feed = Feed.new(site, page)
        page.data['feeds'].each do |type|
          case type
          when 'rss2'
            filename = page.url.clone.sub('.html', EXTENSIONS[type])
            site.static_files << Rss2File.new(site, site.dest, '/', filename, feed)
          end
        end
      end
    end
  end
end
