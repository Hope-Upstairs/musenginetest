draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_alpha(1)
draw_text(0,0,"global pitch: "+string(gl_pitch))
draw_text(0,18,"channels: "+string(channels))
draw_text(0,36,"speed: "+string(m_speed))

if (draw_mode == 1){

	draw_set_halign(fa_center)
	
	for (var i = 0; i<14; i++){draw_line(188+32*i,0,188+32*i,360)}
	for (var i = 0; i<=channels; i++){draw_line(0,60+20*i,640,60+20*i)}
	for (var i = 1; i<=3; i++){draw_line(47*i,60,47*i,60+(channels)*20)}
	
	for (var chan = 0; chan < channels; chan++) {
	
		if (!active[chan]){
		
			draw_set_color(c_red)
			draw_text(20+120, 20*(chan+3), "MUTED")
		}
		
		if timer[chan]>0{
		
			draw_set_color(c_white)
			draw_text(20+0, 20*(chan+3), timer[chan])
			draw_text(20+48, 20*(chan+3), noteind[chan]+3)
			
			if active[chan]{
			
				draw_set_color(c_lime)
				
				if abs(song[chan][noteind[chan]][2]+1) {
				
					draw_text(20+96, 20*(chan+3), song[chan][max(noteind[chan],0)][0])
					draw_set_color(c_fuchsia)
					draw_text(20+144, 20*(chan+3), song[chan][max(noteind[chan],0)][2])
					
				}
				
			}
			
			for (var note = noteind[chan]+1; note <= array_length(song[chan]); note++) {
			
				if (note==array_length(song[chan])){
				
					draw_set_color(c_yellow)
					draw_text(12+32*(note-noteind[chan]+5),20*(chan+3),"<=")
					draw_set_color(c_white)
					
				}else{
				
					if (32*(note-noteind[chan]+3))>640 break
					
					draw_set_color(c_white)
					
					if (note == loopStart[chan]-3) { draw_set_color(c_yellow) }
					
					if (song[chan][note][2] == -1) {
					
						draw_set_color(c_red)
						draw_text(12+32*(note-noteind[chan]+5),20*(chan+3),"X")
						continue
						
					}
					
					draw_text(12+32*(note-noteind[chan]+5),20*(chan+3),song[chan][note][0])
					
				}
				
			}
			
		}else{
		
			draw_set_color(c_red)
			draw_text(47, 20*(chan+3), "STOPPED")
			
		}
		
	}
	
}
else if draw_mode==2{

	for (var chan = 0; chan < channels; chan++) {
	
		if timer[chan]<=0 continue
		
		if active[chan]{
		
			draw_set_color(color[chan])
			draw_set_alpha(1)
			
		}else{
		
			draw_set_color(c_gray)
			draw_set_alpha(0.1)
			
		}
		
		var curr_xpos = 0
		var note = song[chan][noteind[chan]][0]
		var extratime = 0
		
		var back_xpos = 0
		var shouldDraw = true
		
		if (song[chan][noteind[chan]][2] == -1){
		
			shouldDraw = false
			
		}else{
		
			var i = noteind[chan]
			
			while true{
				
				break
			}
			
			var note = song[chan][i][0] - draw_hei
			
		}
		
		if (shouldDraw) {
		
			var i = noteind[chan]
			while true{
				i++
				if (i>=loopEnd[chan]) break
				if (song[chan][i][2] == -2){
					extratime += song[chan][i][1]
					
				} else break
				
			}
			//var extratime = 0
			if active[chan] draw_triangle(curr_xpos-back_xpos,180-(note_height/2)-note*note_height,curr_xpos-back_xpos,180+(note_height/2)-note*note_height,curr_xpos-back_xpos+note_width*(timer[chan]+extratime),180-note*note_height,false)
			draw_rectangle(curr_xpos-back_xpos,180-(note_height/2)-note*note_height,curr_xpos-back_xpos+note_width*(timer[chan]+extratime),180+(note_height/2)-note*note_height,true)
		}
		
		curr_xpos+=note_width*timer[chan]
		
		for (var cnote = noteind[chan]+1; cnote < array_length(song[chan]); cnote++) {
		
			var curTimer = song[chan][cnote][1]
			var note = song[chan][cnote][0] - draw_hei
			
			if (song[chan][cnote][2] >= 0) {
			
				var extratime = 0
				var i = cnote
				
				while true{
				
					i++
					if (i>=loopEnd[chan]) break
					
					if (song[chan][i][2] == -2){
					
						extratime += song[chan][i][1]
						
					} else break
					
				}
				
				if active[chan] draw_triangle(curr_xpos,180-(note_height/2)-note*note_height,curr_xpos,180+(note_height/2)-note*note_height,curr_xpos+note_width*(curTimer+extratime),180-note*note_height,false)
				
				draw_rectangle(curr_xpos,180-(note_height/2)-note*note_height,curr_xpos+note_width*(curTimer+extratime),180+(note_height/2)-note*note_height,true)
			
			}
			
			curr_xpos+=note_width*curTimer
			if curr_xpos>=640 break
			
		}
		
	}
	
}