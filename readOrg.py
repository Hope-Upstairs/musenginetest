from os import system

#region Extracting the song

#region reading the file

org = []

drums = {

      "0":  "Bass01",
      "1":  "Bass02",
      "10": "Bass03",
      "12": "Bass04",
      "13": "Bass05",
      "28": "Bass06",
      "29": "Bass07",
      "39": "Bass08",
      "26": "Bell",
      "27": "Cat",
      "36": "Clap01",
      "7":  "Crash",
      "20": "Crash02",
      "5":  "HiClose",
      "16": "HiClose02",
      "18": "HiClose03",
      "35": "HiClose04",
      "41": "HiClose05",
      "6":  "HiOpen",
      "17": "HiOpen02",
      "19": "HiOpen03",
      "34": "HiOpen04",
      "25": "OrcDrm01",
      "8":  "Per01",
      "9":  "Per02",
      "37": "Pesi01",
      "38": "Quick01",
      "21": "RevSym01",
      "22": "Ride01",
      "2":  "Snare01",
      "3":  "Snare02",
      "14": "Snare03",
      "15": "Snare04",
      "30": "Snare05",
      "31": "Snare06",
      "32": "Snare07",
      "40": "Snare08",
      "4":  "Tom01",
      "11": "Tom02",
      "23": "Tom03",
      "24": "Tom04",
      "33": "Tom05",

}

while True:
      try: 
            file = open(input("\nPaste an .org file's address and press Enter or press CTRL+C to exit:\n").replace('"',""),"rb")
            break
      except:
            print("\nError!")

#file = open("C:\\Users\\razva\\Desktop\\files\\games\\NXEngine\\data\\org\\ironh.org","rb")
#file = open("C:\\Users\\razva\\Desktop\\files\\games\\NXEngine\\data\\org\\gravity.org","rb")
#file = open("C:\\Users\\razva\\Desktop\\files\\games\\NXEngine\\data\\org\\maze.org","rb")

for i in list(bytearray(file.read())):
      org.append(i)

file.close()

#endregion

#region A. Header

header = { #File Properties

      "tempo": (org[0x07]*256)+org[0x06],
      "steps per bar": org[0x08],
      "beats per step": org[0x09],
      "loop beginning": (((((org[0x0D]*256)+org[0x0C])*256)+org[0x0B])*256)+org[0x0A],
      "loop end": (((((org[0x11]*256)+org[0x10])*256)+org[0x0F])*256)+org[0x0E]

}

instruments = []
offset = 0x12
for i in range(16): #Instruments
      instruments.append({

            "pitch": (org[offset+1]*256)+org[offset+0],
            "instrument": org[offset+2],
            "pi": org[offset+3], #no reason for it to be 1 (if 1, disables holding down notes). or maybe it's used in drums?
            "n of notes": (org[offset+5]*256)+org[offset+4]

      })
      offset+=6

#print()
#for i in instruments[8:]:
#      print(drums[str(i["instrument"])])
#      print(i["pi"])

#endregion

#region B. Song

notes = []

for n in range(len(instruments)):   #for each channel:

      notes.append([])
      if instruments[n]["n of notes"] == 0: #if no notes here, go to the next channel
            continue

      for i in range(instruments[n]["n of notes"]): #for each note: read the Note Positions
            notes[n].append([(((((org[offset+3]*256)+org[offset+2])*256)+org[offset+1])*256)+org[offset+0]])
            offset+=4

      for ii in range(0,4): #read each property (height, length, volume, panning)
            for i in range(instruments[n]["n of notes"]): #for each note:
                  notes[n][i].append(org[offset]) #read it
                  offset+=1
      
      if True:
            #go to first note
            i = 0
            #while not end of list:
            while (i+1)<len(notes[n]):
                  #if next one is 255:
                  if notes[n][i+1][1] == 255:
                        if notes[n][i+1][0] < notes[n][i][0]+notes[n][i][2]:
                              #next's length = (pos + length) - next's pos
                              notes[n][i+1][2] = ((notes[n][i][0] + notes[n][i][2]) - notes[n][i+1][0])
                              if notes[n][i+1][2] <= 0:
                                    print("WHY IS THIS ZERO")
                              #length = next's pos - pos
                              notes[n][i][2] = (notes[n][i+1][0] - notes[n][i][0])
                              if notes[n][i][2] <= 0:
                                    print("WHY IS THIS ZERO")
                        else:
                              print("modifier outside note event")
                  #go to next note
                  i+=1

# Position (4 bytes)
# Height (0-95)
# Length (1 byte)
# Volume (0-254, default 200)
# Panning (0-12, 6 = center)

#endregion

#endregion

#region Exporting it

#region first row, just headers. not needed but helpful if ya wanna look at it or modify it by hand.

towrite = ["instruments,channels,percussions,speed,","16,16,8,"+str(int(round(header["tempo"]/16)))+",",""]

for i in "12345678QWERTYUI": #instrument settings
      towrite[0]+="ins "+i+" name,ins "+i+" offset,ins "+i+" bitrate,ins "+i+" volume,"

