# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module RdfSummaryFilter

    PROPERTIES = [
      {'name' => 'added'         , 'type' => 'date' , 'label' => 'Added'  , 'property' => 'dc:created'},
      {'name' => 'subClassOf'    , 'type' => 'uri'  , 'label' => 'Type'   , 'property' => 'rdfs:subClassOf'},
      {'name' => 'subPropertyOf' , 'type' => 'uri'  , 'label' => 'Type'   , 'property' => 'rdfs:subPropertyOf'},
      {'name' => 'domain'        , 'type' => 'uri'  , 'label' => 'Domain' , 'property' => 'rdfs:domain'},
      {'name' => 'range'         , 'type' => 'uri'  , 'label' => 'Range'  , 'property' => 'rdfs:range'},
    ]

    def rdf_summary(item, item_type)
      case item_type
      when 'class'
        type = 'rdfs:Class'
      when 'property'
        type = 'rdf:Property'
      else
        raise Exception.new("Unknown RDF summary type '#{item_type}'.")
      end

      ext_info = false
      PROPERTIES.each do |p|
        if item.has_key?(p['name'])
          ext_info = true
        end
      end

      ret = []
      ret << "<section id=\"#{item['label']}\" about=\"##{item['label']}\" typeof=\"#{type}\">"
      ret << "  <h1 property=\"rdfs:label\">#{item['label']}</h1>"
      if ext_info
        ret << "  <table class=\"info\">"
        ret << "  <col width=\"33%\"/><col width=\"67%\"/>"
        PROPERTIES.each do |p|
          if item.has_key?(p['name'])
            case p['type']
            when 'uri'
              uri = item[p['name']]
              if ! uri.kind_of?(Array)
                uris = [uri]
              else
                uris = uri
              end
              uris.each do |uri|
                value = uri_to_anchor(uri, p['property'])
                ret << "    <tr><th>#{p['label']}</th><td>#{value}</td></tr>"
              end
            when 'date'
              value = item[p['name']]
              ret << "    <tr><th>#{p['label']}</th><td property=\"#{p['property']}\" datatype=\"xsd:date\">#{value}</td></tr>"
            end
          end
        end
        ret << "  </table>"
      end
      ret << "  <p property=\"rdfs:comment\">#{item['comment']}</p>"
      ret << "  <a rel=\"rdfs:isDefinedBy\" href=\"#\"></a>"
      ret << "</section>"
      return ret.join("\n")
    end

  private

    def uri_to_anchor(uri, property)
      config = @context.registers[:site].config
      ns = config['namespaces']

      if uri.include? '#'
        name  = uri.split('#')[1]
        return "<a rel=\"#{property}\" href=\"#{uri}\">#{name}</a>"
      else
        if uri.include? ':' and not uri.include? 'http://'
          nsref, name = uri.split(':')
          expanded_uri = "#{ns[nsref]}#{name}"
          return "<a rel=\"#{property}\" href=\"#{expanded_uri}\">#{name}</a>"
        else
          return "<a rel=\"#{property}\" href=\"#{uri}\">#{uri}</a>"
        end
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfSummaryFilter)
