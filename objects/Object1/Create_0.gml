while(true){	//load the file, no need to ask for this in KLVA so definitely change it
	
	var instr_location = "C:\\Users\\razva\\Documents\\GameMakerStudio2\\musenginetest\\datafiles\\"
	var song_location = get_string("enter the file to load:","marin")
	var csv = instr_location+song_location+".csv"
	
	if csv=="C:\\Users\\razva\\Documents\\GameMakerStudio2\\musenginetest\\datafiles\\.csv" {
		game_end()
		exit
		break
	}
	
	if file_exists(csv){
		grid = load_csv(csv)
		break
	}
	
}

#region declare vars
	
	draw_mode = 1
	
	note_width = 4
	note_height = 8
		
	gl_pitch = 0
	
	pause = false
	
	channels = int64(grid[# 1, 1])

#endregion

#region import instruments

	instruments = ds_list_create()
		
	ii=int64(grid[# 0, 1])
	for(chan=0; chan<ii; chan++){
		
		var rate = grid[# 6+3*chan, 1]
		
		var bufferId=buffer_load(instr_location+song_location+"\\"+grid[# 4+3*chan, 1]+".raw")
		
		var length = buffer_get_size(bufferId);
		
		buff2[chan] = buffer_create(length,buffer_fast,1)
		buffer_copy(bufferId,0,length,buff2[chan],0)
		buffer_delete(bufferId)
		
		soundId = audio_create_buffer_sound(buff2[chan], buffer_s16, rate, 0, length, audio_mono);
		
		ds_list_insert(instruments,chan,[soundId,int64(grid[# 5+3*chan, 1])])
	}
	
//there's no need to clear the instruments and the buffer from memory right now
//but please clear each instrument (audio stream) and buffer (each index in array) from memory
//when the song ends or if loading a new one
		
#endregion

m_speed = int64(grid[# 3, 1])

for (var chan = 0; chan<channels; chan++) { //get channel variables and start playback
	active[chan] = true
	active[chan] = false
	var ii = 5+3*int64(grid[# 0, 1])+(2*chan)
	song[chan] = array_create(0,0)
	for (var cur_pos = 0; cur_pos<grid[# ii, 1]; cur_pos++) {
		array_insert(song[chan],array_length(song[chan]),[
		int64(grid[# (4*chan), 3+cur_pos]),
		int64(grid[# (4*chan)+1, 3+cur_pos])*m_speed,
		int64(grid[# (4*chan)+2, 3+cur_pos]),
		int64(grid[# (4*chan)+3, 3+cur_pos])
		])
	}
	randomize()
	color[chan]=make_colour_rgb(irandom_range(30,255),irandom_range(30,255),irandom_range(30,255))
	
	#region start playback
	
		noteind[chan] = -1
		timer[chan] = 1
		currSound[chan] = noone
		loopStart[chan] = int64(grid[# 4+(3*int64(grid[# 0, 1]))+(2*chan), 1])
		loopEnd[chan] = int64(grid[# 5+(3*int64(grid[# 0, 1]))+(2*chan), 1])
		
	#endregion
	
}

//active[0] = true
//active[1] = true
//active[2] = true

active[3] = true
active[4] = true
active[5] = true

#region functions

	function playNote(_hei,_ins){
		var i = audio_play_sound(_ins,0,0)
		audio_sound_pitch(i,getPitch(_hei))
		return i
	}
	
	function getPitch(_step){
		return power(2, (_step+gl_pitch)/12)
	}

#endregion