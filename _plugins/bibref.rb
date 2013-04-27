# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module BibRefFilter

    def bibref(ref)
      if ref.is_a? String
        site = @context.registers[:site]
        refurl = File.join(site.source, '_references', ref)
        ref = YAML.safe_load(File.read(refurl))
      end

      pub = ref['publisher']

      ret = []
      ret << "<li id=\"#{ref['id']}\" rel=\"dct:references\">"
      ret << "  <span typeof=\"foaf:Document\" about=\"#{ref['href']}\">"
      if ref.has_key? 'partof'
        ret << "    <span rel=\"dct:isPartOf\" resource=\"#{ref['partof']}\"/>"
      end
      if ref.has_key? 'authors'
        ref['authors'].each do |author|
          ret << "    <span property=\"dc:creator\">#{author}</span>,"
        end
      end
      if ref.has_key? 'alt-title'
        ret << "    <a href=\"#{ref['href']}\"><span property=\"dc:title\">#{ref['title']}</span></a>"
        ret << "    (<em property=\"dc:title\">#{ref['alt-title']}</em>)."
      else
        ret << "    <a href=\"#{ref['href']}\"><span property=\"dc:title\">#{ref['title']}</span></a>."
      end
      if ref['journal']
        journal = ref['journal']
        ret << "    <span>#{journal['title']}, pages #{journal['pages']}, volume #{journal['volume']}, number #{journal['number']}.</span>"
      end
      if pub
        pubref = "pub_#{ref['id']}"

        ret << "    <span rel=\"dc:publisher\" resource=\"_:#{pubref}\"></span>"
        ret << "    <span typeof=\"foaf:Organisation\" about=\"_:#{pubref}\">"
        ret << "      <a rel=\"foaf:homepage\" href=\"#{pub['href']}\" property=\"foaf:name\">#{pub['name']}</a>"
        if pub.has_key? 'abbr'
          ret << "      (<span property=\"foaf:name\">#{pub['abbr']}</span>)."
        end
        if pub.has_key? 'near'
          ret << "      <span property=\"foaf:based_near\">#{pub['near']}</span>,"
        end
        ret << "    </span>"
      end
      if ref.has_key? 'date'
        year, month, day = ref['date'].split('-')
        if !day
          day = '01'
        end
        ret << "    <span property=\"dc:date\" datatype=\"xsd:date\" content=\"#{year}-#{month}-#{day}\">#{year}</span>."
      end
      ret << "  </span>"
      ret << "</li>"
      return ret.join("\n")
    end

  end
end

Liquid::Template.register_filter(Jekyll::BibRefFilter)
