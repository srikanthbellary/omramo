// Code-drawn concept art: The Monkey and the Crocodile (Jataka, ancient India).
OMDEF('./art-jataka', function (require, module) {
const { rng, f1, grainDefs, grainRect } = require('./base');

const FUR = '#B5683A', FUR_D = '#7E4426', FUR_L = '#D98C52', CREAM = '#F8D9A8', EAR = '#EDA584';

function monkeyHead({ look = [0, 0], mouth = 'smile', id = 'm', blush = true } = {}) {
  const [lx, ly] = look;
  const eye = (x) => `<ellipse cx="${x}" cy="-3" rx="7.4" ry="8.6" fill="#fff"/><circle cx="${x + lx}" cy="${-2.4 + ly}" r="5.2" fill="#2B160D"/><circle cx="${x + lx - 1.8}" cy="${-4.6 + ly}" r="1.9" fill="#fff"/><circle cx="${x + lx + 2}" cy="${-0.4 + ly}" r=".9" fill="#fff" opacity=".8"/>`;
  const mouths = {
    smile: `<path d="M-9,12.500 Q0,21 9,12.500" fill="none" stroke="#5A2A17" stroke-width="2.400" stroke-linecap="round"/>`,
    grin: `<path d="M-11,11 Q0,25 11,11 Q0,15 -11,11Z" fill="#5A2A17"/><path d="M-7,13.200 Q0,16 7,13.200 L6,15 Q0,18 -6,15Z" fill="#fff"/>`,
    open: `<path d="M-8,11 Q0,8 8,11 Q9,24 0,25 Q-9,24 -8,11Z" fill="#5A2A17"/><ellipse cx="0" cy="21" rx="4.600" ry="3" fill="#F2788A"/>`,
    oh: `<ellipse cx="0" cy="16" rx="4.600" ry="5.600" fill="#5A2A17"/>`,
    smirk: `<path d="M-7,14 Q2,19 10,11" fill="none" stroke="#5A2A17" stroke-width="2.400" stroke-linecap="round"/>`,
  };
  return `<g>
  <circle cx="-33" cy="-3" r="13" fill="${FUR}"/><circle cx="-33" cy="-3" r="8" fill="${EAR}"/><path d="M-37,-6 q5,3 3,9" stroke="#C97D5E" stroke-width="1.800" fill="none" stroke-linecap="round"/>
  <circle cx="33" cy="-3" r="13" fill="${FUR}"/><circle cx="33" cy="-3" r="8" fill="${EAR}"/><path d="M37,-6 q-5,3 -3,9" stroke="#C97D5E" stroke-width="1.800" fill="none" stroke-linecap="round"/>
  <path d="M-6,-33 C-8,-42 -2,-46 -1,-40 C1,-48 8,-46 6,-38 C11,-43 14,-38 10,-32Z" fill="${FUR_D}"/>
  <ellipse cx="0" cy="0" rx="34" ry="31.500" fill="url(#${id}fur)"/>
  <path d="M-30,6 C-26,22 -12,30 0,30 C12,30 26,22 30,6 C24,26 -24,26 -30,6Z" fill="${FUR_D}" opacity=".35"/>
  <path d="M0,-15 C-9,-27 -30,-19 -27,0 C-25,17 -12,25 0,25 C12,25 25,17 27,0 C30,-19 9,-27 0,-15Z" fill="url(#${id}face)"/>
  ${blush ? `<ellipse cx="-17" cy="9" rx="5.500" ry="3.600" fill="#FF8A7A" opacity=".5"/><ellipse cx="17" cy="9" rx="5.500" ry="3.600" fill="#FF8A7A" opacity=".5"/>` : ''}
  ${eye(-11)}${eye(11)}
  <path d="M-17,-14 q6,-4 11,-1" stroke="#7E4426" stroke-width="2" fill="none" stroke-linecap="round"/><path d="M6,-15 q6,-3 11,1" stroke="#7E4426" stroke-width="2" fill="none" stroke-linecap="round"/>
  <path d="M-2.600,7 q2.600,2.200 5.200,0" stroke="#8A4A2C" stroke-width="2" fill="none" stroke-linecap="round"/>
  ${mouths[mouth] || mouths.smile}
  <ellipse cx="-12" cy="-22" rx="12" ry="5" fill="#fff" opacity=".16" transform="rotate(-24 -12 -22)"/>
  </g>`;
}
function monkeyDefs(id = 'm') {
  return `<radialGradient id="${id}fur" cx=".38" cy=".3" r=".8"><stop offset="0" stop-color="${FUR_L}"/><stop offset=".55" stop-color="${FUR}"/><stop offset="1" stop-color="${FUR_D}"/></radialGradient>
  <radialGradient id="${id}face" cx=".45" cy=".35" r=".75"><stop offset="0" stop-color="#FFEAC4"/><stop offset="1" stop-color="#F2C68E"/></radialGradient>
  <linearGradient id="${id}limb" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${FUR_L}"/><stop offset="1" stop-color="${FUR}"/></linearGradient>`;
}
const limb = (d, w = 11, c = FUR) => `<path d="${d}" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;
const paw = (x, y, r = 6.5) => `<circle cx="${x}" cy="${y}" r="${r}" fill="${FUR_D}"/>`;

// pose: sit | ride | wave | call
function monkey({ pose = 'sit', look = [0, 0], mouth = 'smile', id = 'm' } = {}) {
  const torso = `<ellipse cx="0" cy="-32" rx="21" ry="27" fill="url(#${id}fur)"/><ellipse cx="-2" cy="-28" rx="13" ry="18.500" fill="url(#${id}face)"/>`;
  if (pose === 'sit') {
    return `<g>
    ${limb('M12,-8 C40,-2 54,30 42,64 C35,84 14,84 13,68 C12,59 22,56 26,63', 6.5, FUR_D)}
    ${limb('M17,-46 C32,-44 38,-30 34,-14', 10, FUR_D)}
    ${torso}
    ${limb('M-8,-9 C-22,-10 -30,-2 -28,13', 12)}<ellipse cx="-30" cy="17" rx="9" ry="6" fill="${FUR_D}"/>
    ${limb('M10,-9 C22,-8 28,0 25,15', 12)}<ellipse cx="24" cy="19" rx="9" ry="6" fill="${FUR_D}"/>
    ${limb('M-17,-45 C-31,-38 -38,-22 -36,-7', 10)}${paw(-36, -5)}${paw(34, -12)}
    <g transform="translate(-3,-84) rotate(-6)">${monkeyHead({ look, mouth, id })}</g></g>`;
  }
  if (pose === 'ride') {
    return `<g>
    ${limb('M14,-8 C44,-10 60,-34 52,-62 C48,-76 34,-74 36,-62', 6.5, FUR_D)}
    ${limb('M16,-48 C32,-56 40,-72 38,-88', 10, FUR_D)}${paw(38, -90)}
    ${torso}
    ${limb('M-6,-9 C-20,-6 -30,2 -34,10', 12)}<ellipse cx="-37" cy="13" rx="9" ry="6" fill="${FUR_D}"/>
    ${limb('M8,-9 C20,-4 24,4 22,12', 12)}<ellipse cx="22" cy="15" rx="9" ry="6" fill="${FUR_D}"/>
    ${limb('M-17,-48 C-32,-58 -40,-74 -40,-90', 10)}${paw(-40, -92)}
    <g transform="translate(-2,-86) rotate(-4)">${monkeyHead({ look, mouth, id })}</g></g>`;
  }
  if (pose === 'wave') {
    return `<g>
    ${limb('M14,-8 C46,-4 58,26 46,56 C40,72 22,70 23,58', 6.5, FUR_D)}
    ${limb('M16,-46 C30,-40 34,-26 28,-14', 10, FUR_D)}
    ${torso}
    ${limb('M-8,-9 C-22,-10 -30,-2 -28,13', 12)}<ellipse cx="-30" cy="17" rx="9" ry="6" fill="${FUR_D}"/>
    ${limb('M10,-9 C22,-8 28,0 25,15', 12)}<ellipse cx="24" cy="19" rx="9" ry="6" fill="${FUR_D}"/>
    ${limb('M-17,-48 C-36,-52 -48,-70 -50,-92', 10)}${paw(-50, -94, 7)}${paw(27, -12)}
    <g transform="translate(-1,-86) rotate(5)">${monkeyHead({ look, mouth, id })}</g></g>`;
  }
  // call: one hand cupped to the mouth, the other gripping a branch above
  return `<g>
    ${limb('M12,-8 C40,-2 54,30 42,64 C35,84 14,84 13,68 C12,59 22,56 26,63', 6.5, FUR_D)}
    ${limb('M17,-48 C34,-56 42,-78 40,-100', 10, FUR_D)}${paw(40, -102)}
    ${torso}
    ${limb('M-8,-9 C-22,-10 -30,-2 -28,13', 12)}<ellipse cx="-30" cy="17" rx="9" ry="6" fill="${FUR_D}"/>
    ${limb('M10,-9 C22,-8 28,0 25,15', 12)}<ellipse cx="24" cy="19" rx="9" ry="6" fill="${FUR_D}"/>
    <g transform="translate(-6,-84) rotate(-12)">${monkeyHead({ look, mouth, id })}</g>
    ${limb('M-17,-46 C-34,-46 -44,-58 -40,-68', 10)}${paw(-39, -70, 7)}</g>`;
}

// ---------- crocodile (faces left; origin = snout tip, waterline at y=wl) ----------
function crocDefs(id = 'c') {
  return `<linearGradient id="${id}skin" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#8FD05E"/><stop offset=".45" stop-color="#4FA650"/><stop offset="1" stop-color="#2C6E47"/></linearGradient>
  <linearGradient id="${id}belly" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F1F3B4"/><stop offset="1" stop-color="#C9DA8C"/></linearGradient>`;
}
const CROC_BODY = 'M-3,5 C-3,-5 5,-10 14,-9 C21,-8 23,-5 31,-5 L60,-7 C72,-9 75,-23 87,-29 C99,-34 113,-30 117,-20 C132,-18 152,-21 172,-25 C216,-33 266,-23 302,-7 C322,2 338,7 356,9 C338,22 318,30 300,36 C262,48 200,52 122,45 C80,41 30,31 0,17 C-3,14 -3,9 -3,5Z';
function croc({ id = 'c', lid = 'sleepy', look = [0, 0], open = 0, wl = 12, water = '#19A39E', waterOp = 0.78, tooth = true, len = 1 } = {}) {
  const yb = (x) => x > 215 ? -30 + Math.pow((x - 215) / 88, 2) * 24 : -30 + Math.pow((215 - x) / 70, 2) * 7;
  let scutes = '';
  for (let x = 150; x <= 296; x += 14.5) { const y = yb(x); scutes += `<path d="M${f1(x - 7)},${f1(y + 3)} L${f1(x + 1)},${f1(y - 9)} L${f1(x + 8)},${f1(y + 3)}Z" fill="#3E9150" stroke="#2C6E47" stroke-width=".8" stroke-linejoin="round"/>`; }
  let teeth = '';
  for (let x = 8; x < 82; x += 9) teeth += `<path d="M${x},${f1(6 - x * 0.012)} l3.200,6.500 l3.200,-6.500Z" fill="#fff"/>`;
  const lids = {
    sleepy: `<path d="M84,-22 Q94,-33 106,-23 Q95,-25 84,-22Z" fill="#3E9150"/><path d="M84.500,-21 Q95,-25 105.500,-22" stroke="#2C6E47" stroke-width="1.600" fill="none"/>`,
    sly: `<path d="M83,-26 Q96,-34 107,-22 Q96,-27 83,-24Z" fill="#3E9150"/><path d="M83.500,-24 Q96,-27 106,-21" stroke="#2C6E47" stroke-width="1.800" fill="none" stroke-linecap="round"/>`,
    wide: ``,
    shut: `<path d="M85,-19 Q95,-13 105,-19" stroke="#2C6E47" stroke-width="2.200" fill="none" stroke-linecap="round"/>`,
  };
  let spots = '';
  const r = rng(11);
  for (let i = 0; i < 16; i++) { const x = 128 + r() * 170, y = yb(x) + 9 + r() * 16; spots += `<ellipse cx="${f1(x)}" cy="${f1(y)}" rx="${f1(3 + r() * 4)}" ry="${f1(2 + r() * 2)}" fill="#2C6E47" opacity=".35"/>`; }
  const eye = lid === 'shut' ? `<circle cx="95" cy="-19" r="9" fill="#58AE55"/>` : `<circle cx="95" cy="-19" r="9" fill="#FFE46B"/><circle cx="95" cy="-19" r="9" fill="none" stroke="#2C6E47" stroke-width="1.400"/><ellipse cx="${95 + look[0]}" cy="${-18.5 + look[1]}" rx="2.800" ry="6" fill="#1D2B1D"/><circle cx="${93 + look[0]}" cy="${-22 + look[1]}" r="1.700" fill="#fff"/>`;
  return `<g>
  <clipPath id="${id}clip"><path d="${CROC_BODY}"/></clipPath>
  ${scutes}
  <path d="${CROC_BODY}" fill="url(#${id}skin)"/>
  <g clip-path="url(#${id}clip)">
    <path d="M-5,8 C30,9 70,9 96,7 C110,20 60,40 0,24Z" fill="url(#${id}belly)"/>
    <path d="M110,44 C180,52 262,50 320,28 L330,60 L100,60Z" fill="url(#${id}belly)" opacity=".85"/>
    ${spots}
    <path d="M-3,-2 C30,-10 60,-12 80,-28 C100,-40 116,-30 118,-22 C160,-30 230,-36 300,-10" fill="none" stroke="#C8F28A" stroke-width="5" opacity=".45" stroke-linecap="round"/>
    <rect x="-20" y="${wl}" width="400" height="80" fill="${water}" opacity="${waterOp}"/>
  </g>
  <path d="M-3,7 C30,8 70,8.500 94,7 C100,6 104,2 106,-3" fill="none" stroke="#235B3B" stroke-width="2" stroke-linecap="round"/>
  <g>${teeth}</g>
  ${tooth ? `<path d="M22,8.500 l3.500,-8 l3.500,8Z" fill="#fff" stroke="#DCE8C0" stroke-width=".5"/>` : ''}
  <ellipse cx="11" cy="-5.500" rx="2.600" ry="1.800" fill="#235B3B"/>
  <path d="M78,-17 C82,-30 104,-34 112,-20 C104,-9 84,-8 78,-17Z" fill="#58AE55"/>
  ${eye}${lids[lid] || ''}
  </g>`;
}
// ripple rings around something sitting in water
function ripples(x, y, w, n = 3, c = '#fff', op = 0.55) {
  let s = '';
  for (let i = 0; i < n; i++) { const ww = w * (1 + i * 0.22), yy = y + i * 5; s += `<path d="M${f1(x - ww / 2)},${f1(yy)} q${f1(ww / 4)},${3 + i} ${f1(ww / 2)},0 t${f1(ww / 2)},0" fill="none" stroke="${c}" stroke-width="${f1(2.2 - i * 0.5)}" opacity="${f1(op - i * 0.15)}" stroke-linecap="round"/>`; }
  return s;
}

// ---------- vegetation ----------
const leafPath = (x, y, r, a) => { const c = Math.cos(a), s = Math.sin(a); const p = (u, v) => `${f1(x + u * c - v * s)},${f1(y + u * s + v * c)}`; return `M${p(0, 0)} C${p(r * .45, -r * .42)} ${p(r * .95, -r * .26)} ${p(r * 1.25, 0)} C${p(r * .95, r * .26)} ${p(r * .45, r * .42)} ${p(0, 0)}Z`; };
function canopy(blobs, seed = 3, pal = ['#0E4A45', '#16695A', '#22966A', '#52BF72', '#B4E86B'], density = 1) {
  const r = rng(seed); let back = '', mid = '', light = '', hi = '';
  for (const b of blobs) {
    back += `<circle cx="${b.x}" cy="${b.y}" r="${f1(b.r * .72)}" fill="${pal[0]}"/>`;
    const n = Math.round(b.r * b.r / 26 * density);
    for (let i = 0; i < n; i++) {
      const a = r() * 6.283, d = Math.pow(r(), .42) * b.r * 1.06, x = b.x + Math.cos(a) * d, y = b.y + Math.sin(a) * d * .92;
      const la = (r() - .5) * 2.4 + (x < b.x ? 2.6 : .5), sz = 7 + r() * 8;
      const lit = ((b.x - x) + (b.y - y) * 1.3) / b.r; // >0 = upper-left = sunlit
      const k = r();
      if (i < n * .38) back += `<path d="${leafPath(x, y, sz * 1.1, la)}" fill="${k < .5 ? pal[0] : pal[1]}"/>`;
      else if (lit + k * .9 > .95) light += `<path d="${leafPath(x, y, sz, la)}" fill="${k > .82 ? pal[4] : pal[3]}"/>`;
      else mid += `<path d="${leafPath(x, y, sz, la)}" fill="${k < .55 ? pal[1] : pal[2]}"/>`;
    }
  }
  return `<g>${back}</g><g>${mid}</g><g>${light}</g>`;
}
function lotusPad(x, y, rx, flower = false, id = '') {
  const ry = rx * .32;
  let s = `<path d="M${x - rx},${y} a${rx},${ry} 0 1 0 ${rx * 2},0 a${rx},${ry} 0 1 0 ${-rx * 2},0Z M${x},${y} l${rx * .9},${-ry * .5} l${-rx * .1},${ry * .8}Z" fill="#2FA36B" fill-rule="evenodd"/><path d="M${x - rx * .8},${y - ry * .2} a${rx * .8},${ry * .7} 0 0 1 ${rx * 1.2},${-ry * .6}" stroke="#7FD68A" stroke-width="1.500" fill="none" opacity=".8"/>`;
  if (flower) {
    const fx = x - rx * .2, fy = y - ry * .6;
    const pet = (a, l, c) => `<path d="M0,0 C${-l * .32},${-l * .5} ${-l * .2},${-l * .9} 0,${-l} C${l * .2},${-l * .9} ${l * .32},${-l * .5} 0,0Z" fill="${c}" transform="translate(${fx},${fy}) rotate(${a})"/>`;
    s += pet(-62, 15, '#F06C9B') + pet(62, 15, '#F06C9B') + pet(-36, 18, '#FF8FB4') + pet(36, 18, '#FF8FB4') + pet(-14, 20, '#FFB3CC') + pet(14, 20, '#FFB3CC') + pet(0, 17, '#FFD3E0') + `<circle cx="${fx}" cy="${fy - 3}" r="2.600" fill="#FFD23F"/>`;
  }
  return s;
}
function reeds(x, y, n, seed, h = 70, c = '#2C8A5C') {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) { const dx = (r() - .5) * 46, hh = h * (.55 + r() * .6), lean = (r() - .5) * 26; s += `<path d="M${f1(x + dx)},${y} q${f1(lean * .3)},${f1(-hh * .6)} ${f1(lean)},${f1(-hh)}" stroke="${r() > .5 ? c : '#3FA36A'}" stroke-width="${f1(1.8 + r() * 1.6)}" fill="none" stroke-linecap="round"/>`; if (r() > .6) s += `<rect x="${f1(x + dx + lean - 2.2)}" y="${f1(y - hh - 9)}" width="4.400" height="14" rx="2.200" fill="#7A4A2A" transform="rotate(${f1(lean * .6)} ${f1(x + dx + lean)} ${f1(y - hh)})"/>`; }
  return s;
}
function waterRipples(x0, x1, y0, y1, n, seed, c = '#fff') {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) { const t = Math.pow(r(), .8), y = y0 + t * (y1 - y0), w = 14 + t * 60 * (.4 + r()), x = x0 + r() * (x1 - x0); s += `<path d="M${f1(x)},${f1(y)} q${f1(w / 4)},${f1(-1.5 - t * 2)} ${f1(w / 2)},0 t${f1(w / 2)},0" fill="none" stroke="${c}" stroke-width="${f1(.9 + t * 1.6)}" opacity="${f1(.12 + r() * .3)}" stroke-linecap="round"/>`; }
  return s;
}
function hills(w, y, amp, seed, fill, step = 8, x0 = 0) {
  const r = rng(seed); const p1 = r() * 6, p2 = r() * 6, p3 = r() * 6; let d = `M${x0},720 L${x0},${y}`;
  for (let x = x0; x <= x0 + w; x += step) { const yy = y - amp * (.5 * Math.sin(x / 97 + p1) + .32 * Math.sin(x / 41 + p2) + .18 * Math.sin(x / 17 + p3)); d += ` L${x},${f1(yy)}`; }
  return `<path d="${d} L${x0 + w},720Z" fill="${fill}"/>`;
}
function mangoTree(x, y, s, seed) {
  const r = rng(seed); let fruits = '';
  for (let i = 0; i < 7; i++) { const a = r() * 6.28, d = r() * 17 * s; fruits += `<ellipse cx="${f1(x + Math.cos(a) * d)}" cy="${f1(y - 34 * s + Math.sin(a) * d * .7 + 3)}" rx="${f1(2.6 * s)}" ry="${f1(3.3 * s)}" fill="${r() > .4 ? '#FFB62E' : '#FF8A3D'}"/>`; }
  return `<path d="M${x - 2 * s},${y} q${1 * s},${-12 * s} ${-1 * s},${-22 * s} l${5 * s},0 q${-1 * s},${10 * s} ${2 * s},${22 * s}Z" fill="#6B4A3A"/>
  <ellipse cx="${x}" cy="${y - 34 * s}" rx="${22 * s}" ry="${17 * s}" fill="#1E8A63"/><ellipse cx="${x - 6 * s}" cy="${y - 39 * s}" rx="${13 * s}" ry="${9 * s}" fill="#3DB877" opacity=".9"/>${fruits}`;
}
function palm(x, y, s, lean = 0, c = '#1C7A5E') {
  let fr = '';
  for (const a of [-150, -120, -95, -70, -40, -15, 10]) fr += `<path d="M0,0 q${18 * s},${-10 * s} ${34 * s},${4 * s} q${-18 * s},${-3 * s} ${-34 * s},${-4 * s}Z" fill="${c}" transform="translate(${x + lean},${y - 46 * s}) rotate(${a})"/>`;
  return `<path d="M${x},${y} q${lean * .2},${-24 * s} ${lean},${-46 * s}" stroke="#5A4638" stroke-width="${2.6 * s}" fill="none" stroke-linecap="round"/>${fr}`;
}

