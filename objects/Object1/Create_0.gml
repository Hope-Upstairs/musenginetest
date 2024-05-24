while(true){	//load the file, no need to ask for this in KLVA so once implemented there, turn it into a function taking a string as the argument
	
	var instr_location = ""
	//var instr_location = "C:\\Users\\razva\\Documents\\GameMakerStudio2\\musenginetest\\datafiles\\"
	var song_location = get_string("enter the file to load:","test2")
	var csv = instr_location+song_location+".csv"
	
	if song_location=="" {
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
	draw_hei = 0
	
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
		
		if string_digits(grid[# 4+4*chan, 1]) == grid[# 4+4*chan, 1] {
			
			var bufferId=buffer_load(instr_location+"wave.dat")
			
			buff2[chan] = buffer_create(256,buffer_fast,1)
			buffer_copy(bufferId,int64(grid[# 4+4*chan, 1])*256,256,buff2[chan],0)
			buffer_delete(bufferId)
			
			soundId = audio_create_buffer_sound(buff2[chan], buffer_s16, 22050, 0, 256, audio_mono);
			
			ds_list_insert(instruments,chan,[soundId,-21,int64(grid[# 7+4*chan, 1]),true])
			
		} else {
		
			if grid[# 6+4*chan, 1] == "org"{
			
				var rate = 22050
				
			}else{
			
				var rate = grid[# 6+4*chan, 1]
				
			}
			
			var bufferId=buffer_load(instr_location+"ins\\"+grid[# 4+4*chan, 1]+".raw")
			
			var length = buffer_get_size(bufferId);
			
			buff2[chan] = buffer_create(length,buffer_fast,1)
			buffer_copy(bufferId,0,length,buff2[chan],0)
			buffer_delete(bufferId)
			
			soundId = audio_create_buffer_sound(buff2[chan], buffer_s16, rate, 0, length, audio_mono);
			
			ds_list_insert(instruments,chan,[soundId,int64(grid[# 5+4*chan, 1]),int64(grid[# 7+4*chan, 1]),false])
		}
	}
	
//there's no need to clear the instruments and the buffer from memory right now
//but please clear each instrument (audio stream) and buffer (each index in array) from memory
//when the song ends or if loading a new one
		
#endregion

m_speed = int64(grid[# 3, 1])

for (var chan = 0; chan<channels; chan++) { //get channel variables and start playback
	active[chan] = true
	//active[chan] = false
	var ii = 5+4*int64(grid[# 0, 1])+(2*chan)
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
		loopStart[chan] = int64(grid[# 4+(4*int64(grid[# 0, 1]))+(2*chan), 1])
		loopEnd[chan] = int64(grid[# 5+(4*int64(grid[# 0, 1]))+(2*chan), 1])
		
	#endregion
	
}

//active[0]=true

//if true {for (chan = 8; chan < channels; chan++){active[chan] = false}}

#region functions

	function playNote(_hei,_ins,_loop=false){
		var i = audio_play_sound(_ins,0,_loop)
		audio_sound_pitch(i,power(2, (_hei+gl_pitch)/12))
		return i
	}

#endregion