"""Signal/manifest checks; this is not a substitute for human listening."""
from pathlib import Path
import argparse,json,math,wave,hashlib
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--capture',type=Path);args=p.parse_args()
manifest=json.loads((ROOT/'art/audio/manifest.json').read_text())
files={name for cue in manifest['cues'].values() for name in cue['files']}
assert files=={x.name for x in (ROOT/'art/audio').glob('*.wav')}
for name in sorted(files):
 with wave.open(str(ROOT/'art/audio'/name),'rb') as f:
  assert f.getnchannels()==1 and f.getsampwidth()==2 and f.getframerate()==32000
  y=np.frombuffer(f.readframes(f.getnframes()),dtype='<i2').astype(float)/32768
 assert np.isfinite(y).all() and len(y)>100
 assert 0.15<np.max(abs(y))<.70, name
 assert abs(np.mean(y))<.001, name
 assert y[0]==0 and y[-1]==0, name
 assert np.any(abs(y)>.01), name
 onset=np.argmax(abs(y)>.01)/32000
 assert onset<.035, (name,onset)
provenance=json.loads((ROOT/'art/audio/provenance.json').read_text())
if provenance.get('provider')=='ElevenLabs':
 receipt=json.loads((ROOT/'art/audio/elevenlabs/receipt.json').read_text())
 assert receipt['provider']=='ElevenLabs' and receipt['status']=='complete'
 assert len(receipt['results'])==39 and all(x['http_status']==200 and x['state']=='generated' for x in receipt['results'])
 assert manifest.get('provider')=='ElevenLabs'
 for entry in provenance['files']+[provenance['ambience']]:
  assert hashlib.sha256((ROOT/'art/audio'/entry['raw_file']).read_bytes()).hexdigest()==entry['raw_sha256']
  assert hashlib.sha256((ROOT/'art/audio'/entry['file']).read_bytes()).hexdigest()==entry['sha256']
print(f"PASS: {len(files)} runtime waveforms ({provenance.get('provider','prototype')}), manifest, headroom, DC, fades, onset and raw-source receipts")
if args.capture:
 with wave.open(str(args.capture),'rb') as f:
  y=np.frombuffer(f.readframes(f.getnframes()),dtype='<i2').astype(float)/32768
  rate=f.getframerate();channels=f.getnchannels();duration=f.getnframes()/rate
 peak=float(np.max(abs(y)));rms=float(np.sqrt(np.mean(y*y)))
 assert peak>.05 and peak<.95 and rms>.001
 assert np.sum(abs(y)>=.999)==0
 trace_path=args.capture.with_name('audio-trace.json')
 trace=json.loads(trace_path.read_text())
 assert trace['max_voices']<=12
 assert len({(e['run'],e['id']) for e in trace['events']})==len(trace['events'])
 cues={e['cue'] for e in trace['events']}
 assert {'stage_start','cast','burst','swing_sword','impact_sword','boss_arrive','victory'}<=cues
 print(json.dumps(dict(duration=duration,sample_rate=rate,channels=channels,peak_dbfs=round(20*math.log10(peak),3),rms_dbfs=round(20*math.log10(rms),3),clipped_samples=0,max_voices=trace['max_voices'],dropped=trace['dropped']),indent=2))
