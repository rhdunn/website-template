# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module BreadcrumbsFilter

    def breadcrumbs(page)
      crumbs = get_breadcrumb(page, true)
      ret = []
      ret << "<nav role=\"navigation\" class=\"breadcrumbs\">"
      ret << "  <a rel=\"s:breadcrumbs\" href=\"#breadcrumb1\"></a>"
      ret << "  <ol>"
      crumbs.each_with_index do |crumb, index|
        ret << "    <li id=\"breadcrumb#{index}\" about=\"breadcrumb#{index}\" typeof=\"v:Breadcrumb\">"
        if crumb['url']
          ret << "      <a rel=\"v:url\" property=\"v:title\" href=\"#{crumb['url']}\">#{crumb['title']}</a>"
          ret << "      <a rel=\"v:child\" href=\"breadcrumb#{index+1}\"></a>"
        else
          ret << "      <span property=\"v:title\">#{crumb['title']}</span>"
        end
      ret << "    </li>"
      end
      ret << "  </ol>"
      ret << "</nav>"
      return ret.join("\n")
    end

  private

    def get_page(url)
      site = @context.registers[:site]
      site.pages.each do |item|
        if item.url == url
          return item
        end
      end
      site.posts.each do |item|
        if item.url == url
          return item
        end
      end
    end

    def get_breadcrumb(page, is_top)
      if page['parent']
        parent = get_breadcrumb(get_page(page['parent']).to_liquid, false)
      else
        parent = []
      end
      if page['title']
        title = page['title']
      else
        title = 'Home'
      end
      if is_top
        parent << {'title' => title}
      else
        parent << {'title' => title , 'url' => page['url'].sub('index.html', '').sub('.html', '')}
      end
      return parent
    end

  end
end

Liquid::Template.register_filter(Jekyll::BreadcrumbsFilter)
