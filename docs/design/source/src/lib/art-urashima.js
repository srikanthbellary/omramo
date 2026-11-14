// Code-drawn concept art: The Story of Urashima Taro (Japan).
// Visual language borrows from ukiyo-e woodblock prints (flat Prussian-blue wave bands, foam fingers, a hazy red sun)
// and the seigaiha wave pattern. Concept art only; final art should be commissioned from/reviewed by Japanese illustrators.
OMDEF('./art-urashima', function (require, module) {
const { rng, f1, grainDefs, grainRect } = require('./base');

const smooth = (t) => { t = Math.max(0, Math.min(1, t)); return t * t * (3 - 2 * t); };

function seigaiha(id = 'seig', c = '#fff', s = 1, op = 0.5) {
  const ring = (cx, cy) => [10, 7.4, 4.8, 2.2].map(r => `<circle cx="${cx}" cy="${cy}" r="${r}" fill="none" stroke="${c}" stroke-width="1.100"/>`).join('');
  return `<pattern id="${id}" width="${20 * s}" height="${10 * s}" patternUnits="userSpaceOnUse" patternTransform="scale(${s})"><g opacity="${op}">${ring(0, 10)}${ring(20, 10)}${ring(10, 5)}${ring(10, 15)}${ring(0, 0)}${ring(20, 0)}</g></pattern>`;
}
// one ukiyo-e wave band across [x0,x1]; top edge follows base(x) + scalloped crests with foam
function waveBand({ x0 = 0, x1 = 892, base, amp = 7, L = 46, phase = 0, fill, foam = '#fff', foamOp = .9, h = 720, pattern, fingers = false, seed = 1 }) {
  let d = `M${x0},${h} L${x0},${f1(base(x0))}`; let crest = ''; let fg = '';
  const r = rng(seed);
  for (let x = x0; x <= x1; x += 3) {
    const t = ((x + phase) % L) / L; // scallop: slow rise, quick fall
    const y = base(x) - amp * Math.pow(Math.sin(Math.PI * t), .7);
    d += ` L${x},${f1(y)}`; crest += `${x === x0 ? 'M' : 'L'}${x},${f1(y)} `;
  }
  if (fingers) for (let x = x0 + (L - (phase % L)); x <= x1; x += L) { const y = base(x); const s = .7 + r() * .6; fg += `<path d="M${f1(x - 9 * s)},${f1(y - amp * .7)} q${f1(4 * s)},${f1(-9 * s)} ${f1(11 * s)},${f1(-6 * s)} q${f1(-5 * s)},${f1(1 * s)} ${f1(-4 * s)},${f1(6 * s)}Z" fill="${foam}" opacity="${foamOp}"/><circle cx="${f1(x + 5 * s)}" cy="${f1(y - amp - 6 * s)}" r="${f1(1.5 * s)}" fill="${foam}" opacity="${foamOp * .8}"/><circle cx="${f1(x + 10 * s)}" cy="${f1(y - amp - 2 * s)}" r="${f1(1 * s)}" fill="${foam}" opacity="${foamOp * .7}"/>`; }
  return `<path d="${d} L${x1},${h}Z" fill="${fill}"/>${pattern ? `<path d="${d} L${x1},${h}Z" fill="url(#${pattern})"/>` : ''}<path d="${crest}" fill="none" stroke="${foam}" stroke-width="2.200" opacity="${foamOp}" stroke-linejoin="round"/>${fg}`;
}

// The tortoise (minogame-style: an old sea tortoise trailing a seaweed tail). Faces left; origin = shell centre at waterline.
function tortoise({ id = 'to', s = 1, tail = true, look = [0, 0], smile = true } = {}) {
  const hex = [[-14, -16], [6, -18], [-24, -6], [-4, -7], [16, -8], [-14, 2], [6, 1], [26, 0]].map(([x, y]) => `<path d="M${x - 7},${y} l3.500,-5 h7 l3.500,5 l-3.500,5 h-7Z" fill="none" stroke="#2F5A3A" stroke-width="1.400" opacity=".75"/>`).join('');
  return `<g transform="scale(${s})">
  ${tail ? `<g opacity=".9">${[0, 1, 2, 3, 4].map(i => `<path d="M34,${-4 + i * 2} C54,${-10 + i * 4} 70,${6 + i * 3} 92,${-2 + i * 5} C104,${-6 + i * 4} 112,${4 + i * 3} 124,${0 + i * 5}" stroke="${i % 2 ? '#3F8F5E' : '#2F7A52'}" stroke-width="2.200" fill="none" stroke-linecap="round"/>`).join('')}</g>` : ''}
  <path d="M-30,6 C-44,10 -52,20 -50,26 C-40,26 -30,18 -24,10Z" fill="#6E9A54"/>
  <path d="M20,8 C30,16 34,24 30,28 C22,26 14,18 12,10Z" fill="#5E8A4A"/>
  <!-- neck + head -->
  <path d="M-30,-2 C-42,-8 -48,-22 -50,-34 C-44,-40 -36,-38 -34,-30 C-32,-20 -26,-12 -20,-8Z" fill="url(#${id}skin)"/>
  <path d="M-42,-18 q5,-1 8,2 M-44,-26 q5,-2 9,1" stroke="#4F7A3E" stroke-width="1" fill="none" opacity=".6"/>
  <ellipse cx="-52" cy="-40" rx="14" ry="11" fill="url(#${id}skin)" transform="rotate(-14 -52 -40)"/>
  <circle cx="-56" cy="-43" r="4.200" fill="#fff"/><circle cx="${-57 + look[0]}" cy="${-43 + look[1]}" r="2.600" fill="#1B2B1D"/><circle cx="${-57.8 + look[0]}" cy="${-44 + look[1]}" r=".9" fill="#fff"/>
  <path d="M-61,-48 q5,-4 10,-1" stroke="#3F6B35" stroke-width="1.600" fill="none" stroke-linecap="round"/>
  ${smile ? `<path d="M-65,-36 q5,5 12,2" stroke="#2F5A3A" stroke-width="1.600" fill="none" stroke-linecap="round"/>` : ''}
  <circle cx="-64.500" cy="-41" r=".9" fill="#2F5A3A"/>
  <!-- shell -->
  <path d="M-38,4 C-38,-22 -16,-34 4,-34 C24,-34 40,-20 40,4 C24,10 -22,10 -38,4Z" fill="url(#${id}shell)"/>
  <g clip-path="url(#${id}clip)">${hex}<path d="M-34,-8 C-24,-26 -6,-32 8,-31" stroke="#C7E88A" stroke-width="4" fill="none" opacity=".4" stroke-linecap="round"/></g>
  <path d="M-38,4 C-22,10 24,10 40,4 C40,8 38,10 34,11 C16,15 -16,15 -34,11 C-37,10 -38,8 -38,4Z" fill="#E8C76A"/>
  </g>`;
}
function tortoiseDefs(id = 'to') {
  return `<linearGradient id="${id}shell" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7FB05A"/><stop offset="1" stop-color="#3F6B45"/></linearGradient>
  <linearGradient id="${id}skin" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#A9C873"/><stop offset="1" stop-color="#6E9A54"/></linearGradient>
  <clipPath id="${id}clip"><path d="M-38,4 C-38,-22 -16,-34 4,-34 C24,-34 40,-20 40,4 C24,10 -22,10 -38,4Z"/></clipPath>`;
}

// Urashima Taro standing in his boat (origin = feet; faces left)
function urashima({ id = 'ur', rod = true, hat = false } = {}) {
  let straw = '';
  for (let i = 0; i < 15; i++) { const x = -15 + i * 2.1; straw += `<path d="M${f1(x * .6)},-44 L${f1(x * 1.15)},-20" stroke="${i % 2 ? '#E9C877' : '#D4A94F'}" stroke-width="2.600" stroke-linecap="round"/>`; }
  return `<g>
  ${rod ? `<path d="M-14,-66 L-104,-134" stroke="#8A6A3A" stroke-width="2.200" stroke-linecap="round"/><path d="M-104,-134 C-112,-80 -118,-30 -120,22" stroke="#fff" stroke-width=".8" fill="none" opacity=".8"/>` : ''}
  <path d="M-7,-22 L-9,0 M6,-22 L8,0" stroke="#F2C9A0" stroke-width="6.500" stroke-linecap="round"/>
  <path d="M-13,0 h9 M4,0 h9" stroke="#E0B088" stroke-width="5" stroke-linecap="round"/>
  <!-- happi coat -->
  <path d="M-14,-80 C-18,-66 -18,-52 -16,-42 L16,-42 C18,-52 18,-66 14,-80 C6,-86 -6,-86 -14,-80Z" fill="url(#${id}coat)"/>
  <path d="M-2,-84 L4,-42 M2,-84 L-6,-60" stroke="#F4F7FB" stroke-width="2.400" fill="none"/>
  <g fill="#F4F7FB" opacity=".85">${[[-10, -70], [-11, -58], [10, -66], [11, -54], [-8, -48], [8, -76]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="1.500"/>`).join('')}</g>
  <path d="M-17,-48 h34" stroke="#E0453A" stroke-width="4.500" stroke-linecap="round"/>
  ${straw}
  <!-- arms -->
  <path d="M-12,-76 C-20,-72 -22,-66 -16,-64" stroke="url(#${id}coat)" stroke-width="8" fill="none" stroke-linecap="round"/><circle cx="-15" cy="-65" r="4" fill="#F2C9A0"/>
  <path d="M12,-76 C20,-68 20,-60 14,-56" stroke="url(#${id}coat)" stroke-width="8" fill="none" stroke-linecap="round"/><circle cx="13" cy="-55" r="4" fill="#F2C9A0"/>
  <!-- head -->
  <g transform="translate(-1,-98) rotate(-6)">
    <ellipse cx="0" cy="0" rx="13" ry="14" fill="#F6D2AC"/>
    <path d="M-13,-2 C-15,-14 -6,-18 2,-17 C10,-17 15,-10 13,0 C10,-8 4,-11 -3,-10 C-8,-9 -11,-6 -13,-2Z" fill="#1E1B2E"/>
    <path d="M1,-17 C0,-24 5,-27 8,-23 C9,-20 6,-17 4,-16Z" fill="#1E1B2E"/><path d="M1.500,-18 h6" stroke="#E0453A" stroke-width="1.800"/>
    <circle cx="-6.500" cy="1" r="1.700" fill="#1E1B2E"/><circle cx="2.500" cy="1.500" r="1.700" fill="#1E1B2E"/>
    <path d="M-6,7 q4,3.500 8,.5" stroke="#B5533A" stroke-width="1.500" fill="none" stroke-linecap="round"/>
    <ellipse cx="-9" cy="5" rx="2.600" ry="1.800" fill="#F58A7A" opacity=".5"/><ellipse cx="6" cy="6" rx="2.600" ry="1.800" fill="#F58A7A" opacity=".5"/>
  </g>
  ${hat ? `<path d="M-22,-106 L-1,-124 L20,-104 C6,-110 -8,-110 -22,-106Z" fill="#E9C877" stroke="#C99A3F" stroke-width="1"/>` : ''}
  </g>`;
}
const urashimaDefs = (id = 'ur') => `<linearGradient id="${id}coat" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2F5FB0"/><stop offset="1" stop-color="#1B3A7A"/></linearGradient>`;

// wooden fishing boat (origin = centre of waterline)
function boat({ id = 'bo', s = 1 } = {}) {
  return `<g transform="scale(${s})">
  <path d="M-92,-22 C-70,-10 -40,-6 0,-6 C44,-6 76,-12 98,-26 C92,-4 78,10 60,12 L-52,12 C-70,10 -86,-4 -92,-22Z" fill="url(#${id}wood)"/>
  <path d="M-92,-22 C-70,-10 -40,-6 0,-6 C44,-6 76,-12 98,-26 L96,-20 C74,-6 44,0 0,0 C-40,0 -68,-4 -90,-16Z" fill="#E2B27A"/>
  <path d="M-80,-4 C-40,4 40,4 84,-8 M-66,6 C-30,10 30,10 70,2" stroke="#6A4326" stroke-width="1.200" fill="none" opacity=".6"/>
  <path d="M98,-26 l10,-9" stroke="#8A5A34" stroke-width="4" stroke-linecap="round"/>
  </g>`;
}
const boatDefs = (id = 'bo') => `<linearGradient id="${id}wood" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#C08A54"/><stop offset="1" stop-color="#7A4E2E"/></linearGradient>`;
function pine(x, y, s, c = '#5E8F8A') {
  return `<path d="M${x},${y} q${3 * s},${-14 * s} ${-2 * s},${-30 * s}" stroke="${c}" stroke-width="${2.2 * s}" fill="none"/>${[[-10, -30, 16], [6, -36, 14], [-2, -42, 12], [-16, -22, 10], [10, -24, 10]].map(([dx, dy, r]) => `<ellipse cx="${x + dx * s}" cy="${y + dy * s}" rx="${r * s}" ry="${r * .36 * s}" fill="${c}"/>`).join('')}`;
}
const gull = (x, y, s, c = '#5A7C96') => `<path d="M${x - 8 * s},${y} q${4 * s},${-6 * s} ${8 * s},0 q${4 * s},${-6 * s} ${8 * s},0" stroke="${c}" stroke-width="${1.6 * s}" fill="none" stroke-linecap="round"/>`;

// Morning sea. The swell is low under the left-pane text and rises into the right pane.
function seaScene({ w = 892, h = 720, lowL = 648, lift = 196, boatOn = true, tortoiseOn = true, tIn = false, rise = [300, 640] } = {}) {
  const L = (x) => -lift * smooth((x - rise[0]) / (rise[1] - rise[0]));
  const bands = [
    { o: 0, amp: 3, L: 30, fill: '#CDE7F0', foamOp: .7 }, { o: 16, amp: 4, L: 36, fill: '#A9D3E6', foamOp: .8 }, { o: 36, amp: 5, L: 44, fill: '#7FB9DB', foamOp: .85, pattern: 'seig' },
    { o: 62, amp: 7, L: 54, fill: '#4F93CB', fingers: true }, { o: 96, amp: 9, L: 66, fill: '#2B6BB3', fingers: true, pattern: 'seig2' }, { o: 140, amp: 11, L: 80, fill: '#1B4C93', fingers: true }, { o: 200, amp: 13, L: 96, fill: '#12356F', fingers: true, pattern: 'seig2' },
  ];
  const yb = (i) => (x) => lowL + bands[i].o * (1 + .0 * x) + L(x) * (1 - i * .09);
  const bandSvg = (i, extra = {}) => waveBand({ base: yb(i), amp: bands[i].amp, L: bands[i].L, phase: i * 17, fill: bands[i].fill, foamOp: bands[i].foamOp || .92, pattern: bands[i].pattern, fingers: bands[i].fingers, seed: i + 3, x1: w, h, ...extra });
  const bx = 716, by = yb(3)(bx) + 4;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" preserveAspectRatio="xMidYMid slice">
  <defs>
    <linearGradient id="msky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E4F3FA"/><stop offset=".45" stop-color="#F0F8FB"/><stop offset=".7" stop-color="#FFF1E6"/><stop offset=".9" stop-color="#FFE3D3"/></linearGradient>
    <radialGradient id="rsun"><stop offset="0" stop-color="#FF6A52"/><stop offset=".8" stop-color="#F4503F"/><stop offset="1" stop-color="#F4503F" stop-opacity=".0"/></radialGradient>
    <radialGradient id="rsung"><stop offset="0" stop-color="#FFB199" stop-opacity=".7"/><stop offset="1" stop-color="#FFB199" stop-opacity="0"/></radialGradient>
    <linearGradient id="mist" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#F3F9FB" stop-opacity=".95"/><stop offset=".3" stop-color="#F3F9FB" stop-opacity=".6"/><stop offset=".62" stop-color="#F3F9FB" stop-opacity="0"/></linearGradient>
    <filter id="soft"><feGaussianBlur stdDeviation="1.500"/></filter><filter id="hz"><feGaussianBlur stdDeviation="14"/></filter>
    ${seigaiha('seig', '#fff', 1.1, .28)}${seigaiha('seig2', '#9CC8EE', 1.4, .2)}
    ${grainDefs()}${tortoiseDefs('to')}${urashimaDefs('ur')}${boatDefs('bo')}
  </defs>
  <rect width="${w}" height="${h}" fill="url(#msky)"/>
  <circle cx="800" cy="452" r="130" fill="url(#rsung)"/><circle cx="800" cy="452" r="50" fill="url(#rsun)" opacity=".92"/>
  <rect x="700" y="440" width="192" height="4" fill="#FFF1E6" opacity=".7"/><rect x="730" y="456" width="162" height="3" fill="#FFF1E6" opacity=".6"/><rect x="740" y="426" width="130" height="3" fill="#FFF1E6" opacity=".5"/>
  <!-- far headland with pines and a village roofline -->
  <g opacity=".7"><path d="M470,${f1(yb(0)(520) + 2)} C500,${f1(yb(0)(520) - 22)} 560,${f1(yb(0)(560) - 26)} 610,${f1(yb(0)(600) - 10)} C630,${f1(yb(0)(620) - 4)} 650,${f1(yb(0)(640))} 660,${f1(yb(0)(650) + 4)}Z" fill="#9DC3CF"/>
  ${pine(520, yb(0)(520) - 14, .7, '#7FAAB5')}${pine(548, yb(0)(548) - 20, .9, '#7FAAB5')}${pine(590, yb(0)(590) - 14, .6, '#7FAAB5')}</g>
  ${w > 800 ? gull(500, 440, .8) + gull(522, 430, .6) : ''}
  ${bandSvg(0)}${bandSvg(1)}
  <g opacity=".85"><path d="M852,${f1(yb(1)(852) - 3)} l-20,0 q8,7 20,5Z" fill="#6A7C92"/><path d="M842,${f1(yb(1)(852) - 3)} v-17 l10,13Z" fill="#fff"/></g>
  ${bandSvg(2)}${bandSvg(3)}
  ${boatOn ? `<g transform="translate(${bx},${f1(by)}) rotate(-5)">
    <g transform="translate(-10,-8)">${urashima({ id: 'ur' })}</g>
    <g transform="translate(46,-12)"><path d="M-10,0 C-12,-12 12,-12 10,0Z" fill="#C99A3F"/><path d="M-10,0 h20 M-8,-5 h16" stroke="#8A6A2A" stroke-width="1"/></g>
    ${tIn ? `<g transform="translate(-52,-12) scale(.6)">${tortoise({ id: 'to', tail: false, look: [1.5, -1.5] })}</g>` : ''}
    ${boat({ id: 'bo' })}
  </g>` : ''}
  ${bandSvg(4)}
  ${tortoiseOn && !tIn ? `<g transform="translate(578,${f1(yb(4)(578) + 6)}) rotate(4)">${tortoise({ id: 'to', s: 1.05, look: [1, -1] })}</g>
  <path d="M520,${f1(yb(4)(520) + 12)} q20,-7 40,0 t40,0 t40,0" stroke="#fff" stroke-width="2" fill="none" opacity=".8" stroke-linecap="round"/>` : ''}
  ${bandSvg(5)}${bandSvg(6)}
  <rect width="${w}" height="${h}" fill="url(#mist)" opacity=".55"/>
  ${grainRect(w, h, 'grain', .5)}
  </svg>`;
}

// ---------- Rin Gin / Ryūgū-jō, the Dragon King's palace under the sea ----------
const roof = (w, h, fill, edge = '#F4C95A') => `<path d="M${-w},-5 C${-w * .72},2 ${-w * .46},${-h * .5} ${-w * .2},${-h} L${w * .2},${-h} C${w * .46},${-h * .5} ${w * .72},2 ${w},-5 L${w * .93},5 L${-w * .93},5Z" fill="${fill}"/><path d="M${-w},-5 C${-w * .72},2 ${-w * .46},${-h * .5} ${-w * .2},${-h}" stroke="${edge}" stroke-width="2" fill="none"/><path d="M${w},-5 C${w * .72},2 ${w * .46},${-h * .5} ${w * .2},${-h}" stroke="${edge}" stroke-width="2" fill="none"/><path d="M${-w * .93},5 L${w * .93},5" stroke="${edge}" stroke-width="2.600" stroke-linecap="round"/><path d="M${-w * .2},${-h} L${w * .2},${-h}" stroke="${edge}" stroke-width="3" stroke-linecap="round"/><circle cx="${-w}" cy="-6" r="2.400" fill="${edge}"/><circle cx="${w}" cy="-6" r="2.400" fill="${edge}"/>`;
function hall(x, y, w, h, roofH, opts = {}) {
  const { win = 3, roofC = 'url(#prf)', wall = 'url(#pwall)' } = opts; let cols = '', wins = '';
  for (let i = 0; i <= win; i++) cols += `<rect x="${f1(-w + i * (2 * w / win) - 2)}" y="${-h}" width="4" height="${h}" fill="#B3261E"/>`;
  for (let i = 0; i < win; i++) wins += `<rect x="${f1(-w + (i + .5) * (2 * w / win) - (w / win) * .5)}" y="${f1(-h * .78)}" width="${f1(w / win)}" height="${f1(h * .56)}" rx="1.500" fill="url(#pwin)"/>`;
  return `<g transform="translate(${x},${y})"><rect x="${-w}" y="${-h}" width="${2 * w}" height="${h}" fill="${wall}"/>${wins}${cols}<rect x="${-w - 3}" y="-3" width="${2 * w + 6}" height="4" fill="#F4C95A"/><g transform="translate(0,${-h})">${roof(w * 1.36, roofH, roofC)}</g></g>`;
}
function coral(x, y, s, c, seed) {
  const r = rng(seed); let d = '';
  const br = (x0, y0, a, len, depth) => { const x1 = x0 + Math.cos(a) * len, y1 = y0 + Math.sin(a) * len; d += `<path d="M${f1(x0)},${f1(y0)} Q${f1((x0 + x1) / 2 + (r() - .5) * 6)},${f1((y0 + y1) / 2)} ${f1(x1)},${f1(y1)}" stroke="${c}" stroke-width="${f1(depth * 1.5 * s + .8)}" stroke-linecap="round" fill="none"/>`; if (depth > 0) { br(x1, y1, a - .35 - r() * .4, len * .72, depth - 1); br(x1, y1, a + .35 + r() * .4, len * .72, depth - 1); } else d += `<circle cx="${f1(x1)}" cy="${f1(y1)}" r="${f1(1.6 * s)}" fill="${c}"/>`; };
  br(x, y, -Math.PI / 2 + (r() - .5) * .3, 20 * s, 4);
  return d;
}
function kelp(x, y, hgt, seed, c = '#1F8F74') {
  const r = rng(seed); let s = '';
  for (let i = 0; i < 3; i++) { const dx = (i - 1) * 7, sw = 8 + r() * 10, hh = hgt * (.7 + r() * .4); s += `<path d="M${x + dx},${y} C${x + dx - sw},${f1(y - hh * .3)} ${x + dx + sw},${f1(y - hh * .6)} ${f1(x + dx - sw * .4)},${f1(y - hh)}" stroke="${i % 2 ? c : '#2FAE8A'}" stroke-width="${f1(4 + r() * 3)}" fill="none" stroke-linecap="round" opacity=".9"/>`; }
  return s;
}
const fish = (x, y, s, c, flip = 1, c2 = '#fff') => `<g transform="translate(${x},${y}) scale(${s * flip},${s})"><path d="M-10,0 C-5,-6 5,-6 10,0 C5,6 -5,6 -10,0Z" fill="${c}"/><path d="M9,0 l8,-5 v10Z" fill="${c}"/><path d="M-3,-4.500 q3,-5 7,-1Z" fill="${c}"/><circle cx="-6" cy="-1" r="1.300" fill="${c2}"/><circle cx="-6.200" cy="-1" r=".6" fill="#10203A"/></g>`;
function bubbles(n, seed, box) {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) { const x = box[0] + r() * box[2], y = box[1] + r() * box[3], rad = 1 + r() * 3.4; s += `<circle cx="${f1(x)}" cy="${f1(y)}" r="${f1(rad)}" fill="#BFF3FF" opacity="${f1(.08 + r() * .12)}"/><circle cx="${f1(x)}" cy="${f1(y)}" r="${f1(rad)}" fill="none" stroke="#DFFBFF" stroke-width=".7" opacity="${f1(.35 + r() * .4)}"/>`; }
  return s;
}
function palaceScene({ w = 432, h = 430, rider = true } = {}) {
  const cx = w / 2 + 14, gy = h - 78;
  let rays = '';
  for (const [x, ww, op] of [[60, 60, .07], [150, 40, .05], [230, 80, .08], [330, 50, .05], [390, 36, .04]]) rays += `<path d="M${x},-10 L${x + ww},-10 L${x + ww * 1.6 - 90},${h} L${x - ww * .6 - 90},${h}Z" fill="#CFF6FF" opacity="${op}"/>`;
  let school = '';
  const r = rng(77);
  for (let i = 0; i < 14; i++) school += fish(40 + r() * 120, 60 + r() * 60, .5 + r() * .3, i % 3 ? '#FF7A6B' : '#FFB3A8', -1);
  for (let i = 0; i < 9; i++) school += fish(310 + r() * 100, 150 + r() * 50, .45 + r() * .3, '#BFD9F2', 1);
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" preserveAspectRatio="xMidYMid slice">
  <defs>
    <linearGradient id="deep" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0C5C9A"/><stop offset=".45" stop-color="#08407C"/><stop offset="1" stop-color="#051F4D"/></linearGradient>
    <radialGradient id="pglow"><stop offset="0" stop-color="#FFD98A" stop-opacity=".55"/><stop offset=".5" stop-color="#3FD0D0" stop-opacity=".22"/><stop offset="1" stop-color="#3FD0D0" stop-opacity="0"/></radialGradient>
    <linearGradient id="prf" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2FC4B2"/><stop offset="1" stop-color="#0E7C86"/></linearGradient>
    <linearGradient id="pwall" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E8473A"/><stop offset="1" stop-color="#B3261E"/></linearGradient>
    <linearGradient id="pwin" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFF3B8"/><stop offset="1" stop-color="#FFC24D"/></linearGradient>
    <linearGradient id="pgate" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#CFE3F2"/></linearGradient>
    <linearGradient id="floor" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0C4A6E"/><stop offset="1" stop-color="#062447"/></linearGradient>
    <filter id="pblur"><feGaussianBlur stdDeviation="1.200"/></filter>
    ${grainDefs('pgrain')}${tortoiseDefs('pt')}${urashimaDefs('pu')}${seigaiha('pseig', '#7FD6F2', 1.6, .16)}
  </defs>
  <rect width="${w}" height="${h}" fill="url(#deep)"/><rect width="${w}" height="${h}" fill="url(#pseig)" opacity=".5"/>
  ${rays}
  <path d="M0,${h - 120} C40,${h - 170} 80,${h - 150} 110,${h - 110} L110,${h} L0,${h}Z M${w},${h - 150} C${w - 40},${h - 190} ${w - 90},${h - 150} ${w - 110},${h - 100} L${w - 110},${h} L${w},${h}Z" fill="#06305F" opacity=".8"/>
  <circle cx="${cx}" cy="${gy - 110}" r="210" fill="url(#pglow)"/>
  <!-- palace: stacked halls -->
  ${hall(cx - 96, gy - 34, 34, 34, 22, { win: 3 })}${hall(cx + 96, gy - 34, 34, 34, 22, { win: 3 })}
  ${hall(cx, gy - 44, 78, 46, 26, { win: 5 })}
  ${hall(cx, gy - 116, 52, 34, 24, { win: 3 })}
  ${hall(cx, gy - 176, 30, 26, 22, { win: 2 })}
  <path d="M${cx},${gy - 226} v-22" stroke="#F4C95A" stroke-width="2.600" stroke-linecap="round"/><circle cx="${cx}" cy="${gy - 250}" r="5" fill="#FFE9A8"/><circle cx="${cx}" cy="${gy - 250}" r="12" fill="#FFE9A8" opacity=".25"/>
  <!-- the great gate (white arched base, vermilion gatehouse) -->
  <g transform="translate(${cx},${gy})">
    <path d="M-50,0 C-48,-22 -42,-40 -36,-52 L36,-52 C42,-40 48,-22 50,0Z" fill="url(#pgate)"/>
    <path d="M-15,0 V-20 C-15,-40 15,-40 15,0Z" fill="#06305F"/><path d="M-15,0 V-20 C-15,-40 15,-40 15,0" fill="none" stroke="#F4C95A" stroke-width="2.200"/>
    <path d="M-11,0 V-18 C-11,-33 11,-33 11,0Z" fill="#FFD98A" opacity=".55"/>
    <rect x="-40" y="-54" width="80" height="4" fill="#F4C95A"/>
    <rect x="-30" y="-74" width="60" height="20" fill="url(#pwall)"/>${[-18, -6, 6, 18].map(x => `<rect x="${x - 4}" y="-70" width="8" height="12" rx="1" fill="url(#pwin)"/>`).join('')}
    <g transform="translate(0,-74)">${roof(46, 20, 'url(#prf)')}</g>
  </g>
  <!-- sea floor, coral, kelp -->
  <path d="M0,${gy - 2} C80,${gy - 12} 150,${gy + 4} ${cx - 50},${gy} L${cx + 50},${gy} C300,${gy + 6} 380,${gy - 14} ${w},${gy - 4} L${w},${h} L0,${h}Z" fill="url(#floor)"/>
  <path d="M${cx - 14},${gy} L${cx - 60},${h} L${cx + 60},${h} L${cx + 14},${gy}Z" fill="#CFE3F2" opacity=".22"/>
  ${kelp(28, h, 150, 3)}${kelp(72, h, 96, 9)}${kelp(w - 26, h, 170, 5)}${kelp(w - 70, h, 90, 12, '#177A66')}
  ${coral(108, h - 34, 1.25, '#FF6B7A', 4)}${coral(52, h - 20, .9, '#FFB3BD', 8)}${coral(w - 108, h - 30, 1.3, '#FF8A5C', 6)}${coral(w - 50, h - 18, .8, '#F4F7FB', 10)}${coral(150, h - 12, .7, '#F4F7FB', 14)}
  ${[[130, h - 16], [w - 150, h - 14], [190, h - 8]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="5" fill="#fff" opacity=".9"/><circle cx="${x - 1.5}" cy="${y - 1.5}" r="1.600" fill="#BFE6FF"/>`).join('')}
  ${school}
  ${fish(60, 250, 1.3, '#E8473A', -1, '#fff')}${fish(350, 96, 1.2, '#F4C95A', 1)}
  ${rider ? `<g transform="translate(70,${h - 186}) rotate(-12) scale(.56)"><g transform="translate(6,-30) scale(-.8,.8)">${urashima({ id: 'pu', rod: false })}</g><g transform="scale(-1,1)">${tortoise({ id: 'pt', s: 1, look: [0, 0] })}</g></g>
  ${bubbles(8, 5, [10, h - 230, 50, 50])}` : ''}
  ${bubbles(34, 21, [0, 0, w, h])}
  <rect width="${w}" height="${h}" filter="url(#pgrain)" opacity=".5" style="mix-blend-mode:soft-light"/>
  </svg>`;
}

// the tamatebako — the lacquer box Urashima must never open (origin = centre of box base)
function lacquerBox({ id = 'bx', s = 1, wisp = true } = {}) {
  return `<g transform="scale(${s})">
  ${wisp ? `<path d="M10,-64 C-10,-84 24,-100 4,-124 C-8,-138 10,-150 4,-162" stroke="#fff" stroke-width="5" fill="none" opacity=".35" stroke-linecap="round" filter="url(#${id}b)"/>` : ''}
  <ellipse cx="0" cy="2" rx="62" ry="7" fill="#000" opacity=".22"/>
  <path d="M-52,-40 L52,-40 L50,0 L-50,0Z" fill="url(#${id}lac)"/>
  <path d="M-56,-58 L56,-58 L56,-40 L-56,-40Z" fill="url(#${id}lid)"/><path d="M-56,-58 L56,-58" stroke="#fff" stroke-width="1.600" opacity=".35"/>
  <g fill="none" stroke="#F4C95A" stroke-width="1.300" opacity=".95">${[-40, -22, 22, 40].map(x => `<path d="M${x - 9},-6 a9,9 0 0 1 18,0 M${x - 6},-6 a6,6 0 0 1 12,0 M${x - 3},-6 a3,3 0 0 1 6,0"/>`).join('')}<path d="M-50,-6 h100"/></g>
  <g fill="#F4C95A">${[[-38, -24], [34, -27]].map(([x, y]) => [0, 72, 144, 216, 288].map(a => `<circle cx="${f1(x + Math.cos(a * Math.PI / 180) * 4)}" cy="${f1(y + Math.sin(a * Math.PI / 180) * 4)}" r="2.400"/>`).join('') + `<circle cx="${x}" cy="${y}" r="1.400" fill="#E0453A"/>`).join('')}</g>
  <rect x="-6" y="-58" width="12" height="58" fill="#E0453A"/><rect x="-6" y="-58" width="4" height="58" fill="#FF7A6B" opacity=".6"/>
  <path d="M0,-60 C-16,-76 -30,-66 -22,-58 C-16,-54 -6,-56 0,-60 C16,-76 30,-66 22,-58 C16,-54 6,-56 0,-60Z" fill="#E0453A"/><circle cx="0" cy="-60" r="4.600" fill="#B3261E"/>
  <path d="M-3,-58 C-12,-46 -16,-38 -20,-26 M3,-58 C12,-46 16,-38 20,-26" stroke="#E0453A" stroke-width="2.600" fill="none" stroke-linecap="round"/>
  <path d="M-23,-27 l6,2 l-5,14 l-5,-2Z M23,-27 l-6,2 l5,14 l5,-2Z" fill="#F4C95A"/>
  </g>`;
}
const lacquerDefs = (id = 'bx') => `<linearGradient id="${id}lac" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2B2338"/><stop offset=".5" stop-color="#14101C"/><stop offset="1" stop-color="#0A0810"/></linearGradient><linearGradient id="${id}lid" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#3A3048"/><stop offset=".4" stop-color="#1A1524"/><stop offset="1" stop-color="#0E0B16"/></linearGradient><filter id="${id}b"><feGaussianBlur stdDeviation="2.500"/></filter>`;

