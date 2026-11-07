"""Original procedural fantasy SFX. No recordings/assets from the reference game.
Requires numpy, scipy, and ffmpeg (only for the ambience Ogg encode).
"""
from pathlib import Path
import hashlib,json,math,subprocess,wave
import numpy as np
from scipy.signal import butter,sosfilt

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'art/audio';OUT.mkdir(parents=True,exist_ok=True)
if (OUT/'provenance.json').exists() and json.loads((OUT/'provenance.json').read_text()).get('provider')=='ElevenLabs':
 raise SystemExit('Runtime uses ElevenLabs. Refusing to overwrite provider audio with prototype synthesis; use tools/import_elevenlabs_audio.py.')
SR=32000
rng=np.random.default_rng(271828)
def t(d): return np.arange(round(d*SR))/SR
def noise(d,low=200,high=7000):
 x=rng.standard_normal(round(d*SR))
 return sosfilt(butter(2,[low,high],btype='bandpass',fs=SR,output='sos'),x)
def env(d,attack=.004,decay=.12):
 x=t(d);return np.minimum(x/max(attack,1/SR),1)**1.5*np.exp(-x/decay)
def tone(d,f0,f1=None):
 x=t(d);f1=f0 if f1 is None else f1
 return np.sin(2*np.pi*(f0*x+(f1-f0)*x*x/(2*d)))
def add(dst,src,at=0,gain=1):
 i=round(at*SR);end=min(len(dst),i+len(src))
 if end>i:dst[i:end]+=src[:end-i]*gain
def ring(d,f):
 x=t(d)
 return sum(a*np.sin(2*np.pi*f*k*x)*np.exp(-x/decay) for k,a,decay in [(1,1,.30),(2.013,.28,.14),(2.77,.08,.06)])*np.minimum(x/.003,1)
def bell_sequence(notes,spacing=.1,duration=.8):
 y=np.zeros(round(duration*SR))
 for i,f in enumerate(notes):
  sample=ring(.55,f)
  add(y,sample,i*spacing,.55)
  add(y,sample,i*spacing+.065,.09)
  add(y,sample,i*spacing+.14,.05)
 return y

def whoosh(d=.22,factor=1):
 x=t(d);sweep=2*np.pi*(2200*factor*x-1500*factor*x*x/(2*d))
 return (noise(d,500,9000)*.75+np.sin(sweep)*.045)*np.sin(np.pi*x/d)**1.6

def impact(d=.28,metal=True,weight=1):
 x=t(d)
 y=noise(d,500 if metal else 140,8000 if metal else 3000)*env(d,.001,.024)*.32
 y+=tone(d,145*weight,65*weight)*env(d,.001,.055)*.65
 if metal:
  y+=(tone(d,1700*weight)+.34*tone(d,2771*weight))*env(d,.001,.065)*.12
 else:
  y+=(tone(d,270)+.32*tone(d,515))*env(d,.001,.10)*.18
 return y

assets={}
for i in range(3):
 assets[f'sword_swing_{i+1}']=whoosh(.18+i*.02,1+i*.08)
 assets[f'sword_hit_{i+1}']=impact(.24+i*.025,weight=1+i*.06)
assets['spear_swing']=whoosh(.19,.67)+tone(.19,210,85)*env(.19,.018,.08)*.06
assets['staff_swing']=bell_sequence([740,1108],.045,.26)+whoosh(.26,.85)*.18
assets['spear_hit']=impact(.3,False,1.3)
assets['staff_hit']=bell_sequence([587,880],.035,.4)+impact(.4)*.16
assets['critical']=bell_sequence([1175,1760],.055,.50)*.35+impact(.50,True,1.2)
assets['cast']=bell_sequence([294,440,587],.055,.36)+whoosh(.36,.7)*.17
assets['burst']=bell_sequence([587,880,1175],.065,.70)+whoosh(.70,.65)*.35+impact(.70,False)*.28
assets['heal']=bell_sequence([659,880,1175],.12,.82)
assets['lumi']=bell_sequence([1319,1760],.07,.55)
assets['ash']=whoosh(.20,1.45)
assets['arrow_hit']=impact(.20,False,1.6)
assets['guard_ready']=bell_sequence([440,660],.025,.20)
assets['guard_hit']=bell_sequence([784,1175],.016,.35)*.45+impact(.35,True)*.65
assets['shield_on']=bell_sequence([294,440,588],.065,.50)
assets['shield_break']=bell_sequence([1760,1397,1047],.055,.58)*.55+noise(.58,900,8500)*env(.58,.002,.10)*.17
assets['enemy_charge']=tone(.30,230,130)*env(.30,.055,.18)+noise(.30,120,900)*env(.30,.02,.14)*.3
assets['boss_charge']=tone(.60,160,95)*env(.60,.10,.33)+noise(.60,90,1500)*env(.60,.025,.22)*.4
assets['boss_slam']=impact(.48,False,.65)+noise(.48,200,2200)*env(.48,.003,.08)*.2
assets['counter']=bell_sequence([1047,784],.045,.35)+impact(.35,True,.8)*.4
assets['hurt']=impact(.24,False,.85)
assets['enemy_down']=tone(.35,240,75)*env(.35,.008,.11)+noise(.35,200,2500)*env(.35,.008,.08)*.22
assets['step']=noise(.095,180,1700)*env(.095,.004,.025)+tone(.095,120,65)*env(.095,.002,.025)*.2
assets['stage_start']=bell_sequence([294,440,587],.10,.65)
assets['boss_arrive']=tone(.65,98,73)*env(.65,.02,.3)+bell_sequence([294,277],.15,.65)*.12
assets['victory']=bell_sequence([587.33,739.99,880,1174.66],.18,1.45)
assets['defeat']=bell_sequence([440,349.23,293.66],.20,1.2)
assets['ui_click']=tone(.065,900,680)*env(.065,.001,.012)+noise(.065,500,4500)*env(.065,.001,.006)*.08
assets['confirm']=bell_sequence([660,880],.06,.30)
assets['equip']=noise(.18,500,7000)*env(.18,.002,.025)*.15+tone(.18,980,720)*env(.18,.002,.04)
assets['forge']=impact(.50,True)*.5+bell_sequence([880,1175],.09,.50)*.30
assets['reward']=bell_sequence([880,1175,1568],.08,.60)
assets['upgrade']=bell_sequence([587,740,880,1175],.09,.78)

