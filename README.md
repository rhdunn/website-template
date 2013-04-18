The website-template project is a foundation for creating modern websites. It
uses the Jekyll static site generator and supports the following standards:

*  HTML5
*  WAI-ARIA
*  CSS3
*  RDFa

It includes layouts and plugins to support creating content-specific pages
modelled around domain-specific RDF schemas:

*  person descriptions (FOAF metadata)
*  projects and releases (DOAP metadata)
*  schemas/ontologies (RDFS/OWL metadata)

It also includes schema.org metadata for all documents and content to support
search engine structured data/rich snippets such as:

*  web pages
*  blog posts
*  breadcrumb navigation

## Customising Your Site

Customisation is as easy as:

1.  Changing the `title` property in `_config.yml` to match your website name;
2.  Modifying the `_includes/banner.html` file to use your own custom banner;
3.  Modifying the CSS styling in `css/main.css` to match your website design.

## Building and Deploying

To build the website, simply run:

    make

This will create a `_site` directory containing the generated static HTML
pages.

To deploy the website to a locally running Apache webserver, run:

    sudo make install

This will copy the site content to `/var/www`, which you can then display
by navigating to `http://127.0.0.1`.

To deploy the site to the web, upload the content of `_site` to the place
specified by your website hosting service provider.

## License

The following files/directories are licensed under the CC-BY 3.0 license:

    _includes/
    _layouts/
    README.md

The files in the `_plugins` and `css` directories specify their license terms
in the files themselves.

The following files are licensed under the CC0 and Public Domain licenses:

    _config.yml
    Makefile

Any other files are not part of the website-template project and are
governed by the license specified in the downstream project.