const urashimaHead = () => `<g><ellipse cx="0" cy="0" rx="13" ry="14" fill="#F6D2AC"/><path d="M-13,-2 C-15,-14 -6,-18 2,-17 C10,-17 15,-10 13,0 C10,-8 4,-11 -3,-10 C-8,-9 -11,-6 -13,-2Z" fill="#1E1B2E"/><path d="M1,-17 C0,-24 5,-27 8,-23 C9,-20 6,-17 4,-16Z" fill="#1E1B2E"/><circle cx="-5" cy="1" r="1.700" fill="#1E1B2E"/><circle cx="4" cy="1" r="1.700" fill="#1E1B2E"/><path d="M-4,7 q4,3.500 8,0" stroke="#B5533A" stroke-width="1.500" fill="none" stroke-linecap="round"/><ellipse cx="-8" cy="5" rx="2.600" ry="1.800" fill="#F58A7A" opacity=".5"/><ellipse cx="8" cy="5" rx="2.600" ry="1.800" fill="#F58A7A" opacity=".5"/></g>`;
const faceUrashima = () => `<svg viewBox="-20 -24 40 40"><rect x="-20" y="-24" width="40" height="40" fill="#CFE6F7"/><g transform="translate(0,-2)">${urashimaHead()}</g></svg>`;
const faceTortoise = (id = 'ft') => `<svg viewBox="-72 -60 44 44"><defs>${tortoiseDefs(id)}</defs><rect x="-72" y="-60" width="44" height="44" fill="#FFE3D3"/><g transform="translate(2,4)">${tortoise({ id, tail: false })}</g></svg>`;

module.exports = { seigaiha, waveBand, tortoise, tortoiseDefs, urashima, urashimaDefs, boat, boatDefs, seaScene, palaceScene, lacquerBox, lacquerDefs, faceUrashima, faceTortoise, fish, bubbles, coral, kelp, gull, pine, smooth };
});
