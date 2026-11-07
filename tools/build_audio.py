from pathlib import Path
import wave,math,struct
p=Path(__file__).resolve().parents[1]/'art'
for name,freq,duration in [('hit',420,.1),('heal',750,.25),('win',980,.4),('hurt',160,.18)]:
 with wave.open(str(p/(name+'.wav')),'wb') as w:
  w.setparams((1,2,22050,0,'NONE','not compressed'))
  w.writeframes(b''.join(struct.pack('<h',int(3000*math.sin(2*math.pi*freq*t/22050)*(1-t/(22050*duration))**2)) for t in range(int(22050*duration))))
