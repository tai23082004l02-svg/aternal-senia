"""Authored SVG frames with shared canvas, foot anchor and weapon socket. No rig."""
from pathlib import Path
import json, math
P=Path(__file__).resolve().parents[1]/'art';P.mkdir(exist_ok=True)
def svg(path,body,w=192,h=240):
 (P/path).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{body}</svg>')
manifest={'canvas':[192,240],'anchor':[96,216],'heroes':{}}
colors={'eira':('#e4e9ff','#6478b8','#b7c9f1'),'ryn':('#492f3f','#aa4c48','#ecae83'),'mira':('#c1ece7','#337b87','#7ed8ce')}
frames={'idle':[.18]*4,'run':[.085]*6,'attack':[.09,.10,.06,.08,.10,.17],'skill':[.12,.13,.12,.13,.16,.24],'hurt':[.13,.13],'death':[.12,.14,.18,1.0]}
for hero,(hair,coat,edge) in colors.items():
 if hero=="ryn":continue # Retired SVG design; Ryn now uses its authored PNG atlas.
 clips={}
 for state,durations in frames.items():
  entries=[]
  for i,duration in enumerate(durations):
   lean=([0,0,0,0][i] if state=='idle' else [0,-2,0,2,0,-2][i%6])
   dx=([0,-5,8,14,8,0][i] if state=='attack' else 0)
   hand=([130,130,143,152,140,130][i] if state in ['attack','skill'] else 131)
   hy=([130,90,100,143,145,130][i] if state in ['attack','skill'] else 132+lean)
   angle=([-12,-85,-30,75,45,-12][i] if state in ['attack','skill'] else 18)
   leg=([0,9,13,0,-9,-13][i] if state=='run' else 0)
   opacity='.45' if state=='death' and i==3 else '1'
   transform=f'translate(0,{[0,0,15,25][i]}) translate(96,140) rotate({[0,-12,-40,-72][i]}) scale({[1,.9,.75,.65][i]}) translate(-96,-140)' if state=='death' else f'translate({dx},{lean})'
   if state=='hurt':transform='rotate(-9,96,210)'
   b=f'''<g opacity="{opacity}" transform="{transform}" stroke="#202d46" stroke-width="3" stroke-linejoin="round">
   <path d="M64 96 Q32 122 {48-leg} 184 L80 170 L92 108" fill="{coat}"/>
   <path d="M86 161 L{79+leg} 207 L{61+leg} 216 L{84+leg} 216 L101 169 M105 162 L{115-leg} 207 L{109-leg} 216 L{130-leg} 216 L121 163" fill="#30334c"/>
   <path d="M64 107 Q94 91 122 107 L132 153 L115 165 L130 181 Q96 191 60 180 L76 153 Z" fill="{coat}"/>
   <path d="M82 105 L96 139 L109 105 L116 150 L77 150 Z" fill="#e9e3d5"/>
   <path d="M75 151 L122 151 L121 162 L75 162 Z" fill="#33344a"/><path d="M94 151 L106 151 L106 162 L94 162 Z" fill="#d7b87c"/>
   <path d="M72 110 L60 138 L69 158 L80 145 L85 120" fill="{edge}"/>
   <path d="M119 111 Q133 113 {hand} {hy} L{hand-10} {hy+6} L109 131" fill="{edge}"/>
   <circle cx="{hand-3}" cy="{hy}" r="7" fill="#f3d8c5"/>
   <path d="M61 78 Q55 33 94 30 Q133 29 137 74 L131 121 L118 103 L70 109 L60 123 Z" fill="{hair}"/>
   <ellipse cx="96" cy="75" rx="30" ry="33" fill="#f3d8c5"/>
   <path d="M64 77 Q55 30 97 30 Q132 30 132 65 L114 51 L108 73 L97 53 L87 72 L77 56 L68 83 Z" fill="{hair}"/>
   <path d="M76 86 Q82 83 87 86 M106 86 Q111 83 117 86" fill="none" stroke-width="2"/>
   <ellipse cx="83" cy="80" rx="4" ry="7" fill="{coat}" stroke="none"/><ellipse cx="111" cy="80" rx="4" ry="7" fill="{coat}" stroke="none"/>
   <circle cx="84" cy="78" r="1.5" fill="white" stroke="none"/><circle cx="112" cy="78" r="1.5" fill="white" stroke="none"/>
   <path d="M91 96 Q97 100 102 95" fill="none" stroke="#ad7c7e" stroke-width="2"/>
   <path d="M61 61 L53 49 L70 48 L72 35 L83 47 L70 61 Z" fill="#dabc7d"/>
   <path d="M78 168 L70 180 M116 166 L122 179" stroke="#dabc7d" stroke-width="2"/>
   </g>'''
   if hero=='mira':
    b=b.replace('</g>', '<path d="M56 49 L97 8 L130 46 L148 54 Q99 68 46 53 Z" fill="#337b87" stroke="#202d46" stroke-width="3"/><path d="M92 34 L104 35 L107 47 L95 49 Z" fill="#e5c68c"/></g>')
   elif hero=='ryn':
    b=b.replace('</g>', '<path d="M127 51 Q161 25 157 86 L137 111 L140 63 Z" fill="#492f3f"/><path d="M66 108 L81 112 L77 135 L59 127 Z M113 108 L129 116 L132 133 L113 129 Z" fill="#d8b47e"/><path d="M131 53 L142 62" stroke="#e4bd7c" stroke-width="7"/></g>')
   name=f'{hero}_{state}_{i}.svg';svg(name,b)
   hx,hy_socket=hand-3+dx,hy+lean
   if state=='hurt':
    a=math.radians(-9);x,y=hx-96,hy_socket-210
    hx,hy_socket=96+x*math.cos(a)-y*math.sin(a),210+x*math.sin(a)+y*math.cos(a)
    angle-=9
   entries.append({'file':name,'duration':duration,'hand':[hx,hy_socket],'angle':angle})
  clips[state]={'loop':state in ['idle','run'],'frames':entries}
 manifest['heroes'][hero]=clips
