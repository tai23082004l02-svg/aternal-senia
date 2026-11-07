"""Import verified v2 ElevenLabs SFX; preserves partial Music failure receipt.
No API calls or credentials. Uses the existing provider-audio postprocessing.
"""
from pathlib import Path
import argparse, hashlib, json, shutil, tempfile
from import_elevenlabs_audio import ROOT, SR, align, decode, pcm, write

LIMITS = dict(menu_open=.24, menu_back=.20, quest_claim=1.1, summon_reveal=1.4,
              rarity_reveal=1.8, equipment_fuse=1.1, dismantle=.65, spirit_select=.7)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('artifact', type=Path)
    parser.add_argument('--request', required=True, type=Path)
    parser.add_argument('--run-url', required=True)
    args = parser.parse_args()
    receipt = json.loads((args.artifact/'report.json').read_text())
    request = json.loads(args.request.read_text())
    assert receipt['provider'] == 'ElevenLabs' and receipt['batch'] == request['id']
    rows = {row['asset']: row for row in receipt['results']}
    assert set(rows) == set(LIMITS)|{'moonlit_rest'}
    for name in LIMITS:
        row = rows[name]
        assert row['http_status'] == 200 and row['state'] == 'generated'
        assert row['model'] == 'eleven_text_to_sound_v2'
        assert hashlib.sha256((args.artifact/(name+'.mp3')).read_bytes()).hexdigest() == row['sha256']
    audio = ROOT/'art/audio'
    manifest = json.loads((audio/'manifest.json').read_text())
    provenance = json.loads((audio/'provenance.json').read_text())
    with tempfile.TemporaryDirectory(prefix='audio-v2-') as folder:
        staging = Path(folder)
        entries = []
        for name, limit in LIMITS.items():
            y, processing = align(decode(args.artifact/(name+'.mp3')), limit)
            samples = pcm(y, .60)
            write(staging/(name+'.wav'), samples)
            entries.append(dict(file=name+'.wav', raw_file='elevenlabs/v2/raw/'+name+'.mp3',
                                raw_sha256=rows[name]['sha256'], sha256=hashlib.sha256((staging/(name+'.wav')).read_bytes()).hexdigest(),
                                duration=len(samples)/SR, processing=processing, batch=receipt['batch'],
                                receipt='elevenlabs/v2/receipt.json', workflow_run=args.run_url))
        raw = audio/'elevenlabs/v2/raw'
        raw.mkdir(parents=True, exist_ok=True)
        for name in LIMITS:
            shutil.copy2(args.artifact/(name+'.mp3'),raw/(name+'.mp3'))
            shutil.copy2(staging/(name+'.wav'),audio/(name+'.wav'))
            manifest['cues'][name] = dict(files=[name+'.wav'],gain_db=-16 if name.startswith('menu_') else -12,
                                         priority=3, max_instances=1, cooldown=.12 if name.startswith('menu_') else .3,
                                         pitch_variation=0, bus='ui')
        shutil.copy2(args.artifact/'report.json',audio/'elevenlabs/v2/receipt.json')
        shutil.copy2(args.request,audio/'elevenlabs/v2/request.json')
        provenance['files'] = [row for row in provenance['files'] if row['file'] not in {e['file'] for e in entries}]+entries
        provenance['additional_batches'] = [dict(id=receipt['batch'],workflow_run=args.run_url,
                                               generated_sfx=8,music_state=rows['moonlit_rest']['state'],
                                               music_diagnostic=rows['moonlit_rest'].get('diagnostic',''))]
        (audio/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
        (audio/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
    print('Imported8 verified ElevenLabs SFX; preserved original raw bytes/partial receipt. No Music asset imported.')

if __name__ == '__main__':
    main()
