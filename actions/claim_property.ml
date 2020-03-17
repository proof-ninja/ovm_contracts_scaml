type claim_property_params = {
  claim: property;
}

let get_property_id (property: property) : bytes =
  Crypto.sha256(Obj.pack(property))

let store_game
  (adjudication_storage : adjudication_storage)
  (id: bytes)
  (property: property)
  : adjudication_storage =
  {
   instantiated_games =
     Map.update id (Some {
         property = property;
         challenges = [];
         decision = Nat 0;
         created_block = Global.get_now ();
       })
       adjudication_storage.instantiated_games
  }

let claim_property_action
    (claim_property_params: claim_property_params)
    (s: ovm_storage)
 : context =

  let game_id: bytes = get_property_id(claim_property_params.claim) in
  let s = {s with
           adjudication_storage = store_game s.adjudication_storage game_id claim_property_params.claim;}
  in
  (* // NewPropertyClaimed *)
  let new_property_claimed_event: event_params = [
    Obj.pack(game_id);
    Obj.pack(claim_property_params.claim);
    Obj.pack(Global.get_now ());
  ] in
  let s = {s with
           events_storage = emit_event s.events_storage "NewPropertyClaimed" new_property_claimed_event;}
  in
  ([], s)
