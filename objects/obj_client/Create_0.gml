socket = network_create_socket(network_socket_tcp)
global.socket = socket
buffer = buffer_create(16384, buffer_grow, 1)
connect = network_connect(socket, "127.0.0.1", PORT)

if(connect < 0 ){
	show_message("Can not reach the server")
	game_restart()
}

//
entities = ds_map_create()
SendName(global.name)
char = 0
//char = get_integer("Character from 0 to 5", 0)
//SendTankCharacter(char)
playing = false

picked[0] = false
picked[1] = false
picked[2] = false
picked[3] = false

image_speed = .1