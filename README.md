
Scrape [Tatort](http://www.tatort.de/) episode descriptions from the website
and turn it into RDF.

# Usage

Just run

    $ sh bin/run.sh

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

## Movies per kommissar

    $ roqet http://tatort.rdf.mro.name/examples/kommissare.rq --results csv

## Actor appearances with character name

Expect loooong execution time (several minutes).

    $ roqet http://tatort.rdf.mro.name/examples/actor.rq --results csv
