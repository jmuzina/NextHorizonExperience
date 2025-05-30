extends Node

# Autoload named Lobby

@export var NetPlayerSetupControl: Control
@export var NetworkFailedConnect: Control
@export var LocalPlayerStart: Node3D

var LocalPlayer: CharacterBody3D

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
 
const PORT = 12205
const DEFAULT_SERVER_IP = "wss://nhx.frostbreak.org" # OVH
const MAX_CONNECTIONS = 64
var IS_SERVER = false

var frames_til_pos_update = 6
var current_frames = 0 

# This will contain player info for every player,
# with the keys being each player's unique IDs.
# format: {"id"(String): (int) "name"(String): "" (String), "color"(String): (Color), "Pos"(String): (Transform)}}
var players: Array

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var local_player_info

var players_loaded = 0

var connection_begun = false

var multiplayerPeer = WebSocketMultiplayerPeer

func _ready():
	if OS.has_feature("dedserv"): # IS DEDICATED SERVER
		create_game()
		IS_SERVER= true
		print("server listening at " + str(PORT))
	else: # IS CLIENT
		IS_SERVER = false
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	NetPlayerSetupControl.on_player_start.connect(join_game)

func join_game(player_info, address = ""):
	#create local player
	LocalPlayer = LocalPlayerStart.create_player()
	LocalPlayer.player_name = player_info.name
	local_player_info = player_info
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	print("client on %s:%s" % [address, PORT])
	var tt = load("res://cert.crt")
	var error = peer.create_client(address + ":" + str(PORT), TLSOptions.client_unsafe(tt))
	await get_tree().create_timer(2).timeout
	multiplayer.multiplayer_peer = peer
	get_tree().set_multiplayer(multiplayer)
	
	if error:
		return error
		NetworkFailedConnect.visible = true
		return
	connection_begun = true

func create_game():
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	var b = load("res://key.key")
	var c = load("res://cert.crt")
	var error = peer.create_server(PORT, "*", TLSOptions.server(b, c))
	if error or !multiplayer.has_multiplayer_peer():
		return error
	multiplayer.multiplayer_peer = peer 

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()

func _physics_process(delta: float) -> void:
	if  multiplayer.multiplayer_peer == null or connection_begun == false or multiplayer.multiplayer_peer.get_connection_status() != multiplayer.multiplayer_peer.CONNECTION_CONNECTED:
		return
	if !IS_SERVER:
		current_frames += 1
		if (frames_til_pos_update == current_frames):
			rpc("update_player_position", LocalPlayer.transform)
			current_frames = 0

@rpc("any_peer", "call_remote",)
func update_player_position(new_transform: Transform3D):
	var id = multiplayer.get_remote_sender_id()
	for player in players:
		if player.id == id:
			player.transform = new_transform
			player.node.transform = new_transform
	
	

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print("CONNECTION")
	if IS_SERVER:
		print("connected to client ", str(id))
		rpc_id(id, "send_new_player_info", id)
		rpc_id(id, "add_previous_players", players)

@rpc()
func send_new_player_info(id):
	print("im in here ")
	print(id)
	local_player_info.id = id
	print("player info: %s" % local_player_info)
	rpc("_register_player", local_player_info)
	
	

@rpc("any_peer")
func add_previous_players(remote_players):
	players = remote_players
	for player in players:
		var i = create_local_net_player(player)
		player.node = i
		

func create_local_net_player(info) -> Node3D:
	var net_player = preload("res://script/network/NetworkPlayer.tscn").instantiate()

	if (info.id == multiplayer.get_unique_id()):
		net_player.hide_local()
	net_player.set_color(info.color)
	net_player.set_overhead_name(info.name)
	add_child(net_player)
	net_player.transform = info.transform
	
	net_player.set_multiplayer_authority(info.id)
	return net_player

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if multiplayer.multiplayer_peer != null && multiplayer.multiplayer_peer.get_connection_status() == multiplayer.multiplayer_peer.CONNECTION_CONNECTED:
			multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_unique_id())
			multiplayer.multiplayer_peer = null
		get_tree().quit() # default behavior


@rpc("any_peer")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	var i = create_local_net_player(new_player_info)
	new_player_info.node = i
	players.append(new_player_info) 
	player_connected.emit(new_player_id, new_player_info)
	if IS_SERVER:
		print(players)


func _on_player_disconnected(id):
	for i in range(0, players.size()):
		if players[i].id == id:
			players[i].node.queue_free()
			players.remove_at(i)
	print(players)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	#players[peer_id] = player_info
	#_do_playername_checks(peer_id)
	#player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	NetworkFailedConnect.visible = true
	# Put a note on player UI. "Portal inaccessible, simulating from last image"


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
