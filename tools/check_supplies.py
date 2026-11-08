"""Run isolated Godot checks and retain render evidence; used by the UI workflow."""
from pathlib import Path
import json,os,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
work=ROOT/'work/supplies-check'
work.mkdir(parents=True,exist_ok=True)
tests=['supplies','supplies_ui','dungeon_world','mobile_inventory','swipe_scroll','ui_flow','animation_gallery','bag_ui','character_design','music','audio','team_ui','team_flow','regression','mechanics','campaign','team_battle','complete_art','summon_ui','summon_batch','recruitment','bag_inventory','unique_collection','unique_collection_ui','equipment_sets','equipment_ui','hero_management','icon_gallery']
headless={'regression','mechanics','campaign','team_battle','complete_art','summon_batch','recruitment','supplies','bag_inventory','unique_collection','equipment_sets','hero_management'}
results=[]
for test in tests:
    env=os.environ.copy()
    output=ROOT/'docs/previews/supplies' if test=='supplies_ui' else work/test
    output.mkdir(parents=True,exist_ok=True)
    env['FIRST_LIGHT_CAPTURE_DIR']=str(output)
    command=['godot','--audio-driver','Dummy','--path',str(ROOT),'--script','tests/'+test+'.gd']
    if test in headless:command.insert(1,'--headless')
    try:
        run=subprocess.run(command,cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=35)
        text=(run.stdout or '')+(run.stderr or '')
        ok=run.returncode==0 and 'PASS' in text and 'SCRIPT ERROR' not in text and 'Parse Error' not in text
    except subprocess.TimeoutExpired as error:
        text=(error.stdout or b'').decode(errors='replace') if isinstance(error.stdout,bytes) else (error.stdout or '')
        ok=False
    (work/(test+'.log')).write_text(text)
    results.append(dict(test=test,passed=ok))
    print(test+': '+('PASS' if ok else 'FAIL'),flush=True)
    if test=='supplies_ui':
        for line in text.splitlines():
            if line.startswith('SUPPLIES_REVIEW:'):print(line,flush=True)
    if not ok:print(text[-6000:],flush=True)
(work/'results.json').write_text(json.dumps(dict(engine=subprocess.check_output(['godot','--version'],text=True).strip(),display='Xvfb/X11',tests=results),indent=2)+'\n')
if not all(row['passed'] for row in results):sys.exit(1)
