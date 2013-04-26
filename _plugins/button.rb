# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module ButtonFilter

    def feed_link(item, item_type)
      data = TYPES[item_type]
      name = data['name']
      mime = data['mime']
      href = item.sub('.html', data['ext'])
      return "<link rel=\"alternate\" type=\"#{mime}\" title=\"#{name}\" href=\"#{href}\"/>"
    end

    def button(item, item_type)
      data = TYPES[item_type]
      name = data['name']
      href = item.sub('.html', data['ext'])
      return "<div class=\"button\"><a href=\"#{href}\">#{name}</a></div>"
    end

  private

    TYPES = {
      'rdfxml' => {'name' => 'RDF' , 'ext' => '.rdf' , 'mime' => 'application/rdf+xml'},
      'rss2'   => {'name' => 'RSS' , 'ext' => '.rss' , 'mime' => 'application/rss+xml'},
    }

  end
end

Liquid::Template.register_filter(Jekyll::ButtonFilter)
