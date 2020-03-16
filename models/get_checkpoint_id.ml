
let get_checkpoint_id (checkpoint: checkpoint) : bytes =
  Crypto.sha256(Obj.pack(checkpoint))
