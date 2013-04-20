# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module DataNameFilter

    TYPES = {
      'rdfxml' => 'RDF',
      'rss2'   => 'RSS'
    }

    def data_name(item_type)
      return TYPES[item_type]
    end

  end
end

Liquid::Template.register_filter(Jekyll::DataNameFilter)
