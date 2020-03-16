
let store_checkpoint
      (s: ovm_storage)
      (token_type: address)
      (checkpoint: checkpoint)
    : ovm_storage =
  let deposit_storage : deposit_storage =
    match Map.get token_type s.deposit_storages with
    | None -> failwith ""
    | Some ds -> ds
  in
  let checkpoint_id: bytes = get_checkpoint_id(checkpoint) in

  let deposit_storage = { deposit_storage with
      checkpoints = Map.update checkpoint_id (Some checkpoint) deposit_storage.checkpoints;
    }
  in
  {s with
    deposit_storages = Map.update token_type (Some deposit_storage) s.deposit_storages;
  }
