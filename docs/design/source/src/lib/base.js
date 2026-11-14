// Omramo designs v2 — shared device shell, tokens, type system, iOS chrome.
// Point canvas: iPhone Duo unfolded = 432 + 28 (hinge) + 432 = 892 x 720 pt, rendered @3x.
// Folded = one pane, 432 x 720 pt.

// Modules are plain browser scripts: screen.html defines OMDEF/require so Chrome can build and render with no toolchain.
OMDEF('./base', function (require, module) {
const PANE_W = 432, PANE_H = 720, HINGE = 28;
const DUO_W = PANE_W * 2 + HINGE;

// Seeded PRNG so procedural art is stable between renders.
function rng(seed) {
  let s = seed >>> 0;
  return () => {
    s |= 0; s = (s + 0x6D2B79F5) | 0;
    let t = Math.imul(s ^ (s >>> 15), 1 | s);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const f1 = (n) => Math.round(n * 10) / 10;

const css = `
@font-face{font-family:"Bricolage";src:url("../fonts/BricolageGrotesque.ttf") format("truetype");font-weight:200 800;font-stretch:75% 100%;font-display:block}
@font-face{font-family:"Atkinson";src:url("../fonts/AtkinsonHyperlegibleNext.ttf") format("truetype");font-weight:200 800;font-style:normal;font-display:block}
@font-face{font-family:"Atkinson";src:url("../fonts/AtkinsonHyperlegibleNext-Italic.ttf") format("truetype");font-weight:200 800;font-style:italic;font-display:block}
@font-face{font-family:"Inter";src:url("../fonts/Inter.ttf") format("truetype");font-weight:100 900;font-display:block}
:root{
  --night:#130F36; --night2:#1F1856; --cloud:#F3F1FF; --ink:#16123D;
  --coral:#FF6A4D; --sun:#FFC43D; --mint:#19C7A2; --sky:#3FB4FF; --violet:#7257FF; --rose:#FF5C8A;
  --low:#12B58F; --med:#FF9F1A; --adv:#6E56FF;
  --display:"Bricolage",sans-serif; --read:"Atkinson",sans-serif; --sys:"Inter",sans-serif;
}
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:100%;height:100%;overflow:hidden;background:#000;-webkit-font-smoothing:antialiased;text-rendering:geometricPrecision}
body{position:relative;font-family:var(--read);color:var(--ink)}
.scene{position:absolute;inset:0;z-index:0}
.scene svg{display:block;width:100%;height:100%}
.pane{position:absolute;top:0;width:${PANE_W}px;height:${PANE_H}px;overflow:hidden;z-index:1}
.pane.L{left:0}.pane.R{left:${PANE_W + HINGE}px}
.hinge{position:absolute;left:${PANE_W}px;top:0;width:${HINGE}px;height:${PANE_H}px;background:#000;z-index:5}
body.folded .pane.L{left:0}

/* ---------- iOS status bar + home indicator ---------- */
.sb{position:absolute;top:0;left:0;right:0;height:44px;z-index:40;font-family:var(--sys);font-weight:600;font-size:16px;letter-spacing:-.2px;color:var(--sbc,#16123D)}
.sb .time{position:absolute;left:30px;top:15px;line-height:20px;font-feature-settings:"tnum","ss01"}
.sb .sys{position:absolute;right:26px;top:16px;display:flex;gap:6px;align-items:center;height:18px}
.sb svg{display:block}
.island{position:absolute;top:11px;left:50%;margin-left:-58px;width:116px;height:33px;border-radius:20px;background:#000;z-index:41}
.homebar{position:absolute;bottom:8px;left:50%;margin-left:-67px;width:134px;height:5px;border-radius:3px;background:var(--hbc,rgba(22,18,61,.82));z-index:40}

/* ---------- glass controls ---------- */
.glass{background:var(--glass,rgba(255,255,255,.62));-webkit-backdrop-filter:blur(18px) saturate(180%);backdrop-filter:blur(18px) saturate(180%);
  box-shadow:inset 0 0 0 .5px var(--glass-edge,rgba(255,255,255,.9)),inset 0 1px 0 var(--glass-hi,rgba(255,255,255,.85)),0 6px 18px var(--glass-shadow,rgba(20,40,80,.14)),0 1px 2px rgba(0,0,0,.08)}
.dark{--glass:rgba(40,28,84,.46);--glass-edge:rgba(255,255,255,.16);--glass-hi:rgba(255,255,255,.2);--glass-shadow:rgba(0,0,0,.35);--sbc:#fff;--hbc:rgba(255,255,255,.9)}
.rb{position:absolute;width:40px;height:40px;border-radius:20px;display:flex;align-items:center;justify-content:center;color:var(--chrome,#16123D);z-index:30}
.cap{position:absolute;height:40px;border-radius:20px;display:flex;align-items:center;gap:14px;padding:0 15px;color:var(--chrome,#16123D);z-index:30;font-family:var(--display);font-weight:600;font-size:14px}
.cap .aa{font-family:var(--read);font-weight:700;font-size:16px;letter-spacing:-.3px}.cap .aa small{font-size:12px}
.dark .rb,.dark .cap{--chrome:#fff}

/* ---------- reader chrome ---------- */
.crumb{position:absolute;left:70px;top:53px;right:22px;z-index:30;font-family:var(--display);line-height:1.15;color:var(--chrome2,rgba(22,18,61,.9))}
.crumb b{display:block;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-weight:650;font-size:14px;letter-spacing:-.1px;font-variation-settings:"opsz" 14,"wdth" 95}
.crumb span{display:block;font-weight:500;font-size:11.5px;opacity:.66;margin-top:3px;letter-spacing:.1px}
.dark .crumb{--chrome2:#fff}
.foot{position:absolute;left:28px;right:28px;bottom:26px;height:34px;display:flex;align-items:center;gap:10px;z-index:30;font-family:var(--display);font-size:12px;font-weight:600;color:var(--chrome2,rgba(22,18,61,.86))}
.dark .foot{--chrome2:#fff}
.chip{display:inline-flex;align-items:center;gap:6px;height:28px;padding:0 11px 0 9px;border-radius:14px;font-family:var(--display);font-weight:650;font-size:12px;letter-spacing:.1px;white-space:nowrap}
.tierglyph{display:inline-flex;align-items:flex-end;gap:2px;height:11px}
.tierglyph i{display:block;width:3.5px;border-radius:1.5px;background:currentColor;opacity:.28}
.tierglyph i.on{opacity:1}
.tierglyph i:nth-child(1){height:5px}.tierglyph i:nth-child(2){height:8px}.tierglyph i:nth-child(3){height:11px}
.pages{display:flex;gap:3px;align-items:center}
.pg{gap:9px!important;padding:0 12px!important}
.pages i{display:block;width:10px;height:4px;border-radius:2px;background:currentColor;opacity:.22}
.pages i.done{opacity:.6}.pages i.now{opacity:1;width:20px;background:var(--accent,var(--coral))}
.next{position:absolute;right:24px;bottom:24px;width:60px;height:60px;border-radius:30px;z-index:30;display:flex;align-items:center;justify-content:center;color:#fff;
  background:radial-gradient(circle at 32% 26%,var(--nx1,#FF9A66),var(--nx2,#FF5B3D) 62%,var(--nx3,#E8432B));
  box-shadow:inset 0 1.5px 0 rgba(255,255,255,.55),inset 0 -3px 6px rgba(120,20,0,.25),0 10px 22px var(--nxs,rgba(232,67,43,.42)),0 2px 4px rgba(0,0,0,.18)}
.next::before{content:"";position:absolute;inset:-6px;border-radius:40px;border:2px solid var(--nxr,rgba(255,255,255,.55))}
.prev{position:absolute;left:24px;bottom:34px;z-index:30}

/* ---------- reading typography (the Omramo "Open Page" system) ---------- */
.txt{position:absolute;z-index:10;font-family:var(--read);color:var(--tx,#12203A);font-kerning:normal;font-feature-settings:"kern","liga";hanging-punctuation:first;text-wrap:pretty}
.txt p{margin:0}
.t-low{font-size:23.5px;line-height:37px;font-weight:460;letter-spacing:.1px;word-spacing:.4px}
.t-low p+p{margin-top:17px}
.t-low .lead{font-family:var(--display);font-weight:720;font-size:32px;line-height:38px;letter-spacing:-.6px;word-spacing:0;font-variation-settings:"opsz" 48,"wdth" 92;display:block;text-wrap:balance}
.t-med{font-size:19.5px;line-height:32px;font-weight:430;letter-spacing:.1px;word-spacing:.6px}
.t-med p+p{margin-top:16px}
.t-med .lead{font-family:var(--display);font-weight:700;font-size:27px;line-height:33px;letter-spacing:-.5px;word-spacing:0;font-variation-settings:"opsz" 36,"wdth" 90}
.t-adv{font-size:16.5px;line-height:27px;font-weight:420;letter-spacing:.05px;word-spacing:.3px}
.t-adv p+p{margin-top:12px}
.t-adv .lead{font-family:var(--display);font-weight:680;font-size:21px;line-height:27px;letter-spacing:-.3px;font-variation-settings:"opsz" 24,"wdth" 88}
/* speech: every voice has its own colour + weight, with a tiny face chip where a voice starts */
.say{font-weight:640;color:var(--vc)}
.who{display:inline-block;vertical-align:-.22em;width:1.12em;height:1.12em;border-radius:50%;margin:0 .22em 0 .04em;overflow:hidden;box-shadow:0 0 0 1.5px var(--vc),0 2px 5px rgba(0,0,0,.18);background:var(--vb,#fff)}
.who svg{display:block;width:100%;height:100%}
/* tap-to-see words */
.tap{position:relative;font-weight:640;white-space:nowrap;padding:0 .18em;margin:0 -.06em;border-radius:.34em;color:var(--tapc,inherit);
  background:linear-gradient(180deg,transparent 0,transparent 8%,var(--tapbg,rgba(255,196,61,.5)) 8%,var(--tapbg2,rgba(255,170,61,.38)) 92%,transparent 92%);
  box-shadow:inset 0 -2px 0 var(--tapline,rgba(240,140,20,.9))}
.tap::after{content:"";display:inline-block;width:.5em;height:.5em;margin-left:.16em;vertical-align:.5em;background:var(--tapline2,#F08A12);
  clip-path:polygon(50% 0,62% 38%,100% 50%,62% 62%,50% 100%,38% 62%,0 50%,38% 38%)}
.tap.on{background:var(--tapon,#FFC43D);box-shadow:0 0 0 3px var(--taponring,rgba(255,196,61,.35)),0 6px 16px rgba(255,150,30,.35);color:#16123D}
.name{font-weight:640;text-decoration:underline;text-decoration-style:dotted;text-decoration-thickness:2px;text-underline-offset:.2em;text-decoration-color:var(--vc,currentColor);white-space:nowrap}
.pop{font-family:var(--display);font-weight:760;font-style:normal;letter-spacing:-.2px;font-variation-settings:"opsz" 30,"wdth" 86;color:var(--popc,var(--coral))}

/* ---------- generic UI ---------- */
.h-d{font-family:var(--display);font-variation-settings:"opsz" 60,"wdth" 90;letter-spacing:-.8px;font-weight:740}
.ui{font-family:var(--display)}
`;

// ---------- icons (hand-drawn, SF-Symbols-like weights; not Apple assets) ----------
const I = {
  back: `<svg width="12" height="20" viewBox="0 0 12 20" fill="none"><path d="M10 2 2.5 10 10 18" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  fwd: `<svg width="26" height="22" viewBox="0 0 26 22" fill="none"><path d="M3 11h19M14 3l8.5 8-8.5 8" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  prev: `<svg width="18" height="16" viewBox="0 0 26 22" fill="none"><path d="M23 11H4M12 3 3.5 11l8.500 8" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  bookmark: `<svg width="14" height="19" viewBox="0 0 14 19" fill="none"><path d="M2 3.2C2 2.5 2.5 2 3.200 2h7.600c.7 0 1.200.5 1.200 1.200V17l-5-3.800L2 17V3.200Z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/></svg>`,
  pin: (c = 'currentColor', s = 13) => `<svg width="${s}" height="${s * 1.25}" viewBox="0 0 16 20"><path d="M8 0C3.600 0 .2 3.400.2 7.700c0 5.300 6.600 11.500 7.200 12 .3.300.9.300 1.200 0 .6-.5 7.200-6.700 7.200-12C15.800 3.400 12.400 0 8 0Z" fill="${c}"/><circle cx="8" cy="7.600" r="3" fill="#fff"/></svg>`,
  x: `<svg width="13" height="13" viewBox="0 0 13 13" fill="none"><path d="M1.500 1.500l10 10M11.500 1.500l-10 10" stroke="currentColor" stroke-width="2.300" stroke-linecap="round"/></svg>`,
  lock: `<svg width="13" height="16" viewBox="0 0 13 16" fill="none"><rect x="1" y="6.500" width="11" height="8.500" rx="2.400" fill="currentColor"/><path d="M3.400 7V4.600a3.100 3.100 0 0 1 6.200 0V7" stroke="currentColor" stroke-width="1.800"/></svg>`,
  flame: `<svg width="15" height="19" viewBox="0 0 15 19"><path d="M7.800.3c.5 3-1.300 4.400-2.900 6.300C3.300 8.500 1 10.300 1 13.300 1 16.500 3.800 19 7.500 19s6.500-2.500 6.500-5.900c0-2.300-1-4.100-2.100-5.400-.3 1.200-.9 2-1.700 2.400.3-3.600-.5-7.600-2.400-9.800Z" fill="currentColor"/></svg>`,
  check: `<svg width="13" height="11" viewBox="0 0 13 11" fill="none"><path d="M1.500 5.800 4.800 9l6.700-7.500" stroke="currentColor" stroke-width="2.400" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  spark: (c = 'currentColor', s = 14) => `<svg width="${s}" height="${s}" viewBox="0 0 20 20"><path d="M10 0c.8 5.400 4.600 9.200 10 10-5.400.8-9.200 4.600-10 10C9.200 14.600 5.400 10.800 0 10 5.400 9.200 9.200 5.400 10 0Z" fill="${c}"/></svg>`,
  book: `<svg width="20" height="17" viewBox="0 0 20 17" fill="none"><path d="M10 3.200C8.300 1.800 5.800 1.200 2.600 1.300c-.6 0-1.100.5-1.100 1.100v10.300c0 .6.5 1.100 1.100 1.100 3-.1 5.500.5 7.400 1.900 1.900-1.400 4.400-2 7.400-1.900.6 0 1.100-.5 1.100-1.100V2.400c0-.6-.5-1.100-1.100-1.100-3.200-.1-5.700.5-7.400 1.900Zm0 0v12.300" stroke="currentColor" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/></svg>`,
  person2: `<svg width="22" height="16" viewBox="0 0 22 16" fill="currentColor"><circle cx="8" cy="4.200" r="3.700"/><path d="M.8 15c0-3.800 3.200-6 7.200-6s7.200 2.200 7.200 6c0 .6-.4 1-1 1H1.800c-.6 0-1-.4-1-1Z"/><circle cx="16.600" cy="5" r="2.900" opacity=".55"/><path d="M16.400 9.300c3 0 5.100 1.800 5.100 4.700 0 .5-.4.900-.9.900h-3.800c.1-2.300-.5-4.100-1.800-5.500.4-.1.900-.1 1.400-.1Z" opacity=".55"/></svg>`,
  gear: `<svg width="18" height="18" viewBox="0 0 20 20" fill="none"><circle cx="10" cy="10" r="3.200" stroke="currentColor" stroke-width="2"/><path d="M10 1.500v2.600M10 15.900v2.600M1.500 10h2.600M15.900 10h2.600M4 4l1.800 1.800M14.200 14.200 16 16M16 4l-1.800 1.800M5.800 14.200 4 16" stroke="currentColor" stroke-width="2.200" stroke-linecap="round"/></svg>`,
  chevR: `<svg width="8" height="13" viewBox="0 0 8 13" fill="none"><path d="M1.500 1.500 6.500 6.500l-5 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  ret: `<svg width="18" height="16" viewBox="0 0 18 16" fill="none"><path d="M6.500 2 2 6.500 6.500 11M2.500 6.500H11a5 5 0 0 1 5 5V14" stroke="currentColor" stroke-width="2.400" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  globe: `<svg width="17" height="17" viewBox="0 0 18 18" fill="none"><circle cx="9" cy="9" r="7.800" stroke="currentColor" stroke-width="1.800"/><path d="M1.500 9h15M9 1.200c2.300 2.300 3.400 4.900 3.400 7.800S11.300 14.500 9 16.800C6.700 14.500 5.600 11.900 5.600 9S6.700 3.500 9 1.200Z" stroke="currentColor" stroke-width="1.600"/></svg>`,
  home: `<svg width="19" height="18" viewBox="0 0 19 18" fill="currentColor"><path d="M8.300.9a1.800 1.800 0 0 1 2.400 0l7.300 6.500c.6.500.2 1.500-.6 1.500H16v7.300c0 .9-.7 1.600-1.600 1.600h-2.700v-5.200c0-.6-.5-1.100-1.100-1.100H8.400c-.6 0-1.100.5-1.100 1.100v5.200H4.600c-.9 0-1.600-.7-1.600-1.600V8.900H1.600c-.8 0-1.200-1-.6-1.500L8.300.9Z"/></svg>`,
  shelf: `<svg width="19" height="18" viewBox="0 0 19 18" fill="currentColor"><rect x="1.500" y="1" width="4" height="13" rx="1.200"/><rect x="7" y="3.500" width="4" height="10.500" rx="1.200"/><rect x="12.300" y="1.900" width="4" height="12.300" rx="1.200" transform="rotate(-12 14.300 8)"/><rect x="0" y="15.300" width="19" height="2.200" rx="1.100"/></svg>`,
};

const tierGlyph = (n) => `<span class="tierglyph">${[1, 2, 3].map(i => `<i class="${i <= n ? 'on' : ''}"></i>`).join('')}</span>`;

function statusTime(t = '7:18') { return `<div class="sb"><div class="time">${t}</div></div>`; }
function statusSys() {
  return `<div class="sb"><div class="sys">
  <svg width="18" height="12" viewBox="0 0 18 12" fill="currentColor"><rect x="0" y="8" width="3.200" height="4" rx=".9"/><rect x="4.900" y="5.500" width="3.200" height="6.500" rx=".9"/><rect x="9.800" y="2.800" width="3.200" height="9.200" rx=".9"/><rect x="14.700" y="0" width="3.200" height="12" rx=".9"/></svg>
  <svg width="17" height="12" viewBox="0 0 17 12" fill="currentColor"><path d="M8.500 2.400c2.400 0 4.600.9 6.300 2.500.2.200.4.200.6 0l.9-.9c.2-.2.200-.5 0-.7C14.200 1.300 11.400.2 8.500.2S2.800 1.300.7 3.300c-.2.2-.2.5 0 .7l.9.9c.2.2.4.2.6 0 1.700-1.600 3.900-2.500 6.300-2.500Zm0 3.900c1.300 0 2.500.5 3.500 1.300.2.2.4.200.6 0l.9-.9c.2-.2.200-.5 0-.7-1.400-1.200-3.100-1.900-5-1.900s-3.600.7-5 1.900c-.2.2-.2.5 0 .7l.9.9c.2.200.4.200.6 0 1-.8 2.200-1.300 3.500-1.300Zm2.300 2.500c-.6-.6-1.400-.9-2.300-.9s-1.700.3-2.300.9c-.2.200-.2.5 0 .7l2 2c.2.200.4.200.6 0l2-2c.2-.2.2-.5 0-.7Z"/></svg>
  <svg width="27" height="13" viewBox="0 0 27 13" fill="none"><rect x=".5" y=".5" width="23" height="12" rx="3.800" stroke="currentColor" opacity=".4"/><rect x="2" y="2" width="16.500" height="9" rx="2.400" fill="currentColor"/><path d="M25 4.500v4c.8-.3 1.500-1.100 1.500-2s-.7-1.700-1.500-2Z" fill="currentColor" opacity=".45"/></svg>
  </div></div>`;
}
function statusFull(t = '7:18') {
  return `<div class="island"></div>` + statusTime(t) + statusSys();
}
const homebar = `<div class="homebar"></div>`;

// Page wrapper. `scene` is an SVG string drawn across the whole canvas (behind both panes and the hinge).
function duoPage({ title, scene = '', left = '', right = '', extraCss = '', lClass = '', rClass = '', time }) {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><title>${title}</title>
<meta name="viewport" content="width=${DUO_W}, initial-scale=1"><style>${css}${extraCss}</style></head>
<body class="duo" style="width:${DUO_W}px;height:${PANE_H}px">
<div class="scene">${scene}</div>
<div class="pane L ${lClass}">${statusTime(time)}${left}${homebar}</div>
<div class="hinge"></div>
<div class="pane R ${rClass}">${statusSys()}${right}${homebar}</div>
</body></html>`;
}
function foldedPage({ title, scene = '', body = '', extraCss = '', cls = '', time }) {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><title>${title}</title>
<meta name="viewport" content="width=${PANE_W}, initial-scale=1"><style>${css}${extraCss}</style></head>
<body class="folded" style="width:${PANE_W}px;height:${PANE_H}px">
<div class="scene">${scene}</div>
<div class="pane L ${cls}">${statusFull(time)}${body}${homebar}</div>
</body></html>`;
}

// Film grain / paint-tooth overlay used by every scene so flat vector shapes get a printed, tactile finish.
function grainDefs(id = 'grain', freq = 0.85, alpha = 0.5) {
  return `<filter id="${id}" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="${freq}" numOctaves="2" seed="7" result="n"/><feColorMatrix in="n" type="matrix" values="0 0 0 0 .5  0 0 0 0 .5  0 0 0 0 .5  ${alpha} ${alpha} ${alpha} 0 ${-alpha * 0.9}"/></filter>`;
}
const grainRect = (w, h, id = 'grain', op = 0.5, blend = 'soft-light') => `<rect width="${w}" height="${h}" filter="url(#${id})" opacity="${op}" style="mix-blend-mode:${blend}"/>`;

module.exports = { PANE_W, PANE_H, HINGE, DUO_W, rng, f1, css, I, tierGlyph, duoPage, foldedPage, statusFull, statusTime, statusSys, homebar, grainDefs, grainRect };
});
