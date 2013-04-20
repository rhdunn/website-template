# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module DataUrlFilter

    TYPES = {
      'rdfxml' => '.rdf',
      'rss2'   => '.rss'
    }

    def data_url(item, item_type)
      return item.sub('.html', TYPES[item_type])
    end

  end
end

Liquid::Template.register_filter(Jekyll::DataUrlFilter)
