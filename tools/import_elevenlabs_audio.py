"""Import an already-generated ElevenLabs artifact. Never reads an API key.
Preserves raw MP3 + receipts; only aligns/normalizes/converts provider audio.
"""
from pathlib import Path
import argparse,hashlib,json,math,shutil,subprocess,tempfile,wave
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
SR=32000
LIMITS={'arrow_hit':.28,'ash':.25,'boss_arrive':1.5,'boss_charge':1.,'boss_slam':.75,'burst':.9,'cast':.6,'confirm':.5,'counter':.55,'critical':.8,'defeat':1.6,'enemy_charge':.55,'enemy_down':.7,'equip':.4,'forge':.65,'guard_hit':.5,'guard_ready':.3,'heal':1.2,'hurt':.4,'lumi':.9,'reward':.8,'shield_break':.8,'shield_on':.8,'spear_hit':.4,'spear_swing':.3,'staff_hit':.7,'staff_swing':.5,'stage_start':1.,'step':.20,'ui_click':.14,'upgrade':1.1,'victory':2.}
for i in range(1,4):LIMITS[f'sword_hit_{i}']=.4;LIMITS[f'sword_swing_{i}']=.3

def decode(path,channels=1):
 result=subprocess.run(['ffmpeg','-v','error','-i',str(path),'-ar',str(SR),'-ac',str(channels),'-f','f32le','pipe:1'],check=True,capture_output=True)
 return np.frombuffer(result.stdout,dtype='<f4').astype(float)

def align(y,limit):
 assert len(y)>100 and np.isfinite(y).all()
 peak=float(np.max(abs(y)));assert peak>.001,'Provider response is effectively silent'
 kernel=np.ones(64)/64
 envelope=np.convolve(abs(y),kernel,'same')
 onset=np.flatnonzero(envelope>max(.001,peak*.018))
 assert len(onset)>0
 first=max(0,int(onset[0])-64)
 tail=np.flatnonzero(envelope>max(.0003,peak*.006))
 last=min(len(y),int(tail[-1]) + int(.075*SR))
 x=y[first:last]
 before=len(x)/SR
 ratio=before/limit
 if ratio>1.03:
  filters=[]
  while ratio>2:filters.append('atempo=2');ratio/=2
  filters.append(f'atempo={ratio:.8f}')
  result=subprocess.run(['ffmpeg','-v','error','-f','f32le','-ar',str(SR),'-ac','1','-i','pipe:0','-af',','.join(filters),'-f','f32le','pipe:1'],input=x.astype('<f4').tobytes(),capture_output=True,check=True)
  x=np.frombuffer(result.stdout,dtype='<f4').astype(float)
 x=x[:round(limit*SR)]
 return x,dict(trim_start_seconds=first/SR,aligned_seconds=before,tempo_factor=max(1,before/limit))

def pcm(signal,peak):
 y=np.asarray(signal,dtype=float).copy()
 if y.ndim==1:y-=y.mean()
 else:y-=y.mean(axis=0)
 fade=min(128,len(y)//4)
 edge=np.linspace(0,1,fade)
 y[:fade]*=edge if y.ndim==1 else edge[:,None]
 y[-fade:]*=edge[::-1] if y.ndim==1 else edge[::-1,None]
 maximum=float(np.max(abs(y)));assert maximum>.00001
 y*=peak/maximum
 y[0]=0;y[-1]=0
 return np.round(y*32767).astype('<i2')

def write(path,signal,channels=1):
 with wave.open(str(path),'wb') as f:
  f.setparams((channels,2,SR,0,'NONE','not compressed'));f.writeframes(signal.tobytes())

def main():
 parser=argparse.ArgumentParser()
 parser.add_argument('artifact',type=Path)
 parser.add_argument('--request',type=Path,required=True)
 parser.add_argument('--run-url',required=True)
 args=parser.parse_args()
 report=json.loads((args.artifact/'report.json').read_text())
 assert report['provider']=='ElevenLabs' and report['status']=='complete'
 receipts={x['asset']:x for x in report['results']}
 manifest=json.loads((ROOT/'art/audio/manifest.json').read_text())
 names={f.removesuffix('.wav') for c in manifest['cues'].values() for f in c['files']}
 assert set(receipts)==names|{'forest_air'}
 for name,receipt in receipts.items():
  raw=args.artifact/(name+'.mp3')
  assert receipt['state']=='generated' and receipt['http_status']==200
  assert hashlib.sha256(raw.read_bytes()).hexdigest()==receipt['sha256']
 provenance={'provider':'ElevenLabs','model':report['model'],'method':'ElevenLabs Text to Sound v2. Provider MP3 normalized and aligned for runtime; no procedural synthesis fallback.','batch':report['batch'],'workflow_run':args.run_url,'sample_rate':SR,'files':[]}
 with tempfile.TemporaryDirectory(prefix='eleven-import-') as temp:
  staging=Path(temp)
  for name in sorted(names):
   source=args.artifact/(name+'.mp3')
   y,processing=align(decode(source),LIMITS[name])
   samples=pcm(y,.67)
   write(staging/(name+'.wav'),samples)
   values=samples.astype(float)/32768
   provenance['files'].append({'file':name+'.wav','raw_file':'elevenlabs/raw/'+name+'.mp3','raw_sha256':receipts[name]['sha256'],'sha256':hashlib.sha256((staging/(name+'.wav')).read_bytes()).hexdigest(),'duration':len(samples)/SR,'peak_db':round(20*math.log10(np.max(abs(values))),3),'rms_db':round(20*math.log10(np.sqrt(np.mean(values*values))),3),'processing':processing})
  air=decode(args.artifact/'forest_air.mp3',2).reshape(-1,2)
  air_samples=pcm(air,.2)
  write(staging/'air.wav',air_samples,2)
  subprocess.run(['ffmpeg','-y','-v','error','-i',str(staging/'air.wav'),'-c:a','libvorbis','-q:a','3',str(staging/'forest_air.ogg')],check=True)
  target=ROOT/'art/audio'
  raw_dir=target/'elevenlabs/raw';raw_dir.mkdir(parents=True,exist_ok=True)
  # No runtime files are touched before every provider file verifies and converts.
  for name in receipts:shutil.copy2(args.artifact/(name+'.mp3'),raw_dir/(name+'.mp3'))
  for name in names:shutil.copy2(staging/(name+'.wav'),target/(name+'.wav'))
  shutil.copy2(staging/'forest_air.ogg',target/'forest_air.ogg')
  shutil.copy2(args.artifact/'report.json',target/'elevenlabs/receipt.json')
  shutil.copy2(args.request,target/'elevenlabs/request.json')
  manifest['provider']='ElevenLabs'
  manifest['provider_model']=report['model']
  (target/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
  provenance['ambience']={'file':'forest_air.ogg','raw_file':'elevenlabs/raw/forest_air.mp3','raw_sha256':receipts['forest_air']['sha256'],'sha256':hashlib.sha256((target/'forest_air.ogg').read_bytes()).hexdigest(),'duration':len(air)/SR,'loop_requested':True}
  (target/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
 print(f'Imported {len(names)} ElevenLabs SFX and provider-generated forest ambience; raw sources and HTTP receipts retained.')

if __name__=='__main__':main()
