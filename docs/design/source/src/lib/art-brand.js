// Brand-level art: story cover art, dotted world map, splash backdrop.
OMDEF('./art-brand', function (require, module) {
const { rng, f1, grainDefs } = require('./base');
const J = require('./art-jataka'), A = require('./art-anansi'), U = require('./art-urashima');

// ---- dotted world map (hand-plotted land runs every 5° of latitude; stylised, not survey-accurate) ----
const LAND = [
  [75, [-120, -80], [-55, -20], [90, 110]], [70, [-160, -85], [-52, -22], [20, 30], [60, 180]], [65, [-165, -62], [-50, -38], [-22, -14], [10, 40], [45, 180]],
  [60, [-162, -95], [-78, -62], [-48, -43], [5, 30], [30, 165]], [55, [-130, -60], [-8, 0], [8, 160]], [50, [-126, -58], [-5, 2], [3, 142]],
  [45, [-124, -64], [0, 138], [140, 144]], [40, [-123, -72], [-9, 2], [8, 28], [28, 128], [138, 142]], [35, [-120, -76], [-6, 10], [28, 122], [133, 140]],
  [30, [-115, -82], [-9, 34], [35, 120]], [25, [-110, -98], [-82, -80], [-14, 56], [58, 118]], [20, [-105, -88], [-17, 50], [70, 108]],
  [15, [-96, -84], [-17, 48], [74, 82], [94, 108], [120, 123]], [10, [-86, -62], [-15, 50], [76, 80], [98, 108], [122, 126]], [5, [-78, -52], [-8, 46], [96, 118]],
  [0, [-80, -50], [10, 42], [100, 104], [110, 118], [120, 132]], [-5, [-80, -36], [12, 40], [104, 112], [120, 150]], [-10, [-76, -37], [13, 40], [142, 148]],
  [-15, [-74, -39], [12, 40], [46, 50], [124, 146]], [-20, [-70, -40], [13, 36], [44, 50], [116, 148]], [-25, [-70, -48], [15, 34], [44, 47], [114, 152]],
  [-30, [-71, -51], [17, 31], [116, 152]], [-35, [-72, -55], [19, 26], [118, 124], [136, 150]], [-40, [-73, -62], [144, 148], [172, 176]], [-45, [-74, -66], [168, 172]], [-50, [-74, -68]],
];
// project lon/lat into a w x h box
const proj = (lon, lat, w, h) => [f1((lon + 170) / 350 * w), f1((78 - lat) / 132 * h)];
function worldDots(w, h, c = '#C9C4F2', r = 1.9, step = 5) {
  let s = '';
  for (const [lat, ...runs] of LAND) for (const [a, b] of runs) for (let lon = Math.ceil(a / step) * step; lon <= b; lon += step) { const [x, y] = proj(lon, lat, w, h); s += `<circle cx="${x}" cy="${y}" r="${r}"/>`; }
  return `<g fill="${c}">${s}</g>`;
}

// ---- cover art (viewBox 240 x 300), full-bleed, no titles baked in ----
function coverLow(id = 'cl') {
  return `<svg viewBox="0 0 240 300" preserveAspectRatio="xMidYMid slice"><defs>
  <linearGradient id="${id}s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7FE3D3"/><stop offset=".55" stop-color="#D9F7C8"/><stop offset=".7" stop-color="#FFF0A0"/></linearGradient>
  <linearGradient id="${id}w" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#4CC4B4"/><stop offset="1" stop-color="#0A6585"/></linearGradient>
  ${J.monkeyDefs(id + 'm')}${J.crocDefs(id + 'c')}${grainDefs(id + 'g')}</defs>
  <rect width="240" height="300" fill="url(#${id}s)"/><circle cx="176" cy="150" r="46" fill="#FFF9D6"/><circle cx="176" cy="150" r="80" fill="#FFF3A8" opacity=".4"/>
  ${J.hills(240, 196, 14, 6, '#7CCAB2')}
  <rect y="200" width="240" height="100" fill="url(#${id}w)"/>${J.waterRipples(0, 240, 206, 300, 26, 5)}
  <g transform="translate(18,238) scale(.62)">${J.croc({ id: id + 'c', lid: 'sleepy', wl: 12, water: '#1596A0' })}<g transform="translate(206,-26) scale(1.15)">${J.monkey({ pose: 'ride', mouth: 'grin', look: [-1.5, 0], id: id + 'm' })}</g></g>
  ${J.ripples(120, 250, 190, 2)}
  ${J.canopy([{ x: 20, y: 6, r: 44 }, { x: 80, y: -8, r: 34 }, { x: -6, y: 60, r: 26 }, { x: 230, y: 0, r: 30 }], 4)}
  <rect width="240" height="300" filter="url(#${id}g)" opacity=".5" style="mix-blend-mode:soft-light"/></svg>`;
}
function coverMed(id = 'cm') {
  return `<svg viewBox="0 0 240 300" preserveAspectRatio="xMidYMid slice"><defs>
  <linearGradient id="${id}s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1A1250"/><stop offset=".5" stop-color="#4A2470"/><stop offset=".78" stop-color="#C24868"/><stop offset="1" stop-color="#FFA24D"/></linearGradient>
  ${A.potDefs(id + 'p')}${A.kentePattern(id + 'k', .62)}${grainDefs(id + 'g')}<filter id="${id}b"><feGaussianBlur stdDeviation="8"/></filter></defs>
  <rect width="240" height="300" fill="url(#${id}s)"/>${A.stars(40, 3, [0, 0, 240, 150])}
  ${A.spiderWeb(120, 128, 150, 0, 6.283, '#FFE9C8')}
  <circle cx="120" cy="132" r="70" fill="#FFC94D" opacity=".4" filter="url(#${id}b)"/>
  ${A.pot(120, 140, 2.7, id + 'p')}
  ${A.wisdomMotes([[70, 70, 1.3, 0], [176, 58, 1.1, 1], [196, 112, 1, 2], [48, 122, .9, 1], [150, 30, 1, 2], [92, 36, .8, 2], [206, 170, 1.2, 0], [34, 180, 1, 2]])}
  <path d="M120,-4 V40" stroke="#FFE9C8" stroke-width=".8" opacity=".7"/><g transform="translate(120,44) scale(1.3)"><ellipse rx="4" ry="5" fill="#17121F"/><circle cy="-5" r="2.600" fill="#17121F"/>${[-1, 1].map(sx => [[-4, -9], [-1, -10], [3, -9], [6, -6]].map(([dy, ex]) => `<path d="M0,${dy} q${sx * 6},${-3} ${sx * -ex},${3}" stroke="#17121F" stroke-width="1" fill="none"/>`).join('')).join('')}</g>
  <rect y="252" width="240" height="48" fill="url(#${id}k)"/><rect y="252" width="240" height="3" fill="#17121F"/>
  <rect width="240" height="300" filter="url(#${id}g)" opacity=".5" style="mix-blend-mode:soft-light"/></svg>`;
}
function coverAdv(id = 'ca') {
  const base = (o) => (x) => 196 + o + 8 * Math.sin(x / 38 + o);
  return `<svg viewBox="0 0 240 300" preserveAspectRatio="xMidYMid slice"><defs>
  <linearGradient id="${id}s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#DFF0F8"/><stop offset=".6" stop-color="#FFEADC"/><stop offset="1" stop-color="#FFD9C8"/></linearGradient>
  ${U.lacquerDefs(id + 'x')}${U.seigaiha(id + 'q', '#fff', 1.2, .3)}${grainDefs(id + 'g')}</defs>
  <rect width="240" height="300" fill="url(#${id}s)"/>
  <circle cx="120" cy="112" r="74" fill="#F4503F"/><circle cx="120" cy="112" r="96" fill="#FF9A85" opacity=".25"/>
  ${U.gull(36, 60, 1, '#5A7C96')}${U.gull(58, 46, .7, '#5A7C96')}${U.gull(204, 70, .8, '#5A7C96')}
  ${U.waveBand({ x1: 240, base: base(0), amp: 5, L: 36, fill: '#A9D3E6', h: 300 })}
  <g transform="translate(120,206) rotate(-4)">${U.lacquerBox({ id: id + 'x', s: 1.25 })}</g>
  ${U.waveBand({ x1: 240, base: base(18), amp: 7, L: 48, fill: '#4F93CB', h: 300, fingers: true, pattern: id + 'q', phase: 20 })}
  ${U.waveBand({ x1: 240, base: base(46), amp: 9, L: 60, fill: '#1B4C93', h: 300, fingers: true, phase: 8 })}
  ${U.waveBand({ x1: 240, base: base(78), amp: 10, L: 72, fill: '#12356F', h: 300, fingers: true, phase: 40 })}
  <rect width="240" height="300" filter="url(#${id}g)" opacity=".5" style="mix-blend-mode:soft-light"/></svg>`;
}

// soft aurora backdrop for UI screens (light) and splash (dark)
function aurora({ w = 892, h = 720, dark = false, id = 'au' } = {}) {
  const blobs = dark
    ? [[140, 120, 300, '#5B3BFF', .5], [760, 600, 320, '#FF5C7A', .32], [820, 80, 240, '#19C7A2', .28], [80, 680, 260, '#FF9F1A', .22], [446, 360, 240, '#7257FF', .3]]
    : [[80, 60, 300, '#C9BEFF', .7], [820, 120, 300, '#BFEFE6', .75], [760, 700, 320, '#FFD9C2', .7], [120, 700, 280, '#FFE9A8', .55], [446, 380, 260, '#E3DCFF', .6]];
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" preserveAspectRatio="xMidYMid slice"><defs><filter id="${id}b" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="70"/></filter>${grainDefs(id + 'g', .8, .45)}</defs>
  <rect width="${w}" height="${h}" fill="${dark ? '#110C33' : '#F4F2FF'}"/>
  <g filter="url(#${id}b)">${blobs.map(([x, y, r, c, o]) => `<circle cx="${x}" cy="${y}" r="${r}" fill="${c}" opacity="${o}"/>`).join('')}</g>
  <rect width="${w}" height="${h}" filter="url(#${id}g)" opacity="${dark ? .55 : .35}" style="mix-blend-mode:soft-light"/></svg>`;
}

module.exports = { worldDots, proj, coverLow, coverMed, coverAdv, aurora };
});
