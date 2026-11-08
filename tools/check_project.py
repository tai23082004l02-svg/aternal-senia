"""Run isolated Godot suites. Generated evidence stays under ignored work/checks."""
from pathlib import Path
import argparse,json,os,re,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
work=ROOT/'work/checks'
work.mkdir(parents=True,exist_ok=True)
tests=['arena_tactics','arena_battle','arena_ui','admin_unlock','admin_unlock_ui','selena_ui','character_previews','caelan','caelan_ui','ui_design_v2','hero_contract','collection_ui','english_ui','audio_capture','settings','settings_audio','settings_ui','additional_audio','player_profile','utilities_ui','team_matrix','team_campaign','shop_ui','additional_equipment','additional_equipment_ui','supplies','supplies_ui','dungeon_world','mobile_inventory','swipe_scroll','ui_flow','animation_gallery','bag_ui','character_design','music','audio','team_ui','formation_layout','team_flow','regression','mechanics','campaign','team_battle','complete_art','summon_ui','summon_batch','recruitment','bag_inventory','unique_collection','unique_collection_ui','equipment_sets','equipment_ui','hero_management','icon_gallery']
headless={'arena_tactics','arena_battle','admin_unlock','caelan','hero_contract','settings','team_matrix','team_campaign','additional_equipment','regression','mechanics','campaign','team_battle','complete_art','summon_batch','recruitment','supplies','bag_inventory','unique_collection','equipment_sets','hero_management'}
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--tests',nargs='+',help='Run named tests instead of the default51 suites')
parser.add_argument('--timeout',type=int,default=75,help='Per-suite limit in seconds')
parser.add_argument('--emit-reviews',action='store_true',help='Print base64 review frames to CI logs')
args=parser.parse_args()
if args.tests:tests=args.tests
for name in tests:
    if not re.fullmatch(r'[a-z0-9_]+',name) or not (ROOT/'tests'/(name+'.gd')).is_file():
        parser.error('Unknown test: '+name)
if args.timeout < 1:parser.error('--timeout must be positive')
(work/'.gdignore').touch()
results=[]
for test in tests:
    env=os.environ.copy()
    output=work/test
    output.mkdir(parents=True,exist_ok=True)
    env['FIRST_LIGHT_CAPTURE_DIR']=str(output)
    command=['godot','--audio-driver','Dummy','--path',str(ROOT),'--script','tests/'+test+'.gd']
    if test in headless:command.insert(1,'--headless')
    try:
        run=subprocess.run(command,cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=args.timeout)
        text=(run.stdout or '')+(run.stderr or '')
        ok=run.returncode==0 and 'PASS' in text and 'SCRIPT ERROR' not in text and 'Parse Error' not in text
    except subprocess.TimeoutExpired as error:
        text=(error.stdout or b'').decode(errors='replace') if isinstance(error.stdout,bytes) else (error.stdout or '')
        ok=False
    (work/(test+'.log')).write_text(text)
    results.append(dict(test=test,passed=ok))
    print(test+': '+('PASS' if ok else 'FAIL'),flush=True)
    if args.emit_reviews and test in ['supplies_ui','dungeon_world']:
        for line in text.splitlines():
            if line.startswith(('SUPPLIES_REVIEW:','DUNGEON_REVIEW:')):print(line,flush=True)
    if not ok:print(text[-6000:],flush=True)
(work/'results.json').write_text(json.dumps(dict(engine=subprocess.check_output(['godot','--version'],text=True).strip(),display='Xvfb/X11',tests=results),indent=2)+'\n')
if not all(row['passed'] for row in results):sys.exit(1)
