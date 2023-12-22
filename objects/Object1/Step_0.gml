if keyboard_check_pressed(vk_space) pause = !pause
//if keyboard_check(ord("Q")) game_end()
if keyboard_check(ord("R")) game_restart()
if keyboard_check(ord("Z")) game_set_speed(int64(grid[# 3, 1]),gamespeed_fps)
if keyboard_check(ord("B")) {pause = true
	for (var i = 0;i<channels;i++){
		audio_stop_sound(currSound[i])
		currSound[i] = noone
	}
}
if keyboard_check_released(ord("B")) {
	for (var i = 0;i<channels;i++){
		audio_stop_sound(currSound[i])
		noteind[i] = -1
		timer[i] = 1
		currSound[i] = noone
		pause = false
	}
}

gl_pitch += (keyboard_check_pressed(vk_up)-keyboard_check_pressed(vk_down))
game_set_speed(game_get_speed(gamespeed_fps)+((keyboard_check_pressed(vk_right)-(keyboard_check_pressed(vk_left)and(game_get_speed(gamespeed_fps)>5)))*5),gamespeed_fps)

if !pause {
	for (var i = 0;i<channels;i++){
		timer[i] -= 1
		if (timer[i] == 0) {
			if (noteind[i]==loopEnd[i]-1) {
				noteind[i] = loopStart[i]-4
				timer[i] = 1
				i--
				continue
			}
			noteind[i]++
			if (song[i][noteind[i]][2] != -2) {
				audio_stop_sound(currSound[i])
				currSound[i] = noone
			}
			timer[i] = song[i][noteind[i]][1]
			if (song[i][noteind[i]][2] != -1) {
				currSound[i]=playNote(song[i][noteind[i]][0]-instruments[song[i][noteind[i]][2]][1],instruments[song[i][noteind[i]][2]][0])
			}
			audio_sound_gain(currSound[i],song[i][noteind[i]][3]/10,0);
		}
	}
}