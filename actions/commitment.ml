type submit_params = {
  block_number: nat;
  root: bytes;
}

let submit_action (submit_params: submit_params)(s: ovm_storage) : context =

  let commitment_storage: commitment_storage = s.commitment_storage in
  let l2_block_number: nat = submit_params.block_number in
  let root: bytes = submit_params.root in

  (* // Validation *)
  if Global.get_source () <> commitment_storage.operator_address then
    failwith("source should be registered operator address");
  if l2_block_number <> commitment_storage.current_block +^ Nat 1 then
    failwith("block_number should be next block");

  (* // State Update *)
  let commitment_storage =
    {commitment_storage with
      commitments =
        Map.update l2_block_number (Some root) commitment_storage.commitments;
      current_block = l2_block_number;
    }
  in

  (* // Event
   * // encode event params
   * // please see https://github.com/cryptoeconomicslab/wakkanay/blob/f90e3fcfa0227c09d270f732ea9a03387d69456f/packages/contract/src/events/types/BlockSubmitted.ts#L9 *)
  let submitted_event: event_params = [
      Obj.pack(l2_block_number);
      Obj.pack(root)
    ]
  in

  let s = {s with
            events_storage =
              emit_event s.events_storage "BlockSubmitted" submitted_event;
            commitment_storage = commitment_storage
          }
  in
  (([] : operation list), s)
