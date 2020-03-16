#!/bin/sh
set -eux
FILE=ovm.ml
DEPENDENCIES="lib.ml \
              entry.ml
"
cat $DEPENDENCIES > $FILE
scamlc $FILE
