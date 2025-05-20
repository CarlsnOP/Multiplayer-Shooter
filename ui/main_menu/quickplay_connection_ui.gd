extends Control


@onready var status_label = %StatusLabel
@onready var close_button = %CloseButton


func _enter_tree() -> void:
	hide()
	Server.on_lobby_clients_updated.connect(on_lobby_clients_updated)
	Server.on_cant_connect_to_lobby.connect(on_cant_connect_to_lobby)

func activate() -> void:
	if Server.peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		close_button.hide()
		status_label.text = "Connecting to lobby..."
	
	else:
		close_button.show()
		status_label.text = "You are not connected to the server. Try again later."
		
	show()

func on_lobby_clients_updated(connected_clients: int, max_clients: int) -> void:
	status_label.text = "Searching for player %d/%d" %[connected_clients, max_clients]

func on_cant_connect_to_lobby() -> void:
	status_label.text = "Server is full. Try again later."
	close_button.show()

func _on_close_button_pressed():
	hide()
