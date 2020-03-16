
let encode_address(addr: address) : bytes =
  Obj.pack addr

let decode_address(bytes: bytes) : address option =
  Obj.unpack bytes

let encode_number(n: nat) : bytes =
  Obj.pack(n)

let decode_number(bytes: bytes) : nat option =
  Obj.unpack(bytes)

let encode_range(range: range) : bytes =
  Obj.pack((range.start_, range.end_))

let decode_range(bytes: bytes) : range =
  match (Obj.unpack bytes : (nat * nat) option) with
  | Some (start_, end_) -> {start_; end_}
  | None -> failwith "decode error"

let encode_property(property: property) : bytes =
  Obj.pack((property.predicate_address, property.inputs))

let decode_property(bytes: bytes) : property =
  match (Obj.unpack bytes : (address * (nat, bytes) map) option) with
  | Some (predicate_address, inputs) -> {predicate_address; inputs}
  | None -> failwith "decode error"

let pack_property (action: property) (s: bytes) : (ops * bytes) =
  (([]:ops), encode_property(action))
