
let extend_deposited_ranges
  (s: ovm_storage)
  (token_type: address)
  (deposited_amount: nat)
    : ovm_storage =
  let deposit_storage : deposit_storage = match Map.get token_type s.deposit_storages with
      | None -> failwith ""
      | Some ds -> ds
  in

  let is_deposited_range_null: bool =
    not (Map.mem deposit_storage.total_deposited deposit_storage.deposited_ranges)
  in
  if is_deposited_range_null then
    failwith("No range found for the old total_deposited.");
  let old_deposited_range: range = match Map.get deposit_storage.total_deposited deposit_storage.deposited_ranges with
    | None -> failwith ""
    | Some r -> r
  in
  let old_start: nat = old_deposited_range.start_ in
  let old_end: nat = old_deposited_range.end_ in
  let new_deposited_ranges = deposit_storage.deposited_ranges in (*//temporal variable*)

  let new_start =
    if (old_start = Nat 0 && old_end = Nat 0) then
      (* // Creat a new range when the rightmost range has been removed*)
      deposit_storage.total_deposited
    else old_start
  in
  let new_deposited_ranges =
    if (old_start = Nat 0 && old_end = Nat 0) then
      new_deposited_ranges
    else
      (*// Delete the old range and make a new one with the total length*)
      Map.update old_end None new_deposited_ranges
  in

  let new_end: nat = deposit_storage.total_deposited +^ deposited_amount in

  (* // update temporal variable(branch state clone)*)
  let total_deposited = deposit_storage.total_deposited +^ deposited_amount in
  let new_deposited_range: range = {
    start_ = new_start;
    end_ = new_end;
    } in
  let new_deposited_ranges =
    Map.update new_end (Some new_deposited_range) new_deposited_ranges
  in
  let deposit_storage = { deposit_storage with
      total_deposited;
      (* // override branch state *)
      deposited_ranges = new_deposited_ranges
    }
  in
  {s with
    deposit_storages = Map.update token_type (Some deposit_storage) s.deposit_storages;
  }
