draw_set_color(c_white)
draw_text(0,0,"global pitch: "+string(gl_pitch))
draw_text(0,18,"channels: "+string(channels))
draw_text(0,36,"speed: "+string(game_get_speed(gamespeed_fps)/10))
for (var i = 0; i<=14; i++)	draw_line(188+32*i,0,188+32*i,360)
for (var i = 0; i<=channels; i++)	draw_line(0,60+20*i,640,60+20*i)

for (var ii = 0; ii < channels; ii++) {
	draw_set_color(c_white)
	draw_text(32, 20*(ii+3), noteind[ii]+3)
	draw_set_color(c_lime)
	if abs(song[ii][noteind[ii]][2]+1) {
		draw_text(96, 20*(ii+3), song[ii][max(noteind[ii],0)][0])
		draw_set_color(c_fuchsia)
		draw_text(160, 20*(ii+3), song[ii][max(noteind[ii],0)][2])
	}
	for (var i = noteind[ii]+1; i < array_length(song[ii]); i++) {
		if (32*(i-noteind[ii]+3))>640 break
		draw_set_color(c_white)
		if (i == loopStart[ii]-3)or(i == loopEnd[ii]-1) draw_set_color(c_yellow)
		if (song[ii][i][2] == -1) {
			draw_set_color(c_red)
			draw_text(32*(i-noteind[ii]+5),20*(ii+3),"X")
			continue
		}
		draw_text(32*(i-noteind[ii]+5),20*(ii+3),song[ii][i][0])
	}
}