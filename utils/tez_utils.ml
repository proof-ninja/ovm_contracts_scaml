let tez_to_nat(t: tz) : nat =
  t /$ Tz 0.000001

let nat_to_tez(n: nat) : tz =
  Tz 0.000001 *$ n
