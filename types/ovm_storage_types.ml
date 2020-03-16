type deposit_storage = {
    total_deposited : nat;
    deposited_ranges: (nat, range) map;
    checkpoints: checkpoints;
}

type events_storage = {
  ts: timestamp;
  events: topic_sorted_events;
}

type commitment_storage = {
  current_block: nat;
  commitments: commitments;
  operator_address: address;
}

type adjudication_storage = {
  instantiated_games: (bytes, challenge_game) map;
}

type ovm_storage = {
  deposit_storages: (token_type, deposit_storage) map;
  commitment_storage: commitment_storage;
  adjudication_storage: adjudication_storage;
  events_storage: events_storage;
}
