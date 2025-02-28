#!/usr/bin/env bash

cd site && python -m http.server &

while sleep 1.1; do
  find assets posts lib | entr -d mix site.build;
  done
