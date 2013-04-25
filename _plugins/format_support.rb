# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module FormatSupportFilter

    def format_support(item_type)
      info, data = get_data(item_type)
      ret = []
      ret << "<h1>#{info['title']}</h1>"
      ret << "<div class=\"percentage-bar\">"
      ret << "<div class=\"#{info['status']}\" style=\"width: #{info['percentage-complete']}%;\">#{info['percentage-complete']}%</div>"
      ret << "</div>"
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
      'no' => {'status' => 'failure' , 'text' => 'No'},
      'na' => {'status' => 'na'      , 'text' => 'N/A'},
    }

    class Formatter
      attr_accessor :title

      ESCAPES = {
        '\\['  => '[',
        '\\]'  => ']',
        '\\*'  => '*',
        '\\_'  => '_',
        '\\\\' => '\\',
      }

      def initialize(title)
        @title = title
      end

      def parse(value)
        if value
          ESCAPES.each do |match, replacement|
            value = value.sub(match, replacement)
          end
        end
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
          return {'status' => 'inprogress' , 'text' => value.sub('~', '')}
        end
        return {'status' => 'success' , 'text' => value}
      end

      def html(value)
        return "<td class=\"#{value['status']}\">#{value['text']}</td>"
      end
    end

    PROPERTIES = {
      'category' => StringFormatter.new(nil),
      'comments' => StringFormatter.new('Comments'),
      'implemented' => StatusFormatter.new('Implemented'),
      'model' => StatusFormatter.new('Model'),
      'parsing' => StatusFormatter.new('Parsing'),
      'section' => StringFormatter.new('Section'),
      'tests' => StatusFormatter.new('Tests'),
      'title' => StringFormatter.new('Title'),
      'url' => UrlFormatter.new(nil),
    }

    FORMATS = {
      'css-spec' => ['section', 'category', 'title', 'url', 'model', 'parsing', 'tests', 'comments'],
      'spec'     => ['section', 'title', 'url', 'implemented', 'tests', 'comments'],
    }

    def get_data(item)
      info = {'items' => 0 , 'success' => 0 , 'inprogress' => 0}
      STATUS.each do |key, value|
        info.store(value['status'], 0)
      end

      spec = FORMATS[item['type']]
      data = []
      item['content'].split("\n").each do |line|
        row = {}
        spec.zip(line.split(",")).each do |key, value|
          property = PROPERTIES[key]
          propval = property.parse(value)
          if property.is_a? StatusFormatter
            info[propval['status']] += 1
            info['items'] += 1
          end
          row.store(property, propval)
        end
        data << row
      end

      if item['type'] == 'css-spec'
        info['title'] = "CSS #{item['title']} Level #{item['level']}"
      else
        if item['type'] == 'spec'
          parent = get_page(item['parent'], item['url']).data
          info['title'] = "#{parent['title']} #{item['title']}"
        else
          info['title'] = item['title']
        end
      end
      info['percentage-complete'] = ((info['success'].to_f / (info['items'] - info['na'])) * 100).to_i
      if info['percentage-complete'] < 25
        info['status'] = 'failure'
      else
        if info['percentage-complete'] > 75
          info['status'] = 'success'
        else
          info['status'] = 'inprogress'
        end
      end
      return info, data
    end

    def get_page(parent, url)
      site = @context.registers[:site]
      site.pages.each do |item|
        if item.url == parent
          return item
        end
      end
      site.posts.each do |item|
        if item.url == parent
          return item
        end
      end
      raise Exception.new("#{url}: Unable to locate parent \"#{parent}\"")
    end

  end
end

Liquid::Template.register_filter(Jekyll::FormatSupportFilter)
