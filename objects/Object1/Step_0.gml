if keyboard_check(ord("Q")) game_end()
if keyboard_check(ord("R")) game_restart()
if keyboard_check(ord("Z")) game_set_speed(int64(grid[# 2, 1]),gamespeed_fps)
if keyboard_check_pressed(vk_space) pause=!pause

gl_pitch += (keyboard_check_pressed(vk_up)-keyboard_check_pressed(vk_down))
game_set_speed(max(game_get_speed(gamespeed_fps)+((keyboard_check_pressed(vk_right)-keyboard_check_pressed(vk_left))*5),5),gamespeed_fps)

if !pause {
	gtime++
	for (var i = 0;i<channels;i++){
		timer[i] -= 1
		if (timer[i] == 0) {
			audio_stop_sound(currSound[i])
			currSound[i] = noone
			if (noteind[i]==loopEnd[i]-1) {
				noteind[i] = loopStart[i]-4
				timer[i] = 1
				i--
				continue
			}
			noteind[i]++
			timer[i] = song[i][noteind[i]][1]
			if (song[i][noteind[i]][2] != -1) {
				currSound[i]=playNote(song[i][noteind[i]][0]-instruments[song[i][noteind[i]][2]][1],instruments[song[i][noteind[i]][2]][0])
			}
		}
	}
}