for i in "12345678QWERTYUI": #channel settings
      towrite[0]+="ch "+i+" return,ch "+i+" length,"

#endregion

#region second and third rows

for i in range(16):
      if i>=8:
            ins = drums[str(instruments[i]["instrument"])]
      else:
            ins = str(instruments[i]["instrument"])
      towrite[1]+=ins+",2,org,10," #instr settings (will set the chans at the end, don't have the required info rn)
      towrite[2]+="note,length,instrument,volume," #channel headers (not needed, just for human readability)
      #no storage optimisation because this is a quick and dirty org-to-klva conversion lol

#endregion

nof_rows = 0

channels=[]

for i in range(16): #for each channel

      if i<8: #honey i fucked up the bitrate
            offset = 50
      else:
            offset = 24

      channels.append([])
      if instruments[i]["n of notes"] == 0:
            channels[i].append([0,0,-1,0])
            continue
      
      if notes[i][0][0] != 0: #if first note starts later, start with a pause
            channels[i].append([0,notes[i][0][0],-1,0])

      
      channels[i].append([notes[i][0][1]-offset,notes[i][0][2],i,int(notes[i][0][3]/20)])
      
      #then here set the notes
      for ii in range(1,len(notes[i])):
            #fields: pos, hei, len, vol, L-R pan (will ignore)
            #notes[channel][note][field]

            #note, length, instrument, volume

            if notes[i][ii][0] > (notes[i][ii-1][0]+notes[i][ii-1][2]): #if break between notes
                  channels[i].append([0,notes[i][ii][0]-(notes[i][ii-1][0]+notes[i][ii-1][2]),-1,0])
            
            if notes[i][ii][1] != 255:
                  channels[i].append([notes[i][ii][1]-offset,notes[i][ii][2],i,int(notes[i][ii][3]/20)])
            else:
                  channels[i].append([0,notes[i][ii][2],-2,int(notes[i][ii][3]/20)])

#error detection (weirdly generated .org file? should overlapping events even be possible?)
for i in range(len(channels)):
      for ii in range(len(channels[i])):
            if ii != 0:
                  if channels[i][ii][1] == 0:
                        print("Warning! Event {} (line {}) of channel {} (row {}) has a length of 0. Channel will get stuck! How did this happen?".format(ii,ii+4,i,67+i*4))
                  elif channels[i][ii][1] < 0:
                        print("Warning! Event {} (line {}) of channel {} (row {}) has a negative length. Channel will get stuck! How did this happen?".format(ii,ii+4,i,67+i*4))

#
#
#
#region     ADD THE LENGTH CODE HERE

ch_bounds = []

while False:
      pass


for i in range(len(channels)):

      should_pad = 0
      ch_bounds.append([3,3])

      #skip empty channels
      if channels[i][0][1] == 0:
            continue

      pos = 0

      for ii in range(len(channels[i])): #get start
            if pos >= header["loop beginning"]: #if reached the start bound
                  if pos > header["loop beginning"]: #if passed the start bound
                        should_pad += pos-header["loop beginning"]
                  break

            pos += channels[i][ii][1] #add the length of the current note

      ch_bounds[-1][0] = 3+ii


      for ii in range(len(channels[i])): #get end
            pos += channels[i][ii][1] #add the length of the current note

            #rewrite for different cases, not tested yet lmfao
            #scenarios:
            # note stops before end = > add a pause
            # there are notes after end = > get rid of them or something

            # note stops at the end = > do nothing
            if pos >= header["loop end"]:
                  # note stops after end = > crop it
                  if pos > header["loop end"]:
                        channels[i][ii][1] -= pos-header["loop end"]
                  break

      ch_bounds[-1][1] = 3+ii

      if should_pad:
            channels[i].append([0,should_pad,-1,0]) #add a break at the end so it returns right

      ch_bounds[-1][1] = 3+len(channels[i])

#ch_bounds values should be offset by 3

#endregion
#
#

#go back to towrite[1] and add the ends and return positions to each channel at the end
#setting it to 0 for debug DISABLE WHEN INITIALISING!!!
nof_rows = len(towrite)-2
for i in range(len(channels)): #count how many rows there are now
      nof_rows = max(nof_rows,len(channels[i]))

      ch_bounds[i][0] = 3
      ch_bounds[i][1] = len(channels[i])
      towrite[1]+="{},{},".format(ch_bounds[i][0],ch_bounds[i][1])

for i in range(16): #fill in blank spaces
      while len(channels[i])<nof_rows:
            channels[i].append(",,,")

#write the output:
for i in range(nof_rows): #for each note,
      out = ""

      for ii in range(16): #for each channel,
            out += str(channels[ii][i]).replace("[","").replace("]","")+","

      towrite.append(out)

if True: #export the file
      fname = "C:\\Users\\razva\\Documents\\GameMakerStudio2\\musenginetest\\datafiles\\test2.csv"
      #fname = "org.csv"
      file = open(fname,"w")
      for i in towrite:
            file.write(i+"\n")
      file.close()
      #system(fname)

elif False: #print out a channel's data
      print("\n")
      for i in notes[1]:
            print(i)
      print("\n")

#endregion