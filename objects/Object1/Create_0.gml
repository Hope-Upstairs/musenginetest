grid = load_csv("cavestory.csv")

gl_pitch = 0
gtime = 0

pause = false

channels = 2

channels = grid[# 1, 1]

instruments = [[Sound1,2],[Sound2,4],[Sound1,14]]

game_set_speed(int64(grid[# 2, 1]),gamespeed_fps)

for (var i = 0; i<channels; i++) {
	var ii = 5+grid[# 0, 1]+(2*i)
	song[i] = array_create(0,0)
	for (var cur_pos = 0; cur_pos<grid[# ii, 1]; cur_pos++) {
		array_insert(song[i],array_length(song[i]),[
		int64(grid[# (5*i), 3+cur_pos]),
		int64(grid[# (5*i)+1, 3+cur_pos]),
		int64(grid[# (5*i)+2, 3+cur_pos]),
		int64(grid[# (5*i)+3, 3+cur_pos]),
		int64(grid[# (5*i)+4, 3+cur_pos])
		])
	}
}

for (var i = 0;i<channels;i++){
	noteind[i] = -1
	timer[i] = 1
	currSound[i] = noone
	loopStart[i] = int64(grid[# 4+grid[# 0, 1]+(2*i), 1])
	loopEnd[i] = int64(grid[# 5+grid[# 0, 1]+(2*i), 1])
}

function playNote(_hei,_ins){
	var i = audio_play_sound(_ins,0,0)
	audio_sound_pitch(i,getPitch(_hei))
	return i
}

function getPitch(_step){
	return power(2, (_step+gl_pitch)/12)
}