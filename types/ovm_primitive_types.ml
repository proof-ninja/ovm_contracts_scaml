type token_type = address
type range = {start_ : nat; end_ : nat}
type property = {predicate_address : address; inputs : (nat, bytes) map}

type state_update = {
    property: property;
    range: range;
    plasma_block_number: nat;
    deposit_address: address;
}

type checkpoint = {
    subrange : range;
    state_update : property;
}
type exit = checkpoint
type challenge_game = {
    property: property;
    challenges: bytes list;
    decision : nat;
    created_block : timestamp;
}
