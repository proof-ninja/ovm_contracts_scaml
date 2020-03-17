let emit_event s topic params =
  let event = {
      block_height = Nat 0;
      data = params;
    }
  in
  (* TODO: use level *)
  let level: timestamp = Global.get_now () in
  if (s.ts < level) then begin
    let topic_sorted_events = Map.update topic (Some [event]) Map.empty in
    {
      events = topic_sorted_events;
      ts = level;
    }
  end else begin
    let topic_event_opt = Map.get topic s.events in
    {s with
      events =
        Map.update topic (match topic_event_opt with
                          | None -> Some [event]
                          | Some(events) -> Some (event :: events))
          s.events
    }
  end