// The riverbank world. Canvas 892x720: left pane sky is the calm reading zone.
function riverScene({ w = 892, h = 720, horizon = 584 } = {}) {
  const H = horizon;
  const tree = canopy([
    { x: 835, y: 60, r: 95 }, { x: 720, y: 50, r: 80 }, { x: 610, y: 78, r: 70 }, { x: 520, y: 60, r: 62 }, { x: 440, y: 46, r: 50 }, { x: 386, y: 30, r: 34 },
    { x: 880, y: 170, r: 70 }, { x: 760, y: 140, r: 66 }, { x: 660, y: 150, r: 46 }, { x: 560, y: 132, r: 40 }, { x: 480, y: 112, r: 34 }, { x: 870, y: 260, r: 44 }, { x: 660, y: 96, r: 50 }, { x: 570, y: 40, r: 50 }, { x: 800, y: 200, r: 40 }, { x: 700, y: 190, r: 30 }, { x: 610, y: 170, r: 26 }, { x: 420, y: 96, r: 22 }, { x: 392, y: 70, r: 18 }, { x: 520, y: 150, r: 22 },
  ], 5);
  const front = canopy([{ x: 505, y: 302, r: 26 }, { x: 472, y: 316, r: 22 }, { x: 536, y: 318, r: 18 }, { x: 440, y: 302, r: 16 }, { x: 486, y: 290, r: 16 }, { x: 760, y: 236, r: 30 }, { x: 726, y: 252, r: 22 }, { x: 800, y: 262, r: 26 }], 9);
  let roots = '';
  const rr = rng(21);
  for (const [x, y0, len] of [[560, 150, 150], [574, 160, 120], [690, 200, 190], [703, 190, 130], [800, 250, 120], [650, 180, 90], [742, 286, 140], [520, 150, 100]]) {
    const sway = (rr() - .5) * 14; roots += `<path d="M${x},${y0} q${f1(sway)},${f1(len * .5)} ${f1(sway * .4)},${len}" stroke="#5B3B36" stroke-width="${f1(1.6 + rr() * 1.6)}" fill="none" stroke-linecap="round" opacity=".9"/>`;
  }
  let glints = '';
  const g = rng(8);
  for (let i = 0; i < 46; i++) { const y = H + 6 + Math.pow(g(), 1.3) * 130, spread = 16 + (y - H) * .5, x = 120 + (g() - .5) * spread * 2, ww = 6 + g() * 22 * (.5 + (y - H) / 150); glints += `<rect x="${f1(x - ww / 2)}" y="${f1(y)}" width="${f1(ww)}" height="${f1(1.4 + (y - H) / 90)}" rx="1" fill="#FFF6C8" opacity="${f1(.35 + g() * .5)}"/>`; }
  let birds = '';
  for (const [x, y, s] of [[236, 468, 1], [262, 456, .7], [214, 452, .6]]) birds += `<path d="M${x - 7 * s},${y} q${3.5 * s},${-5 * s} ${7 * s},0 q${3.5 * s},${-5 * s} ${7 * s},0" stroke="#3B6E79" stroke-width="${1.5 * s}" fill="none" stroke-linecap="round" opacity=".7"/>`;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" preserveAspectRatio="xMidYMid slice">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#BDEFE9"/><stop offset=".42" stop-color="#DDF8EC"/><stop offset=".72" stop-color="#F6FBD9"/><stop offset=".8" stop-color="#FFF2B5"/></linearGradient>
    <radialGradient id="sunglow" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="#FFF7C2" stop-opacity=".95"/><stop offset=".45" stop-color="#FFEE9E" stop-opacity=".5"/><stop offset="1" stop-color="#FFEE9E" stop-opacity="0"/></radialGradient>
    <linearGradient id="river" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#A9E9D4"/><stop offset=".16" stop-color="#4CC4B4"/><stop offset=".6" stop-color="#1596A0"/><stop offset="1" stop-color="#0A6585"/></linearGradient>
    <linearGradient id="trunk" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#8E5B45"/><stop offset=".35" stop-color="#6B4138"/><stop offset="1" stop-color="#3E2532"/></linearGradient>
    <linearGradient id="bank" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7CCB5C"/><stop offset=".3" stop-color="#3F9E58"/><stop offset="1" stop-color="#1F6B50"/></linearGradient>
    <linearGradient id="topshade" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#06302E" stop-opacity=".55"/><stop offset="1" stop-color="#06302E" stop-opacity="0"/></linearGradient>
    <linearGradient id="shade" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0B3B40" stop-opacity=".0"/><stop offset="1" stop-color="#0B3B40" stop-opacity=".5"/></linearGradient>
    <filter id="soft"><feGaussianBlur stdDeviation="2.200"/></filter><filter id="softer"><feGaussianBlur stdDeviation="7"/></filter>
    ${grainDefs()}${monkeyDefs('m')}${crocDefs('c')}${crocDefs('c2')}
  </defs>
  <rect width="${w}" height="${h}" fill="url(#sky)"/>
  <circle cx="120" cy="${H - 26}" r="170" fill="url(#sunglow)"/>
  <circle cx="120" cy="${H - 30}" r="38" fill="#FFF9D6"/>
  <g opacity=".55">${[[60, 150, 1.1], [300, 96, .8]].map(([x, y, s]) => `<path d="M${x},${y} q${14 * s},${-18 * s} ${34 * s},${-8 * s} q${14 * s},${-16 * s} ${36 * s},${-2 * s} q${22 * s},${-4 * s} ${26 * s},${10 * s}Z" fill="#fff"/>`).join('')}</g>
    ${hills(w, H - 22, 26, 4, '#A8DDCF')}
  ${hills(w, H - 8, 16, 9, '#7CCAB2')}
  <g>${[40, 92, 330, 372, 470, 512, 596].map((x, i) => palm(x, H - 2, .5 + (i % 3) * .12, (i % 2 ? 5 : -4), '#3FA088')).join('')}</g>
  ${hills(w, H + 2, 7, 15, '#3FA088', 5)}
  <rect y="${H}" width="${w}" height="${h - H}" fill="url(#river)"/>
  <rect y="${H}" width="${w}" height="9" fill="#2B8C7E" opacity=".35"/>
  ${glints}
  ${waterRipples(0, w, H + 8, h, 110, 31)}
  <!-- island with the ripe fruit -->
  <g transform="translate(196,4)"><ellipse cx="118" cy="${H + 34}" rx="112" ry="9" fill="#0E7C86" opacity=".35"/>
  <path d="M10,${H + 30} C40,${H + 8} 90,${H + 2} 130,${H + 4} C176,${H + 6} 210,${H + 16} 226,${H + 30}Z" fill="#E9D58A"/><path d="M26,${H + 24} C56,${H + 6} 100,${H + 1} 134,${H + 4} C170,${H + 6} 196,${H + 14} 210,${H + 24}Z" fill="#5DBB63"/>
  ${mangoTree(70, H + 12, .95, 2)}${mangoTree(118, H + 8, 1.2, 5)}${mangoTree(166, H + 13, .9, 7)}${palm(196, H + 16, .7, 8, '#1C7A5E')}</g>
  <!-- near bank + banyan -->
  <path d="M892,470 C850,476 800,500 760,528 C720,556 690,560 650,${H + 22} C640,${H + 32} 660,${H + 44} 700,${H + 50} C760,${H + 60} 800,640 892,650Z" fill="url(#bank)"/>
  <path d="M650,${H + 22} C640,${H + 32} 660,${H + 44} 700,${H + 50} C760,${H + 60} 800,640 892,650 L892,668 C800,660 750,${H + 76} 694,${H + 62} C650,${H + 54} 628,${H + 38} 650,${H + 22}Z" fill="#7A5638"/>
  ${reeds(676, H + 34, 9, 4, 64)}${reeds(742, H + 54, 7, 12, 52)}
  <g>
    <path d="M770,${H - 10} C792,470 790,380 800,300 C806,250 800,200 790,150 L880,150 C872,230 878,330 872,420 C868,480 880,520 892,540 L892,${H + 20} C850,${H + 10} 800,${H + 6} 752,${H + 10} C760,${H + 4} 766,${H - 2} 770,${H - 10}Z" fill="url(#trunk)"/>
    <path d="M806,330 C760,326 700,330 640,326 C590,322 540,318 492,316 C470,315 452,312 436,306 L438,298 C470,304 520,304 560,306 C640,308 720,300 800,286Z" fill="url(#trunk)"/>
    <path d="M800,286 C720,300 640,308 560,306 C520,304 470,304 438,298" fill="none" stroke="#B37A58" stroke-width="2.500" opacity=".7" stroke-linecap="round"/>
    <path d="M812,520 C818,420 814,330 822,200 M842,540 C846,430 840,330 850,190 M790,${H} C800,500 802,470 806,420" stroke="#3A2230" stroke-width="2" fill="none" opacity=".45" stroke-linecap="round"/>
    <path d="M796,470 C800,400 798,340 806,270" stroke="#C68A62" stroke-width="3" fill="none" opacity=".5" stroke-linecap="round"/>
    <path d="M770,${H - 10} C756,${H + 4} 740,${H + 10} 720,${H + 14} M800,${H + 4} C790,${H + 16} 780,${H + 22} 764,${H + 28}" stroke="#5B3B36" stroke-width="7" fill="none" stroke-linecap="round"/>
  </g>
  ${roots}
  ${tree}
  <!-- monkey on the branch -->
  <ellipse cx="607" cy="310" rx="30" ry="4" fill="#2A1820" opacity=".35"/>
  <g transform="translate(606,306) scale(.98)">${monkey({ pose: 'sit', look: [-2.2, 2.2], mouth: 'smile', id: 'm' })}</g>
  ${front}
  <rect x="460" y="0" width="432" height="70" fill="url(#topshade)"/>
  <!-- crocodiles -->
  <g transform="translate(716,${H + 62}) scale(-.8,.8)">${croc({ id: 'c', lid: 'sly', look: [-1, -2], wl: 9, water: '#1596A0' })}</g>
  ${ripples(594, H + 72, 230, 3)}
  <g transform="translate(412,${H + 78}) scale(-.42,.42)">${croc({ id: 'c2', lid: 'wide', look: [-1.500, -1], wl: 9, water: '#2AA9A6' })}</g>
  ${ripples(346, H + 83, 120, 2)}
  ${lotusPad(60, H + 112, 34, true)}${lotusPad(124, H + 132, 26)}${lotusPad(24, H + 138, 22)}${lotusPad(820, 690, 30, true)}${lotusPad(760, 704, 22)}
  <g filter="url(#soft)" opacity=".95"><path d="M-10,720 C-6,660 20,630 60,640 C40,668 34,700 40,720Z" fill="#0E5A55"/><path d="M892,720 L892,600 C860,610 846,650 852,720Z" fill="#0E5A55"/></g>
  <!-- dragonflies -->
  ${[[300, H + 30, 1], [520, H + 20, .8]].map(([x, y, s]) => `<g transform="translate(${x},${y}) scale(${s}) rotate(-18)"><path d="M0,0 l16,0" stroke="#E0457B" stroke-width="2" stroke-linecap="round"/><ellipse cx="4" cy="-4" rx="7" ry="2.400" fill="#fff" opacity=".8" transform="rotate(-20 4 -4)"/><ellipse cx="4" cy="4" rx="7" ry="2.400" fill="#fff" opacity=".7" transform="rotate(20 4 4)"/></g>`).join('')}
  ${grainRect(w, h, 'grain', .55)}
  </svg>`;
}

// tiny face chips for "who is speaking"
const faceMonkey = (id = 'fm') => `<svg viewBox="-42 -44 84 84"><defs>${monkeyDefs(id)}</defs><rect x="-42" y="-44" width="84" height="84" fill="#FFE2A8"/>${monkeyHead({ id })}</svg>`;
const faceCroc = (id = 'fc', bg = '#BDEFE0') => `<svg viewBox="52 -52 78 78"><defs>${crocDefs(id)}</defs><rect x="52" y="-52" width="78" height="78" fill="${bg}"/><g transform="translate(0,6)">${croc({ id, lid: 'sleepy', wl: 60, waterOp: 0 })}</g></svg>`;

module.exports = { monkey, monkeyHead, monkeyDefs, croc, crocDefs, ripples, canopy, lotusPad, reeds, waterRipples, hills, mangoTree, palm, riverScene, faceMonkey, faceCroc, leafPath };
});