def final_pcm(signal,peak=.67):
 y=np.asarray(signal,dtype=np.float64).copy()
 fade=min(128,len(y)//3)
 y[:fade]*=np.linspace(0,1,fade);y[-fade:]*=np.linspace(1,0,fade)
 y-=y.mean()
 maximum=np.max(np.abs(y))
 if maximum:y*=peak/maximum
 y[0]=0;y[-1]=0
 return np.round(y*32767).astype('<i2')
report=[]
for name,signal in assets.items():
 pcm=final_pcm(signal)
 path=OUT/(name+'.wav')
 with wave.open(str(path),'wb') as out:
  out.setparams((1,2,SR,0,'NONE','not compressed'));out.writeframes(pcm.tobytes())
 report.append(dict(file=path.name,duration=len(pcm)/SR,peak_db=round(20*math.log10(max(abs(pcm.astype(float)))/32768),3),rms_db=round(20*math.log10(np.sqrt(np.mean((pcm.astype(float)/32768)**2))),3),sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
# Seamless stereo night air: circular Fourier noise + quiet non-melodic insects.
length=12;count=SR*length
freq=np.fft.rfftfreq(count,1/SR)
ambient=[]
for side in range(2):
 spectrum=(rng.standard_normal(len(freq))+1j*rng.standard_normal(len(freq)))
 weight=1/np.maximum(freq,60)**.85
 weight*=np.minimum(freq/65,1)*np.exp(-freq/1800)
 y=np.fft.irfft(spectrum*weight,count)
 y=y/max(abs(y))*.18
 x=t(length)
 # Integer-cycle oscillators and envelope keep loop boundary periodic.
 y+=.003*np.sin(2*np.pi*(3040+side*11)*x)*(1+np.sin(2*np.pi*x/3))/2
 ambient.append(y)
stereo=np.stack(ambient,axis=1)
stereo*=.20/np.max(abs(stereo))
temp=OUT/'forest_air.tmp.wav'
with wave.open(str(temp),'wb') as out:
 out.setparams((2,2,SR,0,'NONE','not compressed'));out.writeframes(np.round(stereo*32767).astype('<i2').tobytes())
subprocess.run(['ffmpeg','-y','-v','error','-i',str(temp),'-c:a','libvorbis','-q:a','3',str(OUT/'forest_air.ogg')],check=True)
temp.unlink()
# All variations are presentation-only; combat RNG is never consumed by audio.
def cue(files,gain=-10,priority=2,limit=2,cooldown=.035,pitch=.02,bus='battle'):
 if isinstance(files,str):files=[files]
 return dict(files=[s+'.wav' for s in files],gain_db=gain,priority=priority,max_instances=limit,cooldown=cooldown,pitch_variation=pitch,bus=bus)
cues={
 'swing_sword':cue(['sword_swing_1','sword_swing_2','sword_swing_3'],-13,1,3),
 'impact_sword':cue(['sword_hit_1','sword_hit_2','sword_hit_3'],-9,2,3),
 'swing_spear':cue('spear_swing',-12,1,3),'impact_spear':cue('spear_hit',-9,2,3),
 'swing_staff':cue('staff_swing',-14,1,3),'impact_staff':cue('staff_hit',-12,2,3)}
for name,gain,priority in [('critical',-9,3),('cast',-16,1),('burst',-12,3),('heal',-14,3),('lumi',-17,2),('ash',-14,1),('arrow_hit',-14,2),('guard_ready',-17,2),('guard_hit',-10,4),('shield_on',-16,2),('shield_break',-11,4),('enemy_charge',-18,2),('boss_charge',-12,4),('boss_slam',-11,4),('counter',-12,4),('hurt',-12,3),('enemy_down',-17,2),('step',-25,0),('stage_start',-17,2),('boss_arrive',-13,4),('victory',-12,5),('defeat',-15,5),('ui_click',-21,1),('confirm',-19,2),('equip',-17,2),('forge',-16,3),('reward',-15,3),('upgrade',-15,3)]:
 cues[name]=cue(name,gain,priority,1 if priority>=4 else 2,.06 if name=='ui_click' else .035,0 if name in ['victory','defeat','heal','lumi','reward','upgrade'] else .02,'ui' if name in ['ui_click','confirm','equip','forge','reward','upgrade','victory','defeat'] else 'battle')
manifest=dict(version=1,sample_rate=SR,ambience={'file':'forest_air.ogg','gain_db':-14},cues=cues)
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(OUT/'provenance.json').write_text(json.dumps(dict(method='Original deterministic procedural synthesis. No reference audio copied.',seed=271828,sample_rate=SR,numpy=np.__version__,files=report,ambience_sha256=hashlib.sha256((OUT/'forest_air.ogg').read_bytes()).hexdigest()),indent=2)+'\n')
print(f'Built {len(assets)} SFX, {len(cues)} cues and a {length}s stereo ambience loop.')
