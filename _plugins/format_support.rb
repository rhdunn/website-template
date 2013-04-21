# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module FormatSupportFilter

    def format_support(item_type)
      data = get_data(item_type)
      ret = []
      ret << "<table class=\"data\">"
      ret << "<tr>"
      data[0].each do |property, item|
        if property.title
          ret << "<th>#{property.title}</th>"
        end
      end
      ret << "</tr>"
      data.each do |row|
        ret << "<tr>"
        row.each do |property, item|
          if property.title
            ret << property.html(item)
          end
        end
        ret << "</tr>"
      end
      ret << "</table>"
      return ret.join("\n")
    end

  private

    STATUS = {
      'no' => {'class' => 'failure' , 'text' => 'No'},
      'na' => {'class' => 'na'      , 'text' => 'N/A'},
    }

    class Formatter
      attr_accessor :title

      def initialize(title)
        @title = title
      end

      def parse(value)
        return value
      end

      def html(value)
        return "<td>#{value}</td>"
      end
    end

    class StringFormatter < Formatter
    end

    class UrlFormatter < Formatter
    end

    class StatusFormatter < Formatter
      def parse(value)
        s = STATUS[value]
        if s
          return s
        end
        if value.match /^~/
          return {'class' => 'inprogress' , 'text' => value.sub('~', '')}
        end
        return {'class' => 'success' , 'text' => value}
      end

      def html(value)
        return "<td class=\"#{value['class']}\">#{value['text']}</td>"
      end
    end

    PROPERTIES = {
      'category' => StringFormatter.new(nil),
      'comments' => StringFormatter.new('Comments'),
      'model' => StatusFormatter.new('Model'),
      'parsing' => StatusFormatter.new('Parsing'),
      'section' => StringFormatter.new('Section'),
      'tests' => StatusFormatter.new('Tests'),
      'title' => StringFormatter.new('Title'),
      'url' => UrlFormatter.new(nil),
    }

    FORMATS = {
      'css-spec' => ['section', 'category', 'title', 'url', 'model', 'parsing', 'tests', 'comments'],
    }

    def get_data(item)
      spec = FORMATS[item['type']]
      data = []
      item['content'].split("\n").each do |line|
        row = {}
        spec.zip(line.split(",")).each do |key, value|
          property = PROPERTIES[key]
          row.store(property, property.parse(value))
        end
        data << row
      end
      return data
    end

  end
end

Liquid::Template.register_filter(Jekyll::FormatSupportFilter)
