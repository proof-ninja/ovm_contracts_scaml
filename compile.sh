#!/bin/sh
set -eux
FILE=ovm.ml
DEPENDENCIES="lib.ml \
              types/ovm_primitive_types.ml \
              types/ovm_iterable_types.ml \
              types/ovm_event_types.ml \
              types/ovm_storage_types.ml \
              types/ovm_global_types.ml \
              models/emit_event.ml \
              models/extend_deposited_ranges.ml \
              models/get_checkpoint_id.ml \
              models/store_checkpoint.ml \
              utils/tez_utils.ml \
              utils/primitive_coder.ml \
              actions/commitment.ml \
              actions/deposit.ml \
              actions/finalize_checkpoint.ml \
              entry.ml
"
cat $DEPENDENCIES > $FILE
scamlc $FILE
