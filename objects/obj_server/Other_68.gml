var event_id = async_load[? "id"]


if server == event_id{
	var type = async_load[? "type"]
	var sock = async_load[? "socket"]
	
	//connect
	if(type == network_type_connect){
		//create a player, add the socket to teh list
		ds_list_add(sockets, sock)
		
		//create a player
		var playerH = instance_create_layer(64, 64+32, "Instances", obj_Player)
		//var playerH = instance_create_layer(64, 64+32*sock, "Instances", obj_Player)
		playerH.my_id = sock
		ds_map_add(clients, sock, playerH)
		
		ready[sock] = false
		//send data about other players
		for(var i = 0; i < instance_number(obj_Player); i++){
			var player = instance_find(obj_Player, i)
			SendRemoteEntity(sock, CMD_X, player.id, player.x)
			SendRemoteEntity(sock, CMD_Y, player.id, player.y)
			SendRemoteEntity(sock, CMD_NAME, player.id, player.name)
			SendRemoteEntity(sock, CMD_SPRITE, player.id, player.sprite_index)
			SendRemoteEntity(sock, CMD_MYID, player.id, player.my_id)
		}
		
		for(var c = 0; c <= TANK_CHARACTER_YELLOW; c++){
			var a = false
			if (ds_list_find_value(available_tanks, ds_list_find_index(available_tanks, c)) != undefined){
				a = true
			}
			
			if(game_is_started == 0){
				game_is_started = 1
			}
			SendPicked(sock, c, a)
		}
	}
	
	//disconnect
	if(type == network_type_disconnect){
		var p = clients[? sock]
		if(instance_exists(p)){
			with(p){
				instance_destroy()
			}
		}
		
		ds_list_delete(sockets, ds_list_find_index(sockets, sock))
		ds_map_delete(clients, sock)
	}
}else if event_id != global.socket{
	var sock = async_load[? "id"]
	var buff = async_load[? "buffer"]
	buffer_seek(buff, buffer_seek_start, 0)
	var cmd = buffer_read(buff, buffer_u8)
	
	var p = clients[? sock]
	switch (cmd){
		case PACKET_KEY :
			with(p){
				var k = buffer_read(buff, buffer_u8)
				var s = buffer_read(buff, buffer_u8)
				keys[k] = s
			}
		break
		case PACKET_NAME :
			p.name = buffer_read(buff, buffer_string)
			for(var s = 0; s < ds_list_size(sockets); s++){
				var so = ds_list_find_value(sockets, s)
				SendRemoteEntity(so, CMD_NAME, p.id, p.name)
			}
		break
		case PACKET_TANK_CHARACTER :
			if ready[sock] = false{
				var c = buffer_read(buff, buffer_u8)
				if ds_list_find_value(available_tanks, ds_list_find_index(available_tanks, c)) != undefined{
					p.character = c
					ready[sock] = true
					//let the client play
					SendPlay(sock)
					with(p){
						HandleSprites(c)
						
					}
					for(var s = 0; s < ds_list_size(sockets); s++){
						var so = ds_list_find_value(sockets, s)
						SendPicked(so, c, true)
					}
					ds_list_delete(available_tanks, ds_list_find_index(available_tanks, c))	
				}
			}
		break
		case PACKET_MYID :
			SendPlayerID(sock, sock)
		break
	}
}