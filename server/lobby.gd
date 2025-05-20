extends Node3D
class_name Lobby


func _ready() -> void:
	c_lock_client.rpc_id(1)
	
@rpc("any_peer", "call_remote", "reliable")
func c_lock_client() -> void:
	pass

@rpc("authority", "call_remote", "reliable")
func s_start_loading_map() -> void:
	var map = load("res://maps/map_farm.tscn").instantiate()
	map.name = "Map"
	map.ready.connect(map_ready)
	add_child(map, true)
	get_tree().call_group("LocalGameSceneManager", "clear_scenes")

func map_ready() -> void:
	c_map_ready.rpc_id(1)
@rpc("any_peer", "call_remote", "reliable")
func c_map_ready() -> void:
	pass

@rpc("authority", "call_remote", "reliable")
func s_start_match() -> void:
	get_tree().call_group("PlayerLocal", "set_processes", true)
