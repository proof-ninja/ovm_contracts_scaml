
type finalize_checkpoint_params = {
  token_type: token_type;
  checkpoint_property: property;
}

let finalize_checkpoint_action
      (finalize_checkpoint_params: finalize_checkpoint_params)
      (s: ovm_storage)
    : context =


  (* // TODO: check adjudication.isDecided(checkpoint) *)
  let checkpoint: checkpoint = {
    subrange = decode_range
                 (match Map.get (Nat 0) finalize_checkpoint_params.checkpoint_property.inputs with
                  | None -> failwith "get_force"
                  | Some r -> r);
    state_update = decode_property
                     (match Map.get (Nat 1) finalize_checkpoint_params.checkpoint_property.inputs with
                      | None -> failwith "get_force"
                      | Some p -> p);
    }
  in

  (* // Store checkpoint to storage *)
  let s = store_checkpoint s finalize_checkpoint_params.token_type checkpoint in

  (* // Emit event *)
  let checkpoint_finalized_event: event_params = [
    Obj.pack(finalize_checkpoint_params.token_type);
    Obj.pack(get_checkpoint_id(checkpoint));
    Obj.pack(checkpoint);
    ] in
  let s = {s with
            events_storage = emit_event s.events_storage "CheckpointFinalized" checkpoint_finalized_event;
          }
  in
  (([] : ops), s)
