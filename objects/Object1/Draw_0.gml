draw_text(0,0,"global pitch: "+string(gl_pitch))
draw_text(0,18,"channels: "+string(channels))
draw_text(0,36,"timer: "+string(gtime))
draw_text(0,54,"speed: "+string(game_get_speed(gamespeed_fps)/10))
draw_text(100,9,"loopStart: "+string(loopStart))
draw_text(100,27,"loopEnd: "+string(loopEnd))

for (var ii = 0; ii < channels; ii++) {
	draw_text(30, 32*(ii+3), noteind[ii]+3)
	for (var i = noteind[ii]; i < array_length(song[ii]); i++) {
		draw_text(32*(i-noteind[ii]+3),32*(ii+3),song[ii][i][0])
	}
}