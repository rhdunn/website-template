# Copyright (C) 2013 Reece H. Dunn
#
# License: [CC-BY 3.0](http://creativecommons.org/licenses/by/3.0/)

require 'rdf/rdfxml'
require 'rdf/rdfa'
require 'rdf/turtle'

module Jekyll

  class RdfMetadata
    attr_accessor :prefixes, :graph

    def initialize(site, page, basename)
      @prefixes = site.config['namespaces'].clone
      @src = page.destination(site.dest)
      @base_uri = File.join(site.config['url'], basename)
    end

    def load()
      if @graph == nil
        # Load the RDF data from the RDFa file.
        @graph = RDF::Graph.load(@src, :prefixes => @prefixes, :base_uri => @base_uri)

        # Remove WAI-ARIA roles from the RDF graph.
        @graph.delete([nil, RDF::XHV.role, RDF::XHV.banner])
        @graph.delete([nil, RDF::XHV.role, RDF::XHV.main])
        @graph.delete([nil, RDF::XHV.role, RDF::XHV.navigation])
      end
    end
  end

  class RdfFile < StaticFile
    def initialize(site, base, dir, name, metadata)
      super(site, base, dir, name)
      @metadata = metadata
    end

    def write(dest)
      dest_path = destination(dest)
      @metadata.load()
      RDF::Writer.open(dest_path, :prefixes => @metadata.prefixes, :max_depth => 1) do |writer|
        @metadata.graph.each_statement do |statement|
          writer << statement
        end
      end
    end
  end

  class RdfGenerator < Generator
    safe true

    EXTENSIONS = {
      'rdfxml' => '.rdf'
    }

    def generate(site)
      site.pages.each do |page|
        self.process(page, site)
      end
      site.posts.each do |post|
        self.process(post, site)
      end
    end

    def process(page, site)
      if page.output_ext == '.html' and page.data['rdf']
        basename = page.url.clone.sub('.html', '')
        metadata = RdfMetadata.new(site, page, basename)
        page.data['rdf'].each do |type|
          filename = page.url.clone.sub('.html', EXTENSIONS[type])
          site.static_files << RdfFile.new(site, site.dest, '/', filename, metadata)
        end
      end
    end
  end
end
