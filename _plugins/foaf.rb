# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module FoafFilter

    def foaf(item, properties)
      if item['foaf']
        return "<a rel=\"#{properties}\" href=\"#{item['foaf']}\">#{item['name']}</a>"
      end

      about = item['name'].gsub(/[\ \-\.]/, '_')
      if item['type'] == 'Organization'
        type = 'foaf:Organization s:Organization'
      else
        type = 'foaf:Person s:Person'
      end

      ret = []
      ret << "<a rel=\"#{properties}\" href=\"##{about}\"></a>"
      ret << "<span id=\"#{about}\" about=\"##{about}\" typeof=\"#{type}\">"
      if item['homepage']
        ret << "<a rel=\"foaf:homepage s:url\" href=\"#{item['homepage']}\" property=\"foaf:name s:name\">#{item['name']}</a>"
      else
        if item['account']
          ret << "<a rel=\"foaf:account\" href=\"#{item['account']}\" property=\"foaf:name s:name\">#{item['name']}</a>"
        else
          ret << "<span property=\"foaf:name s:name\">#{item['name']}</span>"
        end
      end
      ret << "</span>"
      return ret.join("\n")
    end

  end
end

Liquid::Template.register_filter(Jekyll::FoafFilter)
