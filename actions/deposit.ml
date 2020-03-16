type deposit_params = {
  token_type: address;
  amount: nat;
  state_object: property;
}

let deposit_action (deposit_params: deposit_params)(s: ovm_storage) : context =
  (* // TODO: deposit_params.token_type isn't really working here
   * // and only the tez is working here. custom token validation logic will be required later. *)
  if deposit_params.amount <= Nat 0
    then failwith("Insufficient fund");
  (* // TODO: check amount
   * // if tez_to_nat(amount) =/= deposit_params.amount
   * //   then failwith("Invalid amount");
   * // else skip; *)

  let deposit_storage : deposit_storage = match Map.get deposit_params.token_type s.deposit_storages with
      | None -> failwith "get_force"
      | Some ds -> ds
  in

  (* // send money to deposit contract
   * // const deposit_reciever : contract(unit) = get_contract(source);
   * // const op: operation = transaction(unit, amount, deposit_reciever);
   * // const ops: ops = list op end; *)

  let deposited_range : range = {
    start_ = deposit_storage.total_deposited;
    end_ = deposit_storage.total_deposited +^ deposit_params.amount;
    }
  in

  (* // create state_update *)
  let state_update: property = {
      (* // TODO: Injecting StateUpdate predicate address *)
      predicate_address = Address "tz1TGu6TN5GSez2ndXXeDX6LgUDvLzPLqgYV";
      inputs = Map [
                   (Nat 0, encode_address(deposit_params.token_type));
                   (Nat 1, encode_range(deposited_range));
                   (Nat 2, encode_number(s.commitment_storage.current_block));
                   (Nat 3, encode_property(deposit_params.state_object));
                 ];
    }
  in

  let checkpoint: checkpoint = {
    subrange = deposited_range;
    state_update = state_update;
    }
  in

  let s = store_checkpoint s deposit_params.token_type checkpoint in
  let s =
    extend_deposited_ranges s deposit_params.token_type deposit_params.amount
  in

  (* // Event *)
  let checkpoint_finalized_event: event_params = [
      Obj.pack(deposit_params.token_type);
      Obj.pack(get_checkpoint_id(checkpoint));
      Obj.pack(checkpoint);
    ]
  in

  let s = {s with
            events_storage =
              emit_event s.events_storage "CheckpointFinalized" checkpoint_finalized_event;
          }
  in
  (([] : ops), s)
