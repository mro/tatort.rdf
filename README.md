
Scrape [Tatort](http://www.tatort.de/) episode descriptions from the website
and turn it into RDF.

# Usage

Just run

    $ sh bin/index.sh

and find 3 rdf files in `htdocs`.

# License

see [LICENSE.txt](LICENSE.txt)

# Preliminaries

No fancy script language, no database, no json.

## OS X

    $ brew install raptor rasqal

## Debian

    $ sudo apt-get install xsltproc raptor2-utils rasqal-utils

# Example [SPARQL](http://www.w3.org/TR/sparql11-query/#basicpatterns) queries

## Count all movies per kommissar

    $ roqet htdocs/examples/kommissar.rq --results csv

## Count all actor appearances with character name

Expect loooong execution times (several minutes).

    $ roqet htdocs/examples/actor.rq --results csv
