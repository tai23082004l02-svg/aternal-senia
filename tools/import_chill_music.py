"""Verify and loop already-generated ElevenLabs Music; never calls an API."""
from pathlib import Path
import argparse, hashlib, json, shutil, subprocess, tempfile
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RATE = 44100

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('artifact',type=Path)
    parser.add_argument('--request',required=True,type=Path)
    parser.add_argument('--run-url',required=True)
    args = parser.parse_args()
    receipt = json.loads((args.artifact/'report.json').read_text())
    request = json.loads(args.request.read_text())
    assert receipt['status']=='complete' and receipt['provider']=='ElevenLabs'
    assert receipt['batch']==request['id'] and len(receipt['results'])==1 and len(request['assets'])==1
    row = receipt['results'][0]
    assert row['asset']=='moonlit_rest' and row['http_status']==200 and row['state']=='generated' and row['model']=='music_v1'
    source = args.artifact/'moonlit_rest.mp3'
    assert hashlib.sha256(source.read_bytes()).hexdigest()==row['sha256']
    result = subprocess.run(['ffmpeg','-v','error','-i',str(source),'-ar',str(RATE),'-ac','2','-f','f32le','pipe:1'],capture_output=True,check=True)
    audio = np.frombuffer(result.stdout,dtype='<f4').reshape(-1,2).astype(float)
    assert len(audio)/RATE > 55 and np.isfinite(audio).all() and np.max(abs(audio))>.001
    audio -= audio.mean(axis=0)
    crossfade = 3*RATE
    phase = np.linspace(0,np.pi/2,crossfade)[:,None]
    seam = audio[-crossfade:]*np.cos(phase)+audio[:crossfade]*np.sin(phase)
    loop = np.concatenate([audio[crossfade:-crossfade],seam]).astype('<f4')
    target = ROOT/'art/audio'
    with tempfile.TemporaryDirectory(prefix='music-loop-') as folder:
        staging = Path(folder)/'moonlit_rest.ogg'
        subprocess.run(['ffmpeg','-v','error','-f','f32le','-ar',str(RATE),'-ac','2','-i','pipe:0',
                        '-af','loudnorm=I=-20:TP=-3:LRA=7','-ar',str(RATE),'-c:a','libvorbis','-q:a','4',str(staging)],input=loop.tobytes(),check=True)
        raw = target/'elevenlabs/music-v1/raw'
        raw.mkdir(parents=True,exist_ok=True)
        shutil.copy2(source,raw/source.name)
        shutil.copy2(args.artifact/'report.json',raw.parent/'receipt.json')
        shutil.copy2(args.request,raw.parent/'request.json')
        shutil.copy2(staging,target/staging.name)
    manifest = json.loads((target/'manifest.json').read_text())
    manifest['music'] = dict(file='moonlit_rest.ogg',title='Moonlit Rest',gain_db=-4,loop=True)
    (target/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    provenance = json.loads((target/'provenance.json').read_text())
    provenance['music'] = dict(file='moonlit_rest.ogg',provider='ElevenLabs',model='music_v1',batch=receipt['batch'],
                              raw_file='elevenlabs/music-v1/raw/moonlit_rest.mp3',raw_sha256=row['sha256'],
                              sha256=hashlib.sha256((target/'moonlit_rest.ogg').read_bytes()).hexdigest(),
                              receipt='elevenlabs/music-v1/receipt.json',workflow_run=args.run_url,
                              requested_seconds=60,duration=len(loop)/RATE,force_instrumental=True,
                              processing='3s equal-power tail/head overlap, DC removal, loudnorm I=-20 TP=-3 LRA=7, stereo Vorbis44100Hz q4')
    (target/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
    print('Imported original Music source and verified receipt; runtime loop %.3fs' % (len(loop)/RATE))

if __name__=='__main__':
    main()
