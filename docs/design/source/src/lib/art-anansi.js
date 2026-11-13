// Code-drawn concept art: How Wisdom Became the Property of the Human Race (Anansi; Akan people, Ghana).
// Kente-inspired stripes and an Adinkra-inspired web mark (after Ananse Ntontan, "spider's web": wisdom, creativity)
// are simplified concept drawings; final art must be made/reviewed with Akan cultural advisers.
OMDEF('./art-anansi', function (require, module) {
const { rng, f1, grainDefs, grainRect } = require('./base');

const SKIN = '#7A4A30', SKIN_D = '#55301F', SKIN_L = '#9A6040';
const K = { gold: '#F7B520', green: '#128A4E', red: '#D8342B', black: '#17121F', blue: '#1F4FA8' };

// kente-inspired woven strip (pattern unit 48 x 24)
function kentePattern(id = 'kente', s = 1) {
  return `<pattern id="${id}" width="${48 * s}" height="${24 * s}" patternUnits="userSpaceOnUse" patternTransform="scale(${s})">
  <rect width="48" height="24" fill="${K.gold}"/>
  <rect x="0" y="0" width="12" height="24" fill="${K.green}"/><rect x="2" y="3" width="8" height="3" fill="${K.gold}"/><rect x="2" y="10.500" width="8" height="3" fill="${K.red}"/><rect x="2" y="18" width="8" height="3" fill="${K.gold}"/>
  <rect x="12" y="0" width="4" height="24" fill="${K.black}"/>
  <path d="M16,0h12v6h-12zM16,12h12v6h-12z" fill="${K.red}"/><path d="M16,6h6v6h-6zM22,18h6v6h-6z" fill="${K.black}"/>
  <rect x="28" y="0" width="4" height="24" fill="${K.black}"/>
  <rect x="32" y="0" width="16" height="24" fill="${K.gold}"/><path d="M34,2h12v4h-12zM34,10h12v4h-12zM34,18h12v4h-12z" fill="${K.green}" opacity=".9"/><path d="M38,2h4v20h-4z" fill="${K.red}"/>
  </pattern>`;
}
// Adinkra-inspired web mark (simplified Ananse Ntontan): hub + 8 spokes with rings
function webMark(x, y, r, c = '#FFD25A', sw = 0.11) {
  let s = `<circle cx="${x}" cy="${y}" r="${f1(r * .2)}" fill="${c}"/>`;
  for (let i = 0; i < 8; i++) { const a = i * Math.PI / 4; s += `<path d="M${f1(x + Math.cos(a) * r * .28)},${f1(y + Math.sin(a) * r * .28)} L${f1(x + Math.cos(a) * r)},${f1(y + Math.sin(a) * r)}" stroke="${c}" stroke-width="${f1(r * sw)}" stroke-linecap="round"/>`; }
  s += `<circle cx="${x}" cy="${y}" r="${f1(r * .62)}" fill="none" stroke="${c}" stroke-width="${f1(r * sw * .9)}"/>`;
  return s;
}
// the wisdom pot (clay, glowing from inside)
function pot(x, y, s = 1, id = 'pot', glow = true) {
  return `<g transform="translate(${x},${y}) scale(${s})">
  ${glow ? `<circle r="46" fill="url(#${id}glow)"/>` : ''}
  <path d="M-11,-17 C-13,-21 -12,-24 -9,-24 L9,-24 C12,-24 13,-21 11,-17 C20,-12 22,-2 20,6 C17,17 9,21 0,21 C-9,21 -17,17 -20,6 C-22,-2 -20,-12 -11,-17Z" fill="url(#${id}clay)"/>
  <path d="M-11,-17 C-4,-14 4,-14 11,-17" stroke="#7A2E18" stroke-width="1.600" fill="none"/>
  <ellipse cx="0" cy="-24" rx="9.600" ry="2.600" fill="#3A160E"/><ellipse cx="0" cy="-24" rx="7.500" ry="1.800" fill="#FFE27A"/>
  <path d="M-19,-2 C-8,2 8,2 19,-2 M-20,5 C-8,9 8,9 20,5" stroke="#FFD25A" stroke-width="1.500" fill="none" opacity=".9"/>
  <path d="M-15,1.500 l3,3.500 l3,-3.200 l3,3.400 l3,-3.400 l3,3.400 l3,-3.400 l3,3.200 l3,-3.500" stroke="#3A160E" stroke-width="1.100" fill="none" opacity=".7"/>
  ${webMark(0, 13, 5.5, '#FFD25A', .16)}
  <path d="M-15,-8 C-17,-2 -17,6 -13,12" stroke="#FFB07A" stroke-width="2.400" fill="none" opacity=".55" stroke-linecap="round"/>
  </g>`;
}
function potDefs(id = 'pot') {
  return `<radialGradient id="${id}glow"><stop offset="0" stop-color="#FFE27A" stop-opacity=".85"/><stop offset=".4" stop-color="#FFB93D" stop-opacity=".35"/><stop offset="1" stop-color="#FFB93D" stop-opacity="0"/></radialGradient>
  <radialGradient id="${id}clay" cx=".35" cy=".3" r=".9"><stop offset="0" stop-color="#F08A52"/><stop offset=".55" stop-color="#C7562E"/><stop offset="1" stop-color="#7A2E18"/></radialGradient>`;
}
const limb = (d, w, c) => `<path d="${d}" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;

// Father Anansi climbing (profile, facing right; origin = hip; trunk surface at x≈36)
function anansiClimb({ id = 'an' } = {}) {
  return `<g>
  ${limb('M-2,6 C4,18 16,24 31,25', 9.5, SKIN_D)}<ellipse cx="36" cy="27" rx="7.500" ry="4.500" fill="${SKIN_D}" transform="rotate(62 36 27)"/>
  ${limb('M10,-50 C20,-60 30,-66 40,-68', 8, SKIN_D)}
  <!-- wrapped cloth: body -->
  <path d="M-4,-58 C6,-64 16,-60 18,-52 C22,-36 16,-14 12,2 C8,10 -6,12 -12,4 C-18,-14 -16,-44 -4,-58Z" fill="url(#${id}kente)"/>
  <path d="M-4,-58 C6,-64 16,-60 18,-52 C22,-36 16,-14 12,2 C8,10 -6,12 -12,4 C-18,-14 -16,-44 -4,-58Z" fill="url(#${id}shade)"/>
  <path d="M-10,-52 C-22,-40 -24,-12 -18,10 C-14,16 -8,14 -8,6 C-12,-14 -10,-36 -2,-56Z" fill="url(#${id}kente)"/><path d="M-10,-52 C-22,-40 -24,-12 -18,10 C-14,16 -8,14 -8,6 C-12,-14 -10,-36 -2,-56Z" fill="#17121F" opacity=".35"/>
  ${limb('M2,2 C12,-12 24,-14 32,-6', 11, SKIN)}${limb('M32,-6 C34,-1 34,2 33,5', 9.5, SKIN)}<ellipse cx="36" cy="8" rx="7.500" ry="4.500" fill="${SKIN}" transform="rotate(64 36 8)"/>
  <!-- cord + pot swinging in front -->
  <path d="M8,-58 C14,-48 22,-40 27,-36 M14,-60 C20,-50 26,-42 29,-37" stroke="#E9D9B0" stroke-width="1.300" fill="none"/>
  <g transform="rotate(-10 27 -20)">${pot(27, -14, .8, id + 'pot')}</g>
  ${limb('M12,-52 C20,-50 30,-48 38,-50', 8.5, SKIN)}<circle cx="40" cy="-51" r="5.200" fill="${SKIN}"/><circle cx="42" cy="-69" r="5" fill="${SKIN_D}"/>
  <!-- head -->
  <g transform="translate(6,-76) rotate(-14)">
    <ellipse cx="0" cy="0" rx="14.500" ry="15.500" fill="url(#${id}skin)"/>
    <path d="M-14,-2 C-16,-14 -6,-19 4,-17 C-2,-14 -6,-10 -7,-4 C-8,2 -11,4 -14,-2Z" fill="#F1F1F4"/>
    <path d="M-2,13 C4,17 11,14 13,6 C13,12 10,20 2,20 C-2,20 -4,16 -2,13Z" fill="#F1F1F4"/>
    <ellipse cx="-5" cy="2" rx="3" ry="4" fill="${SKIN_D}"/>
    <ellipse cx="7" cy="-3" rx="3.600" ry="3.200" fill="#fff"/><circle cx="8.400" cy="-3.600" r="1.900" fill="#1B0F0A"/>
    <path d="M2,-8 L11,-9.500" stroke="#F1F1F4" stroke-width="2.200" stroke-linecap="round"/>
    <path d="M14,0 C17,2 17,5 13.500,5" fill="${SKIN}" stroke="${SKIN_D}" stroke-width=".8"/>
    <path d="M6,9 Q10,7.500 13,9.500" stroke="#2B140C" stroke-width="1.600" fill="none" stroke-linecap="round"/>
  </g>
  <path d="M-14,-90 q-3,5 0,8 q3,-3 0,-8Z M-20,-78 q-3,5 0,8 q3,-3 0,-8Z" fill="#BFE6FF" opacity=".9"/>
  </g>`;
}
function anansiDefs(id = 'an') {
  return `${kentePattern(id + 'kente', .5)}${potDefs(id + 'pot')}
  <radialGradient id="${id}skin" cx=".7" cy=".3" r=".9"><stop offset="0" stop-color="${SKIN_L}"/><stop offset="1" stop-color="${SKIN_D}"/></radialGradient>
  <linearGradient id="${id}shade" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#17121F" stop-opacity=".45"/><stop offset=".6" stop-color="#17121F" stop-opacity="0"/><stop offset="1" stop-color="#FFE9A8" stop-opacity=".25"/></linearGradient>`;
}
// Kweku Tsin's face (front view; origin = centre of face). look: pupil offset.
function kwekuHead({ id = 'kw', look = [2, -2.5], mouth = 'smile' } = {}) {
  const eye = (x) => `<ellipse cx="${x}" cy="-1" rx="6.800" ry="7.600" fill="#fff"/><circle cx="${x + look[0]}" cy="${-1 + look[1]}" r="4.300" fill="#24120B"/><circle cx="${x + look[0] - 1.4}" cy="${-2.8 + look[1]}" r="1.500" fill="#fff"/>`;
  return `<g>
  <ellipse cx="-27" cy="2" rx="6" ry="8" fill="${SKIN}"/><ellipse cx="27" cy="2" rx="6" ry="8" fill="${SKIN}"/><ellipse cx="-27" cy="2" rx="3" ry="4.500" fill="${SKIN_D}"/><ellipse cx="27" cy="2" rx="3" ry="4.500" fill="${SKIN_D}"/>
  <ellipse cx="0" cy="0" rx="26" ry="28" fill="url(#${id}skin)"/>
  <path d="M-26,-4 C-28,-26 -12,-34 0,-34 C12,-34 28,-26 26,-4 C22,-16 12,-21 0,-21 C-12,-21 -22,-16 -26,-4Z" fill="#17101C"/>
  ${eye(-10)}${eye(10)}
  <path d="M-16,-12 q6,-4 11,-1 M5,-13 q6,-3 11,1" stroke="#17101C" stroke-width="2" fill="none" stroke-linecap="round"/>
  <path d="M-2.500,8 q2.500,2.400 5,0" stroke="${SKIN_D}" stroke-width="2" fill="none" stroke-linecap="round"/>
  ${mouth === 'oh' ? `<ellipse cx="0" cy="16.500" rx="3.600" ry="4.400" fill="#3A160E"/>` : `<path d="M-7,14.500 Q0,21 8,13.500" stroke="#3A160E" stroke-width="2.200" fill="none" stroke-linecap="round"/>`}
  <ellipse cx="-15" cy="10" rx="4.500" ry="3" fill="#E8674A" opacity=".3"/><ellipse cx="15" cy="10" rx="4.500" ry="3" fill="#E8674A" opacity=".3"/>
  </g>`;
}
const kwekuDefs = (id = 'kw') => `<radialGradient id="${id}skin" cx=".6" cy=".3" r=".9"><stop offset="0" stop-color="${SKIN_L}"/><stop offset="1" stop-color="#65391F"/></radialGradient>`;
// Father Anansi's face (front, for voice chips / small portraits)
function anansiHead({ id = 'ah' } = {}) {
  return `<g>
  <ellipse cx="0" cy="0" rx="26" ry="28" fill="url(#${id}skin)"/>
  <path d="M-26,-2 C-29,-24 -14,-33 0,-33 C14,-33 29,-24 26,-2 C22,-15 12,-20 0,-20 C-12,-20 -22,-15 -26,-2Z" fill="#F1F1F4"/>
  <path d="M-20,12 C-17,27 -8,31 0,31 C8,31 17,27 20,12 C15,21 8,24 0,24 C-8,24 -15,21 -20,12Z" fill="#F1F1F4"/>
  <ellipse cx="-10" cy="-1" rx="5.600" ry="6" fill="#fff"/><circle cx="-9" cy="-1" r="3.600" fill="#24120B"/><ellipse cx="10" cy="-1" rx="5.600" ry="6" fill="#fff"/><circle cx="11" cy="-1" r="3.600" fill="#24120B"/>
  <path d="M-16,-9.500 q5,-2.500 10,0 M16,-9.500 q-5,-2.500 -10,0" stroke="#F1F1F4" stroke-width="2.400" stroke-linecap="round" fill="none"/>
  <path d="M-2.500,8 q2.500,2.400 5,0" stroke="${SKIN_D}" stroke-width="2" fill="none" stroke-linecap="round"/><path d="M-6,15 Q0,19 6,15" stroke="#3A160E" stroke-width="2.200" fill="none" stroke-linecap="round"/>
  </g>`;
}
const faceKweku = (id = 'fk') => `<svg viewBox="-36 -38 72 72"><defs>${kwekuDefs(id)}</defs><rect x="-36" y="-38" width="72" height="72" fill="#F7B520"/><g transform="translate(0,2)">${kwekuHead({ id, look: [0, 0] })}</g></svg>`;
const faceAnansi = (id = 'fa') => `<svg viewBox="-36 -38 72 76"><defs>${kwekuDefs(id)}</defs><rect x="-36" y="-38" width="72" height="76" fill="#D8342B"/>${anansiHead({ id })}</svg>`;

function bigLeaf(x, y, len, ang, c1, c2, rim) {
  return `<g transform="translate(${x},${y}) rotate(${ang})"><path d="M0,0 C${len * .2},${-len * .3} ${len * .7},${-len * .28} ${len},0 C${len * .7},${len * .2} ${len * .2},${len * .22} 0,0Z" fill="${c1}"/><path d="M0,0 C${len * .2},${-len * .3} ${len * .7},${-len * .28} ${len},0 C${len * .6},${-len * .06} ${len * .3},${-len * .04} 0,0Z" fill="${c2}"/><path d="M0,0 Q${len * .5},${-len * .05} ${len},0" stroke="${rim}" stroke-width="1.400" fill="none" opacity=".7"/>${[.25, .42, .58, .74].map(t => `<path d="M${len * t},${-len * .02} l${len * .1},${-len * .14} M${len * t},0 l${len * .1},${len * .1}" stroke="${rim}" stroke-width=".8" opacity=".35"/>`).join('')}</g>`;
}
function umbrellaTree(x, y, h, s, c, seed) {
  const r = rng(seed); let crown = '';
  for (let i = 0; i < 7; i++) crown += `<ellipse cx="${f1(x + (r() - .5) * 90 * s)}" cy="${f1(y - h - 6 * s + (r() - .5) * 18 * s)}" rx="${f1((26 + r() * 22) * s)}" ry="${f1((9 + r() * 8) * s)}" fill="${c}"/>`;
  return `<path d="M${x - 3 * s},${y} C${x - 2 * s},${y - h * .5} ${x - 1 * s},${y - h * .8} ${x - 1.5 * s},${y - h} L${x + 1.5 * s},${y - h} C${x + 1 * s},${y - h * .8} ${x + 2 * s},${y - h * .5} ${x + 4 * s},${y}Z" fill="${c}"/>
  <path d="M${x},${y - h * .8} q${-16 * s},${-10 * s} ${-30 * s},${-h * .2} M${x},${y - h * .72} q${18 * s},${-12 * s} ${34 * s},${-h * .26}" stroke="${c}" stroke-width="${2.2 * s}" fill="none"/>${crown}`;
}
function fireflies(n, seed, box, c = '#FFE27A') {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) { const x = box[0] + r() * box[2], y = box[1] + r() * box[3], rad = 1 + r() * 1.8; s += `<circle cx="${f1(x)}" cy="${f1(y)}" r="${f1(rad * 4.5)}" fill="${c}" opacity="${f1(.1 + r() * .14)}"/><circle cx="${f1(x)}" cy="${f1(y)}" r="${f1(rad)}" fill="#FFF7C8" opacity="${f1(.7 + r() * .3)}"/>`; }
  return s;
}
function stars(n, seed, box) {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) s += `<circle cx="${f1(box[0] + r() * box[2])}" cy="${f1(box[1] + Math.pow(r(), 1.6) * box[3])}" r="${f1(.5 + r() * 1.1)}" fill="#fff" opacity="${f1(.25 + r() * .6)}"/>`;
  return s;
}
function spiderWeb(x, y, r, a0, a1, c = '#fff') {
  let s = ''; const n = 7;
  for (let i = 0; i <= n; i++) { const a = a0 + (a1 - a0) * i / n; s += `<path d="M${x},${y} L${f1(x + Math.cos(a) * r)},${f1(y + Math.sin(a) * r)}" stroke="${c}" stroke-width=".7" opacity=".5"/>`; }
  for (let k = 1; k <= 6; k++) { const rr = r * k / 6.3; let d = ''; for (let i = 0; i <= n; i++) { const a = a0 + (a1 - a0) * i / n; const px = x + Math.cos(a) * rr, py = y + Math.sin(a) * rr; if (i === 0) d += `M${f1(px)},${f1(py)}`; else { const am = a0 + (a1 - a0) * (i - .5) / n; d += ` Q${f1(x + Math.cos(am) * rr * .9)},${f1(y + Math.sin(am) * rr * .9)} ${f1(px)},${f1(py)}`; } } s += `<path d="${d}" fill="none" stroke="${c}" stroke-width=".7" opacity=".45"/>`; }
  return s;
}
function nightCanopy(blobs, seed, pal) {
  const r = rng(seed); let a = '', b = '';
  for (const bl of blobs) {
    a += `<ellipse cx="${bl.x}" cy="${bl.y}" rx="${bl.r}" ry="${f1(bl.r * .62)}" fill="${pal[0]}"/>`;
    const n = Math.round(bl.r * 1.3);
    for (let i = 0; i < n; i++) { const an = r() * 6.283, d = Math.pow(r(), .5) * bl.r * 1.05, x = bl.x + Math.cos(an) * d, y = bl.y + Math.sin(an) * d * .62, sz = 6 + r() * 8, la = r() * 6.283; const lit = (x - bl.x) / bl.r - (y - bl.y) / bl.r; const path = `<ellipse cx="${f1(x)}" cy="${f1(y)}" rx="${f1(sz)}" ry="${f1(sz * .42)}" transform="rotate(${f1(la * 57)} ${f1(x)} ${f1(y)})"`; if (lit + r() * .8 > 1.0) b += `${path} fill="${r() > .7 ? pal[3] : pal[2]}"/>`; else a += `${path} fill="${r() > .5 ? pal[0] : pal[1]}"/>`; }
  }
  return `<g>${a}</g><g>${b}</g>`;
}
function wisdomMotes(pts, c = '#FFD25A') {
  return pts.map(([x, y, s, k]) => k === 0 ? `<circle cx="${x}" cy="${y}" r="${s * 6}" fill="${c}" opacity=".16"/><g opacity=".95">${webMark(x, y, s * 4.2, c, .16)}</g>` : k === 1 ? `<circle cx="${x}" cy="${y}" r="${s * 5}" fill="${c}" opacity=".16"/><path d="M${x},${y - 4 * s} l${1.2 * s},${2.8 * s} l${2.8 * s},${1.2 * s} l${-2.8 * s},${1.2 * s} l${-1.2 * s},${2.8 * s} l${-1.2 * s},${-2.8 * s} l${-2.8 * s},${-1.2 * s} l${2.8 * s},${-1.2 * s}Z" fill="#FFF3C2"/>` : `<circle cx="${x}" cy="${y}" r="${s * 4}" fill="${c}" opacity=".18"/><circle cx="${x}" cy="${y}" r="${s * 1.4}" fill="#FFF3C2"/>`).join('');
}

