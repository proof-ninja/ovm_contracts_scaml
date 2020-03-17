
type finalize_exit_params = {
  token_type: token_type;
  exit_property: property;
  deposited_range_id: nat;
}

let remove_deposited_range
      (deposit_storage: deposit_storage)
      (range_to_remove: range)
      (deposited_range_id: nat)
    : deposit_storage =

  let encompasing_range: range = match Map.get deposited_range_id deposit_storage.deposited_ranges with
      | None -> failwith "get_force"
      | Some r -> r
  in
  if encompasing_range.start_ <= range_to_remove.start_ && range_to_remove.end_ <= encompasing_range.end_ then ()
  else failwith("range must be of a depostied range.");

  let new_deposited_ranges = deposit_storage.deposited_ranges in
  (* // check start *)
  let deposit_storage =
    {deposit_storage with
      deposited_ranges =
        if range_to_remove.start_ <> encompasing_range.start_ then
          let range = {
              start_ = encompasing_range.start_;
              end_ = range_to_remove.start_;
            }
          in
          Map.update range_to_remove.start_ (Some range) deposit_storage.deposited_ranges
        else deposit_storage.deposited_ranges;
    }
  in
  (* // check end *)
  let deposit_storage =
    {deposit_storage with
      deposited_ranges =
        if range_to_remove.end_ = encompasing_range.end_ then
          Map.update encompasing_range.end_ None deposit_storage.deposited_ranges
        else
          let encompasing_range = {encompasing_range with
                                    start_ = range_to_remove.end_ }
          in
          Map.update encompasing_range.end_ (Some encompasing_range)
            deposit_storage.deposited_ranges;
    }
  in
  deposit_storage

let get_exit_id(exit: exit) : bytes =
  Crypto.sha256(Obj.pack(exit))

let transfer(account: address)(amount_: tz) : operation =

  let contract : unit contract =
    match Contract.contract(account) with
    | None -> failwith "get_contract"
    | Some c -> c
  in
  let op: operation = Operation.transfer_tokens () amount_ contract in
  op

let get_force ((n : nat), (inputs : (nat, bytes) map)) =
  match Map.get n inputs with
  | None -> failwith "get_force"
  | Some i -> i

let finalize_exit_action
      (finalize_exit_params: finalize_exit_params)
      (s: ovm_storage)
    : context =

  (* // TODO: check adjudication.isDecided(finalize_exit_params.exit_property)*)
  let new_exit: exit = {
    subrange = decode_range(get_force(Nat 0, finalize_exit_params.exit_property.inputs));
    state_update = decode_property(get_force(Nat 1, finalize_exit_params.exit_property.inputs));
    }
  in
  (* // remove deposited range *)
  let s =
    let range = remove_deposited_range
                  (match Map.get finalize_exit_params.token_type s.deposit_storages with
                     | None -> failwith "get_force"
                     | Some s -> s)
                  new_exit.subrange
                  finalize_exit_params.deposited_range_id
    in
    {s with
      deposit_storages = Map.update finalize_exit_params.token_type
                           (Some range)
                           s.deposit_storages;}
  in
  (* // transfer*)
  let state_object: property = decode_property(match Map.get (Nat 3) new_exit.state_update.inputs with
  | None -> failwith "get_force"
  | Some i -> i)
  in
  let owner_opt: address option = decode_address(match Map.get (Nat 0) state_object.inputs with
                                                  | None -> failwith "get_force"
                                                  | Some i -> i)
  in
  let withdraw_amount: int =
    new_exit.subrange.end_ -^ new_exit.subrange.start_
  in
  let operations: operation list = [] in
  let operations =
    match owner_opt with
    | Some(owner) -> transfer owner (nat_to_tez(abs withdraw_amount)) :: operations
    | None -> failwith("decode error")
  in

  (* // Emit event*)
  let exit_finalized_event: event_params = [
    Obj.pack(finalize_exit_params.token_type);
    Obj.pack(get_exit_id(new_exit));
    ] in
  let s = {s with
            events_storage = emit_event s.events_storage "ExitFinalized" exit_finalized_event;
            }
  in
  ((operations : ops), s)
