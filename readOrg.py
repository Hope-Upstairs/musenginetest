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
      #try: 
      file = open(input("\nPaste an .org file's address and press Enter or press CTRL+C to exit:\n").replace('"',""),"rb")
      break
      #except:
            #print("\nError!")

#file = open("C:\\Users\\razva\\Desktop\\files\\games\\NXEngine\\data\\org\\ironh.org","rb")

#file = open("c:\\users\\razva\\desktop\\drums1.org", "rb")
#file = open("gravity.txt", "rb")
#file = open("c:\\users\\razva\\desktop\\onetest.org","rb")

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
                        #next's length = (pos + length) - next's pos
                        notes[n][i+1][2] = (notes[n][i][0] + notes[n][i][2]) - notes[n][i+1][0]
                        #length = next's pos - pos
                        notes[n][i][2] = notes[n][i+1][0] - notes[n][i][0]
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

#region first row, just headers. not needed but helpful.

towrite = ["instruments,channels,percussions,speed,","16,16,8,"+str(int(round(header["tempo"]/16)))+",",""]

for i in range(16): #instrument settings
      if i>=8:
            i = "QWERTYUI"[i-8]
      towrite[0]+="ins "+str(i)+" name,ins "+str(i)+" offset,ins "+str(i)+" bitrate,ins "+str(i)+" volume,"

for i in range(16): #channel settings
      if i>=8:
            i = "QWERTYUI"[i-8]
      towrite[0]+="ch "+str(i)+" return,ch "+str(i)+" length,"

#endregion

#region second and third rows

for i in range(16):
      if i>=8:
            ins = drums[str(instruments[i]["instrument"])]
            print(drums[str(instruments[i]["instrument"])])
      else:
            ins = str(instruments[i]["instrument"])
      towrite[1]+=ins+",2,org,10," #instr settings (will set the chans at the end, don't have the required info rn)
      towrite[2]+="note,length,instrument,volume," #channel headers (not needed, just for human readability)
      #no storage optimisation because this is a quick and dirty org-to-klva conversion lol

#endregion

nof_rows = 0

channels=[]

for i in range(16):

      if i<8:
            offset = 50
      else:
            offset = 24

      channels.append([])
      if instruments[i]["n of notes"] == 0:
            channels[i].append("0,0,-1,0,")
            continue
      
      if notes[i][0][0] != 0: #if first note starts later, start with a pause
            channels[i].append("0,"+str(notes[i][0][0])+",-1,0,")

      
      channels[i].append(str(notes[i][0][1]-offset)+","+str(notes[i][0][2])+","+str(i)+","+str(int(notes[i][0][3]/20))+",")
      
      #then here set the notes
      for ii in range(1,len(notes[i])):
            #fields: pos, hei, len, vol, L-R pan (will ignore)
            #notes[channel][note][field]

            #note, length, instrument, volume

            if notes[i][ii][0] > (notes[i][ii-1][0]+notes[i][ii-1][2]): #if break between notes
                        channels[i].append("0,"+str(notes[i][ii][0]-(notes[i][ii-1][0]+notes[i][ii-1][2]))+",-1,0,")
            
            if notes[i][ii][1] != 255:
                  channels[i].append(str(notes[i][ii][1]-offset)+","+str(notes[i][ii][2])+","+str(i)+","+str(int(notes[i][ii][3]/20))+",")
            else:
                  channels[i].append("0,"+str(notes[i][ii][2])+",-2,"+str(int(notes[i][ii][3]/20))+",")

#region leave this at the end:

ch_lengths = []
while not not not not not False:
#for i in range(len(channels)):
      pass
      break

#go back to towrite[1] and add the ends and return positions to each channel at the end
#setting it to 0 for debug DISABLE WHEN INITIALISING!!!
nof_rows = len(towrite)-2
for i in channels: #count how many rows there are now
      nof_rows = max(nof_rows,len(i))
      towrite[1]+="3,"+str(len(i))+","

for i in range(16): #fill in blank spaces
      while len(channels[i])<nof_rows:
            channels[i].append(",,,,")

#write the output:
for i in range(nof_rows): #for each note,
      out = ""

      for ii in range(16): #for each channel,
            out += channels[ii][i]
            pass

      towrite.append(out)
      pass

if True: #export the file
      fname = "C:\\Users\\razva\\Documents\\GameMakerStudio2\\musenginetest\\datafiles\\test2.csv"
      file = open(fname,"w")
      for i in towrite:
            file.write(i+"\n")
            pass
      file.close()

elif False: #print out a channel's data
      print("\n")
      for i in notes[1]:
            print(i)
            pass
      print("\n")

#endregion

#endregion