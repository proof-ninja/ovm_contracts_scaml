type action =
  | Deposit of deposit_params
  | FinalizeCheckpoint of finalize_checkpoint_params
  | FinalizeExit of finalize_exit_params
  | Submit of submit_params
  | ClaimProperty of claim_property_params
