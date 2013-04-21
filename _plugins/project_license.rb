# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'liquid'

module Jekyll
  module ProjectLicenseFilter

    LICENSES = {
      'artistic' => {
        'href' => 'http://www.opensource.org/licenses/artistic-license.php',
        'rdf'  => 'http://usefulinc.com/doap/licenses/artistic',
        'name' => 'Artistic'
      },
      'asl10' => {
        'href' => 'http://www.apache.org/licenses/LICENSE-1.0',
        'rdf'  => 'http://usefulinc.com/doap/licenses/asl10',
        'name' => 'Apache 1.0'
      },
      'asl11' => {
        'href' => 'http://www.apache.org/licenses/LICENSE-1.1',
        'rdf'  => 'http://usefulinc.com/doap/licenses/asl11',
        'name' => 'Apache 1.1'
      },
      'asl20' => {
        'href' => 'http://www.apache.org/licenses/LICENSE-2.0',
        'rdf'  => 'http://usefulinc.com/doap/licenses/asl20',
        'name' => 'Apache 2.0'
      },
      'bsd' => {
        'href' => 'http://www.opensource.org/licenses/bsd-license.php',
        'rdf'  => 'http://usefulinc.com/doap/licenses/bsd',
        'name' => 'BSD'
      },
      'gpl' => {
        'href' => 'http://www.gnu.org/licenses/gpl',
        'rdf'  => 'http://usefulinc.com/doap/licenses/gpl',
        'name' => 'GPL'
      },
      'lgpl' => {
        'href' => 'http://www.gnu.org/licenses/lgpl',
        'rdf'  => 'http://usefulinc.com/doap/licenses/lgpl',
        'name' => 'LGPL'
      },
      'mit' => {
        'href' => 'http://www.opensource.org/licenses/mit-license.php',
        'rdf'  => 'http://usefulinc.com/doap/licenses/mit',
        'name' => 'MIT'
      },
      'mpl' => {
        'href' => 'http://www.mozilla.org/MPL/',
        'rdf'  => 'http://usefulinc.com/doap/licenses/mpl',
        'name' => 'MPL'
      },
      'w3c' => {
        'href' => 'http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231',
        'rdf'  => 'http://usefulinc.com/doap/licenses/w3c',
        'name' => 'W3C'
      },
    }

    VERSIONED_LICENSES = {
      'gpl' => {
        'href' => 'http://www.gnu.org/licenses/gpl-%s.0',
        'rdf'  => 'http://usefulinc.com/doap/licenses/gpl',
        'name' => 'GPLv%s'
      },
      'lgpl' => {
        'href' => 'http://www.gnu.org/licenses/lgpl-%s.0',
        'rdf'  => 'http://usefulinc.com/doap/licenses/lgpl',
        'name' => 'LGPLv%s'
      },
    }

    def project_license(item_type)
      license = LICENSES[item_type]
      if license # exact match
        name = license['name']
        href = license['href']
        rdf  = license['rdf']
      else # try: <license><version>+? for e.g. gpl3+
        item_type.match /([a-z]+)([0-9]+?)(\+?)/
        license = VERSIONED_LICENSES[$1]
        if !license
          raise Exception("Unsupported license: #{item_type}")
        end

        version = $2
        ext = $3
        name = license['name'] % [version]
        href = license['href'] % [version]
        rdf  = license['rdf']
      end

      ret = []
      ret << "<a rel=\"doap:license\" href=\"#{rdf}\"></a>"
      ret << "<a href=\"#{href}\">#{name}</a>"
      if ext == '+'
        ret << "<span> or later</span>"
      end
      return ret.join("\n")
    end

  end
end

Liquid::Template.register_filter(Jekyll::ProjectLicenseFilter)
