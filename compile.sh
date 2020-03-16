#!/bin/sh
set -eux
FILE=ovm.ml
DEPENDENCIES="lib.ml \
              types/ovm_primitive_types.ml \
              types/ovm_iterable_types.ml \
              types/ovm_event_types.ml \
              types/ovm_storage_types.ml \
              entry.ml
"
cat $DEPENDENCIES > $FILE
scamlc $FILE
