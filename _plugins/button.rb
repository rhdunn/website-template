# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module ButtonFilter

    TYPES = {
      'rdfxml' => { 'ext' => '.rdf' , 'name' => 'RDF' },
      'rss2'   => { 'ext' => '.rss' , 'name' => 'RSS' }
    }

    def button(item, item_type)
      type = TYPES[item_type]
      return "<div class=\"button\"><a href=\"#{item.sub('.html', type['ext'])}\">#{type['name']}</a></div>"
    end

  end
end

Liquid::Template.register_filter(Jekyll::ButtonFilter)