// Twilight forest in Fanti-land. Left pane upper sky = reading zone (light text on deep indigo).
function forestScene({ w = 892, h = 720, kweku = true } = {}) {
  const pal = ['#10283F', '#16385A', '#2B6A7A', '#8FD0B0'];
  const top = nightCanopy([{ x: 640, y: 30, r: 120 }, { x: 800, y: 40, r: 110 }, { x: 500, y: 20, r: 80 }, { x: 870, y: 120, r: 60 }, { x: 716, y: 92, r: 70 }, { x: 420, y: 34, r: 46 }, { x: 560, y: 84, r: 40 }, { x: 372, y: 18, r: 30 }], 14, pal);
  let far = '';
  [[30, .3], [86, .42], [150, .3], [226, .36], [300, .3], [372, .4], [486, .6], [540, .5], [760, .7], [828, .56], [878, .66]].forEach(([x, s], i) => { far += umbrellaTree(x, 650, 120 * s + 40, s * .8, i % 2 ? '#3A2466' : '#472C73', 40 + i); });
  let mid = '';
  [[-6, .5, 1.1], [118, .42, 1], [236, .36, .9], [800, 1.2, 1.2], [888, 1.0, 1]].forEach(([x, hh, s], i) => { mid += umbrellaTree(x, 690, 250 * hh, s * 1.15, '#22133F', 70 + i); });
  let huts = '';
  for (const [x, s] of [[60, 1], [96, .8], [140, 1.1], [182, .75]]) huts += `<g transform="translate(${x},650) scale(${s})"><rect x="-11" y="-13" width="22" height="13" fill="#2A1746"/><path d="M-16,-12 L0,-27 L16,-12Z" fill="#1B0F33"/><rect x="-3" y="-9" width="6" height="9" fill="#FFC45A"/><rect x="-3" y="-9" width="6" height="9" fill="#FFE9A8" opacity=".6"/></g><circle cx="${x}" cy="${650 - 5 * s}" r="${12 * s}" fill="#FFB84D" opacity=".18"/>`;
  const fg = bigLeaf(262, 740, 130, -58, '#0E2A3C', '#17485A', '#7FE0C0') + bigLeaf(318, 760, 128, -100, '#0B2233', '#12384A', '#7FE0C0') + bigLeaf(446, 740, 140, -122, '#0E2A3C', '#17485A', '#7FE0C0') + bigLeaf(380, 770, 120, -78, '#0B2233', '#12384A', '#7FE0C0');
  const fgR = bigLeaf(900, 735, 190, -118, '#0B2233', '#12384A', '#7FE0C0') + bigLeaf(880, 740, 150, -150, '#0E2A3C', '#17485A', '#7FE0C0') + bigLeaf(470, 740, 140, -70, '#0B2233', '#12384A', '#7FE0C0');
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" preserveAspectRatio="xMidYMid slice">
  <defs>
    <linearGradient id="nsky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#120D38"/><stop offset=".4" stop-color="#241758"/><stop offset=".66" stop-color="#4A2470"/><stop offset=".8" stop-color="#93386F"/><stop offset=".88" stop-color="#E4694F"/><stop offset=".93" stop-color="#FFB45A"/></linearGradient>
    <radialGradient id="moonglow"><stop offset="0" stop-color="#FFF4C8" stop-opacity=".6"/><stop offset=".35" stop-color="#F6D9FF" stop-opacity=".2"/><stop offset="1" stop-color="#F6D9FF" stop-opacity="0"/></radialGradient>
    <radialGradient id="moon" cx=".4" cy=".35" r=".8"><stop offset="0" stop-color="#FFFBE6"/><stop offset="1" stop-color="#FFE08A"/></radialGradient>
    <linearGradient id="ktrunk" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#150A2C"/><stop offset=".5" stop-color="#22123F"/><stop offset=".82" stop-color="#4A2C5E"/><stop offset=".96" stop-color="#B98A9A"/><stop offset="1" stop-color="#FFE3C8"/></linearGradient>
    <linearGradient id="haze" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FF9A5A" stop-opacity="0"/><stop offset="1" stop-color="#FF9A5A" stop-opacity=".5"/></linearGradient>
    <filter id="soft"><feGaussianBlur stdDeviation="2"/></filter><filter id="glow"><feGaussianBlur stdDeviation="9"/></filter>
    ${grainDefs()}${anansiDefs('an')}${kwekuDefs('kw')}${kentePattern('kwk', .42)}
  </defs>
  <rect width="${w}" height="${h}" fill="url(#nsky)"/>
  ${stars(60, 5, [460, 0, 432, 420])}<g opacity=".5">${stars(40, 6, [0, 0, 432, 420])}</g>
  <ellipse cx="640" cy="330" rx="230" ry="330" fill="#6A3A9A" opacity=".35" filter="url(#glow)"/>
  <circle cx="776" cy="170" r="150" fill="url(#moonglow)"/><circle cx="776" cy="170" r="52" fill="url(#moon)"/>
  <circle cx="760" cy="156" r="9" fill="#F3D27A" opacity=".5"/><circle cx="794" cy="188" r="13" fill="#F3D27A" opacity=".4"/><circle cx="790" cy="150" r="5" fill="#F3D27A" opacity=".4"/>
  ${far}
  <rect y="540" width="${w}" height="180" fill="url(#haze)"/>
  <path d="M0,660 C80,640 160,654 260,646 C360,638 420,656 520,648 C640,640 760,656 892,644 L892,720 L0,720Z" fill="#2A1746"/>
  ${huts}
  <path d="M100,618 C96,600 108,590 102,572 C98,560 106,552 104,544" stroke="#D9B8E8" stroke-width="2.500" fill="none" opacity=".3" stroke-linecap="round"/>
  ${mid}
  <path d="M0,690 C100,672 200,684 300,676 C420,668 520,686 640,678 C740,672 820,684 892,676 L892,720 L0,720Z" fill="#1A0F33"/>
  <!-- the great silk-cotton (kapok) tree -->
  <g>
    <path d="M604,0 C610,160 606,330 600,470 C596,560 570,640 520,720 L770,720 C726,650 700,560 696,470 C690,330 690,160 694,0Z" fill="url(#ktrunk)"/>
    <path d="M600,470 C590,570 556,650 500,720 L560,720 C590,660 612,580 618,500Z" fill="#1B0F33" opacity=".7"/>
    <path d="M696,470 C702,570 730,650 782,720 L740,720 C712,660 690,590 684,510Z" fill="#F3D9C8" opacity=".25"/>
    <path d="M640,720 C644,640 640,560 644,500 M664,720 C660,650 664,590 660,520" stroke="#1B0F33" stroke-width="3" fill="none" opacity=".5"/>
    <path d="M622,20 C626,160 620,320 618,450 M650,10 C654,180 648,300 650,440 M672,0 C676,160 670,320 674,460" stroke="#1B0F33" stroke-width="1.800" fill="none" opacity=".4"/>
    <path d="M692,10 C688,160 688,330 694,470" stroke="#FFE9D2" stroke-width="2.200" fill="none" opacity=".65"/>
    <path d="M606,120 C560,110 500,96 440,70 C420,62 400,58 380,50 L384,42 C420,48 470,66 520,78 C560,88 590,90 610,88Z" fill="#22133F"/>
    <path d="M692,150 C740,130 800,120 892,96 L892,84 C810,104 750,108 692,122Z" fill="#3D2458"/>
  </g>
  ${spiderWeb(694, 140, 110, -0.42, 0.5)}
  <path d="M762,118 L762,196" stroke="#fff" stroke-width=".7" opacity=".6"/><g transform="translate(762,200)"><ellipse rx="4" ry="5" fill="#17121F"/><circle cy="-5" r="2.600" fill="#17121F"/>${[-1, 1].map(sx => [[-4, -9], [-1, -10], [3, -9], [6, -6]].map(([dy, ex]) => `<path d="M0,${dy} q${sx * 6},${-3} ${sx * -ex},${3}" stroke="#17121F" stroke-width="1" fill="none"/>`).join('')).join('')}</g>
  ${top}
  <!-- Father Anansi and the pot -->
  <circle cx="598" cy="318" r="90" fill="#FFC94D" opacity=".22" filter="url(#glow)"/>
  <g transform="translate(558,372) scale(1.42)">${anansiClimb({ id: 'an' })}</g>
  ${wisdomMotes([[560, 268, 1.2, 1], [530, 236, 1, 2], [574, 210, 1.5, 0], [540, 176, .9, 1], [508, 196, .8, 2], [486, 150, 1.2, 0], [520, 130, .8, 2]])}
  ${kweku ? `<!-- Kweku Tsin watching from the leaves -->
  <g transform="translate(348,622)">
    <path d="M-40,110 C-44,50 -30,26 0,24 C30,26 46,50 42,110Z" fill="#8A4F33"/><path d="M-42,110 C-44,60 -30,30 -6,24 L34,66 L44,110Z" fill="url(#kwk)"/><path d="M-42,110 C-44,60 -30,30 -6,24 L34,66 L44,110Z" fill="#17121F" opacity=".2"/>
    <g transform="rotate(8)">${kwekuHead({ id: 'kw', look: [2.6, -2.6] })}</g>
  </g>` : ''}
  <g>${fg}</g><g>${fgR}</g>
  ${kweku ? `<g transform="translate(348,622)"><ellipse cx="-34" cy="36" rx="9" ry="7" fill="${SKIN}"/><ellipse cx="40" cy="44" rx="9" ry="7" fill="${SKIN}"/></g>` : ''}
  ${fireflies(12, 9, [0, 590, 300, 90])}${fireflies(22, 29, [460, 300, 432, 400])}
  ${grainRect(w, h, 'grain', .5)}
  </svg>`;
}

module.exports = { K, kentePattern, webMark, pot, potDefs, anansiClimb, anansiDefs, kwekuHead, kwekuDefs, anansiHead, faceKweku, faceAnansi, forestScene, fireflies, stars, bigLeaf, umbrellaTree, spiderWeb, wisdomMotes, nightCanopy };
});
