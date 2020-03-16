type event_params = bytes list
type event = {
    block_height : nat;
    data : event_params;
}

type topic = string
type topic_sorted_events = (topic, event list) map

type l2_block_number = nat
type events = (l2_block_number, topic_sorted_events) map
