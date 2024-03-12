#region keyboard keys

	if keyboard_check_pressed(vk_space) pause = !pause
	if keyboard_check(ord("Q")) game_end()
	if keyboard_check_pressed(vk_f1) draw_mode = 1
	if keyboard_check_pressed(vk_f2) draw_mode = 2
	if keyboard_check_pressed(vk_f3) draw_mode = 3
	if keyboard_check(ord("B")) game_restart()
	if keyboard_check(ord("Z")) game_set_speed(60,gamespeed_fps)
	if keyboard_check(ord("X")) gl_pitch = 0
	
	for(i=0;i<10;i++){
		if keyboard_check_pressed(ord(i)) {active[i]= !active[i]}
	}
	
	if keyboard_check(ord("R")) {
		pause = true
		for (var i = 0;i<channels;i++){
			audio_stop_sound(currSound[i])
			currSound[i] = noone
		}
	}
	
	if draw_mode == 2{
		if keyboard_check_pressed(vk_f5) note_width--
		if keyboard_check_pressed(vk_f6) note_width++
		if keyboard_check_pressed(vk_f7) note_height--
		if keyboard_check_pressed(vk_f8) note_height++
	}
	
	if keyboard_check_released(ord("R")) {
		for (var i = 0;i<channels;i++){
			audio_stop_sound(currSound[i])
			noteind[i] = -1
			timer[i] = 1
			currSound[i] = noone
			pause = false
		}
	}
	
	gl_pitch += (keyboard_check_pressed(vk_up)-keyboard_check_pressed(vk_down))
	game_set_speed(max(0,game_get_speed(gamespeed_fps)+(keyboard_check_pressed(vk_right)-(keyboard_check_pressed(vk_left)))*20),gamespeed_fps)
	
#endregion

if !pause {
	for (var i = 0;i<channels;i++){
		timer[i]--
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
			if (song[i][noteind[i]][2] != -1)and(song[i][noteind[i]][2] != -2)and(active[i]) {
				currSound[i]=playNote(song[i][noteind[i]][0]-instruments[| song[i][noteind[i]][2]][1],instruments[| song[i][noteind[i]][2]][0])
			}
			audio_sound_gain(currSound[i],song[i][noteind[i]][3]/10,0);
		}
	}
}