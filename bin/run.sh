#!/bin/sh
#
# Copyright (c) 2013-2014, Marcus Rohrmoser mobile Software
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions
#    and the following disclaimer.
#
# 2. The software must not be used for military or intelligence or related purposes nor
#    anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# Scrape content from http://www.daserste.de/unterhaltung/krimi/tatort/sendung/ into RDF.
#
cd "$(dirname "$0")"

which xsltproc >/dev/null 2>&1 || { echo "xsltproc is not installed." && exit 1; }
which rapper >/dev/null 2>&1 || { echo "rapper (raptor2-utils) is not installed." && exit 1; }
which roqet >/dev/null 2>&1 || { echo "roqet (rasqal-utils) is not installed." && exit 1; }
which make >/dev/null 2>&1 || { echo "make is not installed." && exit 1; }

www_root="../htdocs"
cache_root="../cache"

# result filename basenames
dst_overview="$www_root/overview"
dst_episode="$www_root/episodes"
dst_kommissar="$www_root/kommissare"
dst_schedule="$www_root/schedule"

# tmp directories
cache_episode="$cache_root/episode"
cache_kommissar="$cache_root/kommissar"
cache_schedule="$cache_root/schedule"


##########################################################
## scrape episode list
##########################################################

mkdir -p "$(dirname "$dst_overview")" 2>/dev/null
echo xsltproc --html --output "$dst_overview".rdf overview.xslt http://www.daserste.de/unterhaltung/krimi/tatort/sendung/index.html
xsltproc --html --output "$dst_overview".rdf overview.xslt http://www.daserste.de/unterhaltung/krimi/tatort/sendung/index.html 2> /dev/null


##########################################################
## scrape (missing) episodes
##########################################################

mkdir -p "$cache_episode" 2>/dev/null
roqet episode.rq --results csv --input sparql --format rdfxml --data "$dst_overview".rdf | tr -d \\r | tail -n +2 | while read line
do
  episode_num=$(echo $line | cut -d , -f1)
  episode_url=$(echo $line | cut -d , -f2)

  episode_file="$cache_episode/$(printf '%04d' $episode_num)"

  if [ -f "$episode_file".ttl ] ; then
    # already present, nothing to do
    continue
  fi

  echo xsltproc --stringparam episode "$(printf '%04d' $episode_num)" --stringparam base_url "$episode_url" --html --output "$episode_file".rdf episode.xslt "$episode_url"
  xsltproc --stringparam episode "$(printf '%04d' $episode_num)" --stringparam base_url "$episode_url" --html --output "$episode_file".rdf episode.xslt "$episode_url" 2> /dev/null
  rapper --input rdfxml --output turtle --input-uri "$episode_url" --output-uri - "$episode_file".rdf > "$episode_file".ttl
  rm "$episode_file".rdf
done
# consolidate into 1 single file
mkdir -p "$(dirname "$dst_episode")" 2>/dev/null
cat "$cache_episode"/*.ttl > "$dst_episode".ttl~ \
&& rapper --input turtle --output rdfxml-abbrev "$dst_episode".ttl~ > "$dst_episode".rdf \
&& rm "$dst_episode".ttl~


##########################################################
## scrape future broadcast schedule
##########################################################


##########################################################
## scrape detetives <-> episode relations (only if needed)
##########################################################

if [ ! -f "$dst_kommissar".rdf ] || [ $(roqet episodes-without-kommissar.rq --results csv --input sparql --format rdfxml --data "$dst_episode".rdf --data "$dst_kommissar".rdf | tr -d \\r | wc -l) -gt 1 ]
then
  mkdir -p "$cache_kommissar" 2>/dev/null
  rm "$cache_kommissar"/*
  roqet kommissar.rq --results csv --input sparql --format rdfxml --data "$dst_overview".rdf | tr -d \\r | tail -n +2 | while read komm_id
  do
    komm_url="http://www.daserste.de/unterhaltung/krimi/tatort/kommissare/$komm_id~_show-overviewBroadcasts.html"
    komm_file="$cache_kommissar/$komm_id"

    echo xsltproc --stringparam base_url "http://www.daserste.de/unterhaltung/krimi/tatort/kommissare/$komm_id.html" --html --output "$komm_file".rdf kommissar.xslt "$komm_url"
    xsltproc --stringparam base_url "http://www.daserste.de/unterhaltung/krimi/tatort/kommissare/$komm_id.html" --html --output "$komm_file".rdf kommissar.xslt "$komm_url" 2> /dev/null

    rapper --quiet --input rdfxml --output turtle --input-uri "$komm_url" --output-uri - "$komm_file".rdf > "$komm_file".ttl
    rm "$komm_file".rdf
  done

  # consolidate into 1 single file
  mkdir -p "$(dirname "$dst_kommissar")" 2>/dev/null
  cat "$cache_kommissar"/*.ttl > "$dst_kommissar".ttl~ \
  && rapper --input turtle --output rdfxml-abbrev "$dst_kommissar".ttl~ > "$dst_kommissar".rdf \
  && rm "$dst_kommissar".ttl~
fi

make
