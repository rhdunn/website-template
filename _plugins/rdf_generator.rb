require 'rdf/rdfxml'
require 'rdf/rdfa'
require 'rdf/turtle'

module Jekyll

  class RdfFile < StaticFile
    def initialize(site, base, dir, name, graph, prefixes)
      super(site, base, dir, name)
      @graph = graph
      @prefixes = prefixes
    end

    def write(dest)
      dest_path = destination(dest)
      RDF::Writer.open(dest_path, :prefixes => @prefixes) do |writer|
        @graph.each_statement do |statement|
          writer << statement
        end
      end
    end
  end

  class RdfGenerator < Generator
    safe true
    priority :low

    EXTENSIONS = {
      'rdfxml' => '.rdf'
    }

    def generate(site)
      @rdf_files = []
      site.pages.each do |page|
        if page.output_ext == '.html' and page.data['rdf']
          prefixes = site.config['namespaces'].clone

          src = page.destination(site.dest)
          base_uri = File.join(site.config['url'], page.basename)

          # Load the RDF data from the RDFa file.
          graph = RDF::Graph.load(src, :prefixes => prefixes, :base_uri => base_uri)

          # Remove WAI-ARIA roles from the RDF graph.
          graph.delete([nil, RDF::XHV.role, RDF::XHV.banner])
          graph.delete([nil, RDF::XHV.role, RDF::XHV.main])
          graph.delete([nil, RDF::XHV.role, RDF::XHV.navigation])

          page.data['rdf'].each do |type|
            filename = page.url.clone.sub('.html', EXTENSIONS[type])
            site.static_files << RdfFile.new(site, site.dest, '/', filename, graph, prefixes)
          end
        end
      end
    end
  end
end
