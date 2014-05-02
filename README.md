
Scrape [Tatort](http://www.tatort.de/) episode descriptions from the website
and turn it into RDF.

# Usage

Just run

    $ sh index.sh

and find 3 rdf files in `htdocs`.

# License

see [LICENSE.txt](LICENSE.txt)

# Preliminaries

No fancy script language, no database, no json.

## OS X

    $ brew install raptor rasqal

## Debian

    $ sudo apt-get install xsltproc raptor2-utils rasqal-utils