for category in ['sword','spear','staff']:
 for rank in [1,2]:
  glow='#f3d18b' if rank==2 else '#9bdde4'
  if category=='sword':
   body=f'<path d="M32 128 L22 111 L25 34 L32 8 L39 34 L42 111 Z" fill="{glow}" stroke="#23354b" stroke-width="3"/><path d="M32 20 L32 109" stroke="#f0fbff" stroke-width="3"/><path d="M13 116 L51 116 L46 125 L18 125 Z" fill="#d2b274"/><path d="M28 125 L36 125 L36 149 L28 149 Z" fill="#555075"/>'
  elif category=='spear':
   body=f'<path d="M29 153 L35 153 L35 45 L29 45 Z" fill="#a4836b" stroke="#23354b" stroke-width="2"/><path d="M32 1 L46 30 L32 63 L18 30 Z" fill="{glow}" stroke="#23354b" stroke-width="3"/><path d="M15 61 Q32 77 49 61 L40 83 L32 77 L24 83 Z" fill="#c68269"/>'
  else:
   body=f'<path d="M29 153 L35 153 L38 54 L26 54 Z" fill="#b8aa8c" stroke="#23354b" stroke-width="3"/><path d="M32 11 Q1 33 22 54 L42 54 Q65 33 32 11 Z" fill="none" stroke="#d8bb85" stroke-width="7"/><path d="M32 20 L43 37 L32 52 L21 37 Z" fill="{glow}" stroke="#ecf9ff" stroke-width="2"/>'
  svg(f'{category}_{rank}.svg',body,64,160)
for id,color in [('slime','#8697c5'),('wolf','#8aa6ad'),('golem','#97ae94'),('guardian','#d8ab79'),('bird','#ab9dc9')]:
 if id=='slime':b=f'<path d="M18 188 Q21 96 96 112 Q167 83 176 190 Q151 223 40 214 Z" fill="{color}"/><path d="M45 150 Q68 124 82 131" stroke="#e3edeb" stroke-width="9" fill="none"/>'
 elif id=='wolf':b=f'<path d="M25 208 L36 129 L30 66 L71 100 L120 98 L161 62 L154 133 L170 208 L138 207 L127 160 L70 160 L59 209 Z" fill="{color}"/><path d="M62 113 L96 135 L133 113 L122 156 L96 175 L72 156 Z" fill="#d8dbce"/>'
 elif id=='bird':b=f'<path d="M93 98 Q38 36 8 117 L73 147 L50 197 L95 174 L140 197 L119 147 L183 117 Q158 35 103 98 Z" fill="{color}"/><path d="M83 105 L96 72 L111 105 L96 146 Z" fill="#efe5c8"/>'
 else:b=f'<path d="M58 89 L40 119 L18 171 L47 185 L65 157 L59 216 L88 216 L96 178 L106 216 L139 216 L129 155 L153 184 L180 167 L150 112 L130 88 Z" fill="{color}"/><path d="M70 46 L121 46 L140 81 L124 112 L69 112 L51 81 Z" fill="{color}"/><path d="M96 121 L112 143 L96 165 L80 143 Z" fill="#f5d296"/>'
 b=f'<g stroke="#263648" stroke-width="4" stroke-linejoin="round">{b}<path d="M66 139 L81 142 M112 142 L129 139" stroke="#233047" stroke-width="5"/></g>'
 svg(f'enemy_{id}.svg',b)
for zone,color in [('forest','#1c414a'),('ruins','#4b3947'),('lake','#244958'),('mountain','#343a58'),('tower','#3d3d54')]:
 b=f'<defs><linearGradient id="sky" x2="0" y2="1"><stop stop-color="#101b32"/><stop offset="1" stop-color="{color}"/></linearGradient></defs><path fill="url(#sky)" d="M0 0H540V390H0Z"/><circle cx="415" cy="67" r="36" fill="#dfdec1" opacity=".85"/><circle cx="401" cy="59" r="34" fill="#23374b"/>'
 for j in range(10):
  x=j*66-30; y=130+(j%3)*22
  if zone in ['forest','lake']:
   b+=f'<path d="M{x} 332 L{x+18} {y} L{x+35} 332 Z" fill="#19353f"/><path d="M{x+26} {y-30} L{x-26} {y+95} L{x+72} {y+80} Z" fill="#274d51"/>'
  else:b+=f'<path d="M{x} 340 V{y} H{x+33} V340Z" fill="#252f44"/><path d="M{x-7} {y} H{x+40} V{y+10} H{x-7}Z" fill="#455261"/>'
 b+='<path d="M0 320 Q135 290 270 322 T540 315 V390 H0Z" fill="#203b43"/><path d="M0 349 Q160 328 340 350 T540 345" fill="none" stroke="#688781" stroke-width="2" opacity=".5"/>'
 for j in range(28):
  x=(j*117)%540;y=65+(j*73)%260
  b+=f'<circle cx="{x}" cy="{y}" r="1.5" fill="#b3d6c0" opacity=".5"/>'
 svg(f'bg_{zone}.svg',b,540,390)
(P/'clips.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Authored',len(list(P.glob('*.svg'))),'SVG assets; stable foot anchor [96,216].')
