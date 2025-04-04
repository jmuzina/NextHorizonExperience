extends Node

# Autoload named Lobby

@export var NetPlayerSetupControl: Control

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 12205
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 128
var IS_SERVER = true

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.

var players_loaded = 0

func _ready():
	if OS.has_feature("dedserv"): # IS DEDICATED SERVER
		create_game()
		IS_SERVER= true
	else: # IS CLIENT
		var IS_SERVER = false
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	NetPlayerSetupControl.on_player_start.connect()

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()

@rpc("any_peer", "call_remote", "unreliable")
func update_player_position(new_transform: Transform3D):
	var id = multiplayer.get_remote_sender_id()
	
	

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	rpc("_register_player")


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	_do_playername_checks(peer_id)
	player_connected.emit(peer_id, player_info)

#func _do_playername_checks(peer_id: int):
	#if player_info.name.is_empty():
		#player_info.name = "Player" + str(peer_id)
	#elif player_info.name.containsn("Reykreyth") or player_info.name.containsn("Rey"):
		#player_info.color = Color('3A0A4E')
	#if player_info.name.containsn("Diamond"):
		#player_info.color = Color('ff007c')
	#

func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	# Put a note on player UI. "Portal inaccessible, simulating from last image"


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
