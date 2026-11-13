// Omramo designs v2 — app screens other than the three plain reading spreads.
OMDEF('./screens-ui', function (require, module) {
const B = require('./base');
const J = require('./art-jataka'), A = require('./art-anansi'), U = require('./art-urashima'), R = require('./art-brand');
const { I, tierGlyph } = B;
const screens = [];

const who = (svg, vc, vb) => `<span class="who" style="--vc:${vc};--vb:${vb || '#fff'}">${svg}</span>`;
const pages = (n, now) => `<span class="pages">${Array.from({ length: n }, (_, i) => `<i class="${i + 1 < now ? 'done' : i + 1 === now ? 'now' : ''}"></i>`).join('')}</span>`;
const TIER = { 1: ['Low', '#0B8A6C', '#D6F7EC'], 2: ['Medium', '#B36200', '#FFEFC9'], 3: ['Advanced', '#5A3FE0', '#E6E0FF'] };
const tierPill = (n, extra = '') => `<span class="chip" style="background:${TIER[n][2]};color:${TIER[n][1]};${extra}">${tierGlyph(n)}${TIER[n][0]}</span>`;

const uiCss = `
.card{position:absolute;border-radius:26px;background:rgba(255,255,255,.78);box-shadow:inset 0 0 0 .5px rgba(255,255,255,.9),0 14px 34px rgba(60,40,140,.10),0 2px 6px rgba(60,40,140,.06);overflow:hidden}
.h1{position:absolute;font-family:var(--display);font-weight:760;font-size:30px;letter-spacing:-.9px;line-height:1.05;font-variation-settings:"opsz" 48,"wdth" 90;color:#16123D}
.h2{font-family:var(--display);font-weight:700;font-size:17px;letter-spacing:-.3px;color:#16123D;font-variation-settings:"opsz" 20,"wdth" 92}
.sub{font-family:var(--read);font-weight:450;font-size:13px;line-height:18px;color:rgba(22,18,61,.62)}
.lab{font-family:var(--display);font-weight:650;font-size:11px;letter-spacing:.9px;text-transform:uppercase;color:rgba(22,18,61,.5)}
.btn{display:flex;align-items:center;justify-content:center;gap:9px;height:52px;border-radius:26px;font-family:var(--display);font-weight:700;font-size:17px;letter-spacing:-.2px;color:#fff;
  background:linear-gradient(180deg,#FF8A66,#FF5B3D);box-shadow:inset 0 1.5px 0 rgba(255,255,255,.5),inset 0 -3px 6px rgba(120,20,0,.2),0 10px 22px rgba(232,67,43,.34),0 2px 4px rgba(0,0,0,.14)}
.btn.ghost{background:rgba(255,255,255,.14);box-shadow:inset 0 0 0 1px rgba(255,255,255,.28);color:#fff}
.btn.quiet{background:rgba(22,18,61,.06);box-shadow:none;color:#16123D}
.cover{position:relative;border-radius:20px;overflow:hidden;box-shadow:0 12px 26px rgba(40,24,110,.22),0 2px 5px rgba(40,24,110,.16),inset 0 0 0 .5px rgba(255,255,255,.4)}
.cover>svg{display:block;width:100%;height:100%}
.cover::after{content:"";position:absolute;inset:0;border-radius:inherit;box-shadow:inset 0 1px 0 rgba(255,255,255,.55),inset 0 0 0 1px rgba(255,255,255,.12)}
`;

// OM | RA | MO mini wordmark for nav bars
const wordmark = (c1 = '#16123D', c2 = '#FF5B3D', size = 22) => `<span style="font-family:var(--display);font-weight:800;font-size:${size}px;letter-spacing:-.3px;font-variation-settings:'opsz' 30,'wdth' 96;color:${c1}">OM<span style="color:${c2}">RA</span>MO</span>`;

// ------------------------------------------------------------------ 01 splash
screens.push({
  name: '01-splash',
  html: () => B.duoPage({
    title: 'Omramo',
    scene: R.aurora({ dark: true }),
    lClass: 'dark', rClass: 'dark',
    extraCss: `
    .mark{position:absolute;top:214px;font-family:var(--display);font-weight:800;font-size:158px;line-height:1;letter-spacing:-3px;font-variation-settings:"opsz" 96,"wdth" 100;color:#fff;white-space:nowrap}
    .mark.l{right:9px}.mark.r{left:9px}
    .mark .ra{background:linear-gradient(180deg,#FFD25A 10%,#FF7A4D 60%,#FF4D7A);-webkit-background-clip:text;background-clip:text;color:transparent}
    .edge{position:absolute;top:0;bottom:0;width:60px;pointer-events:none}
    .edge.l{right:0;background:linear-gradient(90deg,transparent,rgba(255,150,90,.22))}.edge.r{left:0;background:linear-gradient(270deg,transparent,rgba(255,150,90,.22))}
    .seam{position:absolute;top:150px;bottom:150px;width:2px;border-radius:1px;background:linear-gradient(180deg,transparent,#FFC46B 30%,#FF7A4D 70%,transparent);opacity:.9}
    .tag{position:absolute;top:404px;font-family:var(--read);font-weight:480;font-size:19px;letter-spacing:.2px;color:rgba(255,255,255,.82)}
    .roots{position:absolute;bottom:64px;display:flex;gap:8px;font-family:var(--display);font-weight:600;font-size:12px;color:rgba(255,255,255,.7)}
    .roots span{display:inline-flex;align-items:center;gap:6px;height:28px;padding:0 11px 0 9px;border-radius:14px;background:rgba(255,255,255,.09);box-shadow:inset 0 0 0 .5px rgba(255,255,255,.18)}
    .dots{position:absolute;bottom:72px;left:28px;display:flex;gap:7px}.dots i{width:8px;height:8px;border-radius:4px;display:block}`,
    left: `<div class="edge l"></div><div class="seam" style="right:0"></div>
      <svg style="position:absolute;inset:0" viewBox="0 0 432 720">${A.wisdomMotes([[70, 150, 1.2, 1], [330, 120, 1, 2], [110, 560, 1, 2], [250, 610, 1.3, 1], [40, 400, .8, 2]], '#FFD25A')}</svg>
      <div class="mark l">OM<span class="ra">R</span></div>
      <div class="tag" style="right:20px;text-align:right">A magical book</div>
      <div style="position:absolute;left:28px;bottom:58px;display:flex">${[R.coverLow('m1'), R.coverMed('m2'), R.coverAdv('m3')].map((c, i) => `<div style="width:40px;height:40px;border-radius:20px;overflow:hidden;margin-left:${i ? -9 : 0}px;box-shadow:0 0 0 2px #1B1466,0 4px 10px rgba(0,0,0,.3)">${c.replace('<svg ', '<svg style="display:block;width:100%;height:100%" ')}</div>`).join('')}</div>`,
    right: `<div class="edge r"></div><div class="seam" style="left:0"></div>
      <svg style="position:absolute;inset:0" viewBox="0 0 432 720">${A.wisdomMotes([[360, 170, 1.2, 1], [90, 110, 1, 2], [300, 560, 1, 2], [150, 620, 1.1, 1], [400, 420, .8, 2]], '#FFD25A')}</svg>
      <div class="mark r"><span class="ra">A</span>MO</div>
      <div class="tag" style="left:20px">that you read.</div>
      <div class="roots" style="right:28px"><span>${I.pin('#19C7A2', 9)}Ancient India</span><span>${I.pin('#FFB020', 9)}Akan · Ghana</span><span>${I.pin('#FF6A8A', 9)}Japan</span></div>`,
  }),
});

// ------------------------------------------------------------------ 02 library home
const storyCard = (art, tier, title, place, pinC, state) => `<div style="width:116px"><div class="cover" style="width:116px;height:134px">${art}<div style="position:absolute;left:7px;top:7px;z-index:2">${tierPill(tier, 'height:22px;font-size:10.5px;padding:0 8px 0 7px;box-shadow:0 2px 6px rgba(0,0,0,.18)')}</div>${state ? `<div style="position:absolute;right:7px;bottom:7px;z-index:2;width:24px;height:24px;border-radius:12px;background:#fff;color:#0B8A6C;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 6px rgba(0,0,0,.2)">${I.check}</div>` : ''}</div>
  <div style="font-family:var(--display);font-weight:680;font-size:13px;line-height:15.500px;letter-spacing:-.15px;margin-top:9px;color:#16123D;display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden">${title}</div>
  <div style="display:flex;align-items:center;gap:5px;margin-top:5px;font-family:var(--display);font-weight:600;font-size:11px;color:rgba(22,18,61,.6)">${I.pin(pinC, 8)}${place}</div></div>`;

function mapCard() {
  const w = 344, h = 150;
  const pin = (lon, lat, c, label, dx, dy, state) => { const [x, y] = R.proj(lon, lat, w, h); return `${state === 'now' ? `<circle cx="${x}" cy="${y}" r="13" fill="${c}" opacity=".22"/><circle cx="${x}" cy="${y}" r="8" fill="none" stroke="${c}" stroke-width="1.200" opacity=".7"/>` : ''}<circle cx="${x}" cy="${y}" r="5" fill="${c}" stroke="#fff" stroke-width="1.800"/><path d="M${x},${y} l${dx * .55},${dy * .55}" stroke="${c}" stroke-width="1" opacity=".8"/><g transform="translate(${x + dx},${y + dy})"><rect x="${dx < 0 ? -label.length * 5.9 - 14 : 0}" y="-10" width="${label.length * 5.9 + 14}" height="20" rx="10" fill="#fff"/><text x="${dx < 0 ? -label.length * 2.95 - 7 : label.length * 2.95 + 7}" y="3.800" text-anchor="middle" font-family="Bricolage" font-weight="700" font-size="10.500" fill="#16123D">${label}</text></g>`; };
  const soon = (lon, lat) => { const [x, y] = R.proj(lon, lat, w, h); return `<circle cx="${x}" cy="${y}" r="3.600" fill="none" stroke="#fff" stroke-width="1.300" opacity=".75" stroke-dasharray="2 1.600"/>`; };
  return `<svg viewBox="0 0 ${w} ${h}" style="display:block;width:${w}px;height:${h}px">${R.worldDots(w, h, 'rgba(255,255,255,.3)', 1.5)}
  ${soon(31, 27)}${soon(105, 35)}${soon(-90, 17)}${soon(53, 32)}${soon(23, 39)}${soon(44, 33)}
  ${pin(79, 23, '#19C7A2', 'Ancient India', 4, 26, 'done')}${pin(-1.5, 7.5, '#FFB020', 'Akan · Ghana', -14, 24, 'done')}${pin(137, 36, '#FF6A8A', 'Japan', -4, -24, 'now')}</svg>`;
}
const avatar = (svg, name, ring, dim) => `<div style="width:52px;text-align:center"><div style="width:48px;height:48px;border-radius:24px;overflow:hidden;margin:0 auto;box-shadow:0 0 0 2.500px #fff,0 0 0 4.500px ${ring},0 6px 12px rgba(40,24,110,.16);${dim ? 'filter:grayscale(1) brightness(1.1);opacity:.4' : ''}">${svg}</div><div style="font-family:var(--display);font-weight:620;font-size:10.500px;margin-top:8px;color:rgba(22,18,61,${dim ? .4 : .8});white-space:nowrap">${name}</div></div>`;

screens.push({
  name: '02-library-home',
  html: () => B.duoPage({
    title: 'Omramo — Library',
    scene: R.aurora({}),
    extraCss: uiCss + `
    .seg{position:absolute;left:30px;top:356px;width:372px;height:38px;border-radius:19px;background:rgba(22,18,61,.07);display:flex;padding:3px;font-family:var(--display);font-weight:650;font-size:13px;color:rgba(22,18,61,.7)}
    .seg>span{flex:1;display:flex;align-items:center;justify-content:center;gap:6px;border-radius:16px}
    .seg>span.on{background:#fff;color:#16123D;box-shadow:0 2px 8px rgba(40,24,110,.14),0 0 0 .5px rgba(40,24,110,.06)}
    .tab{position:absolute;left:50%;bottom:22px;transform:translateX(-50%);height:62px;border-radius:31px;display:flex;padding:5px;gap:2px;z-index:30;--glass:rgba(255,255,255,.72)}
    .tab>span{width:92px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;border-radius:26px;font-family:var(--display);font-weight:650;font-size:10.500px;color:rgba(22,18,61,.55)}
    .tab>span.on{background:rgba(110,86,255,.13);color:#5A3FE0}
    .day{width:34px;text-align:center;font-family:var(--display);font-weight:650;font-size:10.500px;color:rgba(22,18,61,.5)}
    .day i{display:flex;align-items:center;justify-content:center;width:30px;height:30px;border-radius:15px;margin:0 auto 5px;background:rgba(22,18,61,.06);color:#fff}
    .day.on i{background:linear-gradient(180deg,#FFB84D,#FF7A3D);box-shadow:0 4px 10px rgba(255,122,61,.35),inset 0 1px 0 rgba(255,255,255,.5)}
    .day.today i{box-shadow:0 0 0 2px #fff,0 0 0 4px #FF7A3D,0 4px 10px rgba(255,122,61,.35)}`,
    left: `
      <div style="position:absolute;left:30px;top:56px">${wordmark()}</div>
      <div class="chip" style="position:absolute;right:28px;top:52px;height:32px;border-radius:16px;background:#fff;color:#E8552B;font-size:13px;box-shadow:0 4px 12px rgba(255,122,61,.2)">${I.flame}<span style="color:#16123D">5 days</span></div>
      <div class="lab" style="position:absolute;left:30px;top:110px">Keep reading</div>
      <div class="cover" style="position:absolute;left:30px;top:132px;width:372px;height:186px;border-radius:28px">
        <div style="position:absolute;inset:0">${U.seaScene({ w: 372, h: 186, lowL: 92, lift: 0, boatOn: false, tortoiseOn: false }).replace('<svg ', '<svg style="position:absolute;inset:0" ')}</div>
        <svg viewBox="0 0 372 186" style="position:absolute;inset:0"><defs>${U.lacquerDefs('hb')}${U.tortoiseDefs('ht')}<linearGradient id="hsc" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#0E2A5C" stop-opacity=".0"/><stop offset="1" stop-color="#0E2A5C" stop-opacity="0"/></linearGradient><linearGradient id="hsc2" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0B2A63" stop-opacity="0"/><stop offset="1" stop-color="#0B2A63" stop-opacity=".82"/></linearGradient></defs>
          <circle cx="292" cy="66" r="44" fill="#F4503F" opacity=".92"/>
          <g transform="translate(290,128) rotate(-5)">${U.lacquerBox({ id: 'hb', s: .8 })}</g><rect y="96" width="372" height="90" fill="url(#hsc2)"/></svg>
        <div style="position:absolute;left:18px;top:16px;z-index:2">${tierPill(3, 'height:24px;font-size:11px;box-shadow:0 2px 6px rgba(0,0,0,.12)')}</div>
        <div style="position:absolute;left:18px;top:50px;width:190px;font-family:var(--display);font-weight:760;font-size:25px;line-height:26px;letter-spacing:-.7px;color:#13264A;font-variation-settings:'opsz' 36,'wdth' 88;z-index:2">The Story of Urashima Taro</div>
        <div style="position:absolute;left:18px;right:18px;bottom:16px;display:flex;align-items:center;gap:12px;z-index:2">
          <div class="btn" style="height:42px;padding:0 18px 0 16px;font-size:15px">${I.book}Continue</div>
          <div style="flex:1;font-family:var(--display);font-weight:650;font-size:12px;color:#fff"><div style="display:flex;justify-content:space-between"><span>Page 5 of 19</span><span style="display:inline-flex;gap:5px;align-items:center">${I.pin('#fff', 8)}Japan</span></div><div style="height:5px;border-radius:3px;background:rgba(255,255,255,.3);margin-top:7px"><div style="width:26%;height:100%;border-radius:3px;background:#fff"></div></div></div>
        </div>
      </div>
      <div class="lab" style="position:absolute;left:30px;top:334px">Stories by level</div>
      <div class="seg"><span class="on">All</span><span style="color:#0B8A6C">${tierGlyph(1)}Low</span><span style="color:#B36200">${tierGlyph(2)}Medium</span><span style="color:#5A3FE0">${tierGlyph(3)}Advanced</span></div>
      <div style="position:absolute;left:30px;top:408px;display:flex;gap:12px">
        ${storyCard(R.coverLow(), 1, 'The Monkey and the Crocodile', 'Ancient India', '#19C7A2', true)}
        ${storyCard(R.coverMed(), 2, 'How Wisdom Became the Property of the Human Race', 'Akan · Ghana', '#FFB020', true)}
        ${storyCard(R.coverAdv(), 3, 'The Story of Urashima Taro', 'Japan', '#FF6A8A', false)}
      </div>
      <div class="tab glass"><span class="on">${I.home}Library</span><span>${I.shelf}My shelf</span><span>${I.lock}Grown-ups</span></div>`,
    right: `
      <div class="lab" style="position:absolute;left:30px;top:60px">Where the stories come from</div>
      <div class="card" style="left:30px;top:84px;width:372px;height:214px;background:linear-gradient(160deg,#2A1F7A,#17114A 70%);box-shadow:0 16px 34px rgba(40,24,110,.3)">
        <div style="position:absolute;left:14px;top:14px">${mapCard()}</div>
        <div style="position:absolute;left:18px;right:18px;bottom:14px;display:flex;gap:14px;font-family:var(--display);font-weight:600;font-size:11px;color:rgba(255,255,255,.78);align-items:center">
          <span style="display:inline-flex;gap:6px;align-items:center"><i style="width:8px;height:8px;border-radius:4px;background:#19C7A2;display:block"></i>Read</span>
          <span style="display:inline-flex;gap:6px;align-items:center"><i style="width:8px;height:8px;border-radius:4px;background:#FF6A8A;box-shadow:0 0 0 3px rgba(255,106,138,.3);display:block"></i>Reading now</span>
          <span style="display:inline-flex;gap:6px;align-items:center"><i style="width:8px;height:8px;border-radius:4px;border:1.300px dashed #fff;display:block"></i>More cultures later</span></div>
      </div>
      <div class="card" style="left:30px;top:312px;width:372px;height:104px;padding:14px 18px">
        <div style="display:flex;justify-content:space-between;align-items:baseline"><span class="h2">5 days in a row</span><span class="sub" style="font-size:12px">A day counts when you read a page</span></div>
        <div style="display:flex;justify-content:space-between;margin-top:11px">
          ${['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d, i) => `<div class="day ${i < 5 ? 'on' : ''} ${i === 4 ? 'today' : ''}"><i>${i < 5 ? I.check : ''}</i>${d}</div>`).join('')}
        </div>
      </div>
      <div class="card" style="left:30px;top:430px;width:372px;height:132px;padding:14px 18px">
        <div style="display:flex;justify-content:space-between;align-items:baseline"><span class="h2">My shelf</span><span class="sub" style="font-size:12px">2 stories finished · 25 pages read</span></div>
        <div style="display:flex;gap:12px;margin-top:12px;align-items:flex-end">
          <div class="cover" style="width:58px;height:72px;border-radius:12px;transform:rotate(-4deg)">${R.coverLow('s1')}</div>
          <div class="cover" style="width:58px;height:72px;border-radius:12px;transform:rotate(3deg)">${R.coverMed('s2')}</div>
          <div style="position:relative;width:58px;height:72px"><div class="cover" style="width:58px;height:72px;border-radius:12px;opacity:.45">${R.coverAdv('s3')}</div><div style="position:absolute;left:0;right:0;bottom:-3px;text-align:center;font-family:var(--display);font-weight:700;font-size:10px;color:#5A3FE0"><span style="background:#fff;border-radius:8px;padding:2px 7px;box-shadow:0 2px 6px rgba(40,24,110,.18)">5 / 19</span></div></div>
          ${[0, 1].map(() => `<div style="width:58px;height:72px;border-radius:12px;border:1.500px dashed rgba(22,18,61,.2)"></div>`).join('')}
        </div>
      </div>
      <div class="lab" style="position:absolute;left:30px;top:580px">Friends you have met</div>
      <div style="position:absolute;left:28px;top:604px;display:flex;gap:11px">
        ${avatar(J.faceMonkey('a1'), 'Monkey', '#FFB020')}${avatar(J.faceCroc('a2'), 'Crocodile', '#19C7A2')}${avatar(A.faceAnansi('a3'), 'Anansi', '#D8342B')}${avatar(A.faceKweku('a4'), 'Kweku Tsin', '#F7B520')}${avatar(U.faceUrashima(), 'Urashima', '#3FB4FF')}${avatar(U.faceTortoise('a6'), 'Tortoise', '#bbb', true)}
      </div>`,
  }),
});

// ------------------------------------------------------------------ 06 tap-to-see (open) + 06b return
const advCss = `.txt{--tx:#13264A}.ur{--vc:#1B4C93}.to{--vc:#2F6B45}.tap{--tapbg:rgba(255,150,120,.34);--tapbg2:rgba(255,120,100,.26);--tapline:#F4503F;--tapline2:#F4503F}.foot .chip{--glass:rgba(255,255,255,.8);color:#13264A}.pane{--hbc:rgba(255,255,255,.92)}`;
const rinText = (open) => `
  <div class="txt t-adv ${open ? 'held' : ''}" style="left:30px;top:108px;width:374px">
    <p>So the tortoise climbed into the boat, the fisherman helping him, and after an exchange of complimentary speeches the tortoise said:</p>
    <p class="here">${who(U.faceTortoise('ft1'), '#2F6B45')}<span class="say to">“Have you ever seen <span class="tap ${open ? 'on' : 'seen'}">Rin Gin</span>, the Palace of the Dragon King of the Sea, Urashima?”</span></p>
    <p>The fisherman shook his head and replied; ${who(U.faceUrashima(), '#1B4C93')}<span class="say ur">“No; year after year the sea has been my home, but though I have often heard of the Dragon King’s realm under the sea I have never yet set eyes on that wonderful place. It must be very far away, if it exists at all!”</span></p>
    <p>${who(U.faceTortoise('ft2'), '#2F6B45')}<span class="say to">“Is that really so? You have never seen the Sea King’s Palace? Then you have missed seeing one of the most wonderful sights in the whole universe. It is far away at the bottom of the sea, but if I take you there we shall soon reach the place.”</span></p>
  </div>`;
screens.push({
  name: '06-tap-to-see-open',
  html: () => B.duoPage({
    title: 'Omramo — tap-to-see: Rin Gin',
    scene: U.seaScene({ boatOn: false, tortoiseOn: false }),
    rClass: 'dark',
    extraCss: advCss + uiCss + `
    .held p{opacity:.42}.held p.here{opacity:1}
    .beam{position:absolute;left:0;right:0;top:182px;height:66px;background:linear-gradient(90deg,rgba(255,196,61,0),rgba(255,196,61,.2) 60%,rgba(255,196,61,.5));z-index:5}
    .keeper{position:absolute;left:12px;top:192px;width:5px;height:46px;border-radius:3px;background:#FF7A3D;z-index:11;box-shadow:0 0 0 4px rgba(255,122,61,.18)}
    .see{position:absolute;inset:0;background:#06204A;z-index:20}
    .see .vis{position:absolute;left:0;top:0;width:432px;height:404px}
    .see .vis svg{display:block;width:100%;height:100%}
    .see .fade{position:absolute;left:0;right:0;top:300px;height:106px;background:linear-gradient(180deg,rgba(6,32,74,0),#06204A)}
    .see .inlet{position:absolute;left:0;top:182px;width:14px;height:66px;background:linear-gradient(90deg,rgba(255,196,61,.75),rgba(255,196,61,0));z-index:3}
    .see h3{position:absolute;left:28px;top:372px;font-family:var(--display);font-weight:780;font-size:40px;letter-spacing:-1.2px;color:#fff;font-variation-settings:"opsz" 60,"wdth" 90;line-height:1}
    .see h3 small{display:block;font-size:13px;font-weight:600;letter-spacing:.2px;color:#8FE3E8;margin-top:8px;font-variation-settings:"opsz" 14}
    .see .line{position:absolute;left:28px;right:28px;top:446px;font-family:var(--read);font-weight:480;font-size:19px;line-height:29px;color:#F2F8FF}
    .note{position:absolute;left:20px;right:20px;top:520px;border-radius:22px;padding:13px 16px 14px;background:rgba(255,255,255,.1);box-shadow:inset 0 0 0 .5px rgba(255,255,255,.22);color:#DDEBFF;font-family:var(--read);font-size:13.500px;line-height:19.500px;font-weight:440}
    .note b{display:flex;align-items:center;gap:7px;font-family:var(--display);font-weight:700;font-size:12px;letter-spacing:.7px;text-transform:uppercase;color:#FFB3A8;margin-bottom:5px}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="crumb"><b>The Story of Urashima Taro</b><span>The Fisher Lad</span></div>
      <div class="beam"></div><div class="keeper"></div>
      ${rinText(true)}
      <div class="foot">${`<span class="chip glass" style="color:#5A3FE0">${tierGlyph(3)}Advanced</span><span class="chip glass">${I.pin('#F4503F', 10)}Japan</span>`}</div>`,
    right: `
      <div class="see">
        <div class="vis">${U.palaceScene({ w: 432, h: 404 })}</div><div class="fade"></div><div class="inlet"></div>
        <div class="rb glass" style="left:20px;top:50px;--glass:rgba(10,40,90,.5)">${I.x}</div>
        <h3>Rin Gin<small>Ryūgū-jō · the Dragon Palace</small></h3>
        <div class="line">A palace at the bottom of the sea, where the Dragon King lives.</div>
        <div class="note"><b>${I.pin('#FF8A7A', 10)}From Japan</b>In Japanese legend the sea is ruled by Ryūjin, the Dragon King. Storytellers say his palace is built of red and white coral.</div>
        <div class="btn" style="position:absolute;left:20px;right:20px;bottom:26px;background:linear-gradient(180deg,#FFD25A,#FFB020);color:#3A1B08;box-shadow:inset 0 1.5px 0 rgba(255,255,255,.6),0 10px 22px rgba(255,176,32,.3)">${I.ret}Back to my line</div>
      </div>`,
  }),
});
screens.push({
  name: '06b-tap-to-see-return',
  html: () => B.duoPage({
    title: 'Omramo — back at the same line',
    scene: U.seaScene({ tIn: true }),
    extraCss: advCss + `
    .tap.seen{background:rgba(255,196,61,.28);box-shadow:inset 0 -2px 0 #FFB020}.tap.seen::after{background:#FFB020}
    .keeper{position:absolute;left:12px;top:192px;width:5px;height:46px;border-radius:3px;background:#FF7A3D;z-index:11;box-shadow:0 0 0 4px rgba(255,122,61,.18)}
    .beam{position:absolute;left:0;right:0;top:182px;height:66px;background:linear-gradient(90deg,rgba(255,196,61,.22),rgba(255,196,61,.06) 70%,rgba(255,196,61,0));z-index:5}
    .toast{position:absolute;left:50%;top:104px;transform:translateX(-50%);height:38px;border-radius:19px;padding:0 16px 0 12px;display:flex;align-items:center;gap:9px;font-family:var(--display);font-weight:650;font-size:13.500px;color:#13264A;z-index:30;white-space:nowrap}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="crumb"><b>The Story of Urashima Taro</b><span>The Fisher Lad</span></div>
      <div class="beam"></div><div class="keeper"></div>
      ${rinText(false)}
      <div class="foot"><span class="chip glass" style="color:#5A3FE0">${tierGlyph(3)}Advanced</span><span class="chip glass">${I.pin('#F4503F', 10)}Japan</span></div>`,
    right: `
      <div class="cap glass" style="right:20px;top:50px"><span class="aa">A<small>A</small></span>${I.bookmark}</div>
      <div class="toast glass"><span style="width:22px;height:22px;border-radius:11px;background:#FF7A3D;color:#fff;display:flex;align-items:center;justify-content:center">${I.ret.replace('width="18" height="16"', 'width="12" height="11"')}</span>You are back at your line</div>
      <div class="foot" style="right:100px"><span class="chip glass pg">${pages(9, 4)}<span>7 / 19</span></span></div>
      <div class="next" style="--nx1:#FF8A70;--nx2:#F4503F;--nx3:#D8342B">${I.fwd}</div>`,
  }),
});

// ------------------------------------------------------------------ 07 character card
screens.push({
  name: '07-character-card',
  html: () => B.duoPage({
    title: 'Omramo — character: the Monkey',
    scene: J.riverScene(),
    rClass: 'dark',
    extraCss: uiCss + `.txt{--tx:#10283A}.croc{--vc:#17694A}.mk{--vc:#A8501C}.pane.L{--hbc:rgba(255,255,255,.92)}.foot .chip{--glass:rgba(255,255,255,.84);color:#10283A}
    .pane.R{--hbc:rgba(42,20,8,.8)}.name.on{text-decoration:none;background:#FFC43D;border-radius:.34em;padding:0 .2em;margin:0 -.08em;box-shadow:0 0 0 3px rgba(255,196,61,.35),0 6px 16px rgba(255,150,30,.35);color:#16123D}
    .held p{opacity:.45}.held p.here{opacity:1}
    .keeper{position:absolute;left:12px;top:110px;width:5px;height:30px;border-radius:3px;background:#FF7A3D;z-index:11;box-shadow:0 0 0 4px rgba(255,122,61,.18)}
    .cc{position:absolute;inset:0;z-index:20;background:linear-gradient(180deg,#FFD35A 0%,#FFAE45 46%,#FF8A4D 70%)}
    .cc .sheet{position:absolute;left:0;right:0;top:372px;bottom:0;background:#FFFBF4;border-radius:34px 34px 0 0;box-shadow:0 -10px 30px rgba(160,60,0,.18)}
    .cc h3{font-family:var(--display);font-weight:800;font-size:38px;letter-spacing:-1.200px;line-height:1;color:#2A1408;font-variation-settings:"opsz" 60,"wdth" 90}
    .trait{display:inline-flex;align-items:center;height:30px;padding:0 13px;border-radius:15px;font-family:var(--display);font-weight:680;font-size:12.500px;white-space:nowrap}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="crumb"><b>The Monkey and the Crocodile</b><span>Part I</span></div>
      <div class="keeper"></div>
      <div class="txt t-low held" style="left:30px;top:106px;width:374px">
        <p class="here">${who(J.faceMonkey('fm1'), '#A8501C')}<span class="say mk">“Very well,”</span> said the <span class="name on">Monkey</span>.</p>
        <p>But no sooner had he jumped onto the bank of the river than—<span class="pop" style="font-size:1.25em;--popc:#E8552B">whisk!</span> up he ran into the tree.</p>
        <p>From the topmost branches he called down to the Crocodile in the water below:</p>
        <p>${who(J.faceMonkey('fm2'), '#A8501C')}<span class="say mk">“My heart is way up here! If you want it, come for it, come for it!”</span></p>
      </div>
      <div class="foot"><span class="chip glass" style="color:#0B7A62">${tierGlyph(1)}Low</span><span class="chip glass">${I.pin('#FF6A4D', 10)}Ancient India</span><span class="chip glass">7 / 14</span></div>`,
    right: `
      <div class="cc">
        <svg viewBox="0 0 432 400" style="position:absolute;left:0;top:0;width:432px;height:400px"><defs>${J.monkeyDefs('cm')}<radialGradient id="ccg"><stop offset="0" stop-color="#FFF6C8" stop-opacity=".95"/><stop offset="1" stop-color="#FFF6C8" stop-opacity="0"/></radialGradient><linearGradient id="ccb" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#8E5B45"/><stop offset="1" stop-color="#5B3A36"/></linearGradient>${B.grainDefs('ccgr')}</defs>
          <g opacity=".5">${Array.from({ length: 14 }, (_, i) => `<path d="M216,230 L${B.f1(216 + Math.cos(i * 0.4488) * 520)},${B.f1(230 + Math.sin(i * 0.4488) * 520)} L${B.f1(216 + Math.cos(i * 0.4488 + .2) * 520)},${B.f1(230 + Math.sin(i * 0.4488 + .2) * 520)}Z" fill="#FFE27A" opacity=".5"/>`).join('')}</g>
          <circle cx="216" cy="224" r="170" fill="url(#ccg)"/>
          ${J.canopy([{ x: 30, y: 40, r: 60 }, { x: 110, y: 10, r: 44 }, { x: 410, y: 30, r: 62 }, { x: 330, y: 6, r: 40 }, { x: -6, y: 130, r: 34 }, { x: 440, y: 130, r: 30 }], 12)}
          <path d="M-10,338 C100,326 300,330 442,318 L442,346 C300,352 100,352 -10,362Z" fill="url(#ccb)"/><path d="M-10,338 C100,326 300,330 442,318" stroke="#C68A62" stroke-width="3" fill="none" opacity=".7"/>
          <ellipse cx="220" cy="336" rx="64" ry="7" fill="#3A2230" opacity=".3"/>
          <g transform="translate(220,330) scale(2.15)">${J.monkey({ pose: 'wave', mouth: 'grin', look: [0, .5], id: 'cm' })}</g>
          ${J.canopy([{ x: 70, y: 348, r: 26 }, { x: 36, y: 330, r: 20 }, { x: 392, y: 326, r: 24 }], 18)}
          <rect width="432" height="400" filter="url(#ccgr)" opacity=".45" style="mix-blend-mode:soft-light"/></svg>
        <div class="rb glass" style="left:20px;top:50px;--glass:rgba(255,255,255,.55)">${I.x}</div>
        <div class="sheet">
          <div style="position:absolute;left:28px;right:28px;top:26px">
            <div class="lab" style="color:#C2571C">Character · in Part I and Part II</div>
            <h3 style="margin-top:8px">The Monkey</h3>
            <div style="display:flex;gap:7px;margin-top:14px"><span class="trait" style="background:#FFE9B8;color:#8A4A00">Quick thinker</span><span class="trait" style="background:#D9F5E4;color:#0B6B4A">Lives in the great tree</span><span class="trait" style="background:#FFE0D6;color:#B33A1C">Cannot swim</span></div>
            <div style="font-family:var(--read);font-weight:470;font-size:19px;line-height:29px;color:#2A1408;margin-top:16px">He loves ripe fruit a little too much. When he is in trouble, he does not fight. He thinks.</div>
          </div>
          <div class="btn" style="position:absolute;left:20px;right:20px;bottom:26px">${I.ret}Back to my line</div>
        </div>
      </div>`,
  }),
});

// ------------------------------------------------------------------ 08 parent view
const row = (label, value, last) => `<div style="display:flex;align-items:center;height:46px;padding:0 16px;font-family:var(--sys);font-size:15.500px;letter-spacing:-.2px;color:#16123D;${last ? '' : 'box-shadow:inset 0 -.5px 0 rgba(22,18,61,.12)'}"><span style="flex:1">${label}</span><span style="color:rgba(22,18,61,.5);margin-right:10px;font-size:14.500px">${value || ''}</span><span style="color:rgba(22,18,61,.3)">${I.chevR}</span></div>`;
function pagesChart() {
  const d = [['Sat', 3], ['Sun', 0], ['Mon', 4], ['Tue', 5], ['Wed', 6], ['Thu', 4], ['Today', 3]];
  const W = 336, H = 120, base = 96, max = 6, bw = 26, gap = (W - bw * 7) / 6;
  let s = '';
  for (const g of [3, 6]) s += `<path d="M0,${base - g / max * 80} H${W}" stroke="rgba(22,18,61,.08)" stroke-width="1"/><text x="${g === 6 ? 0 : 58}" y="${base - g / max * 80 - 4}" text-anchor="start" font-family="Inter" font-size="9.500" fill="rgba(22,18,61,.4)">${g} pages</text>`;
  d.forEach(([l, v], i) => { const x = i * (bw + gap), h = Math.max(v / max * 80, 0); const today = i === 6;
    s += v ? `<path d="M${x},${base} V${base - h + 4} a4,4 0 0 1 4,-4 H${x + bw - 4} a4,4 0 0 1 4,4 V${base}Z" fill="${today ? '#5A3FE0' : '#B9ADFF'}"/>` : `<rect x="${x}" y="${base - 2}" width="${bw}" height="2" rx="1" fill="rgba(22,18,61,.18)"/>`;
    if (today || v === 6) s += `<text x="${x + bw / 2}" y="${base - h - 6}" text-anchor="middle" font-family="Bricolage" font-weight="700" font-size="11.500" fill="#16123D">${v}</text>`;
    s += `<text x="${x + bw / 2}" y="${base + 16}" text-anchor="middle" font-family="Inter" font-weight="${today ? 600 : 400}" font-size="10" fill="rgba(22,18,61,${today ? .9 : .5})">${l}</text>`; });
  s += `<path d="M0,${base} H${W}" stroke="rgba(22,18,61,.22)" stroke-width="1"/>`;
  return `<svg viewBox="0 0 ${W} ${H}" style="display:block;width:${W}px;height:${H}px">${s}</svg>`;
}
const tierRow = (n, state, detail, pct) => `<div style="display:flex;gap:13px;align-items:center;padding:11px 0">
  <div style="width:40px;height:40px;border-radius:14px;background:${TIER[n][2]};color:${TIER[n][1]};display:flex;align-items:center;justify-content:center;flex:none"><span style="transform:scale(1.45)">${tierGlyph(n)}</span></div>
  <div style="flex:1"><div style="display:flex;justify-content:space-between;align-items:baseline"><span class="h2" style="font-size:15.500px">${TIER[n][0]}</span><span style="font-family:var(--display);font-weight:650;font-size:11.500px;color:${state === 'Reading now' ? '#5A3FE0' : 'rgba(22,18,61,.55)'}">${state}</span></div>
  <div style="height:6px;border-radius:3px;background:rgba(22,18,61,.08);margin-top:7px"><div style="width:${pct}%;height:100%;border-radius:3px;background:${TIER[n][1]}"></div></div>
  <div class="sub" style="font-size:12px;margin-top:5px">${detail}</div></div></div>`;
screens.push({
  name: '08-parent-view',
  html: () => B.duoPage({
    title: 'Omramo — For grown-ups',
    scene: R.aurora({}),
    extraCss: uiCss + `.card{background:rgba(255,255,255,.86)}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="h1" style="left:30px;top:104px">For grown-ups</div>
      <div class="sub" style="position:absolute;left:30px;top:142px;width:360px">What your child has read this week.</div>
      <div class="card" style="left:30px;top:178px;width:372px;height:282px;padding:18px 18px">
        <div class="lab">Pages read · last 7 days</div>
        <div style="display:flex;align-items:baseline;gap:8px;margin-top:6px"><span style="font-family:var(--display);font-weight:800;font-size:56px;letter-spacing:-2.500px;line-height:1;color:#16123D;font-variation-settings:'opsz' 96,'wdth' 90">25</span><span style="font-family:var(--display);font-weight:650;font-size:15px;color:rgba(22,18,61,.6)">pages</span><span style="flex:1"></span><span class="chip" style="background:#FFEFE2;color:#C2471C;height:26px;font-size:11.500px">${I.flame.replace('width="15" height="19"', 'width="10" height="13"')}Read on 6 of 7 days</span></div>
        <div style="margin-top:16px">${pagesChart()}</div>
        <div class="sub" style="font-size:12px;margin-top:8px">A page counts when your child turns it after reading.</div>
      </div>
      <div class="card" style="left:30px;top:474px;width:372px;height:86px;padding:15px 18px;display:flex;gap:14px;align-items:center">
        <div style="flex:1"><div style="font-family:var(--display);font-weight:800;font-size:26px;letter-spacing:-.8px;color:#16123D">2</div><div class="sub" style="font-size:12px">stories finished</div></div>
        <div style="width:.5px;height:44px;background:rgba(22,18,61,.14)"></div>
        <div style="flex:1"><div style="font-family:var(--display);font-weight:800;font-size:26px;letter-spacing:-.8px;color:#16123D">3</div><div class="sub" style="font-size:12px">cultures visited</div></div>
        <div style="width:.5px;height:44px;background:rgba(22,18,61,.14)"></div>
        <div style="flex:1"><div style="font-family:var(--display);font-weight:800;font-size:26px;letter-spacing:-.8px;color:#16123D">5</div><div class="sub" style="font-size:12px">days in a row</div></div>
      </div>
      <div style="position:absolute;left:30px;top:580px;width:372px;display:flex;gap:11px;align-items:flex-start"><span style="width:30px;height:30px;border-radius:15px;background:#E6E0FF;color:#5A3FE0;display:flex;align-items:center;justify-content:center;flex:none">${I.book.replace('width="20" height="17"', 'width="15" height="13"')}</span><span class="sub" style="font-size:12.500px;line-height:17.500px">Omramo reports reading, not screen time. There is no timer and no usage clock anywhere in the app.</span></div>`,
    right: `
      <div class="lab" style="position:absolute;left:30px;top:62px">Reading level</div>
      <div class="card" style="left:30px;top:86px;width:372px;height:262px;padding:8px 18px">
        ${tierRow(1, 'Finished 1 story', 'The Monkey and the Crocodile · 14 of 14 pages', 100)}
        <div style="height:.5px;background:rgba(22,18,61,.1)"></div>
        ${tierRow(2, 'Finished 1 story', 'How Wisdom Became the Property of the Human Race · 6 of 6 pages', 100)}
        <div style="height:.5px;background:rgba(22,18,61,.1)"></div>
        ${tierRow(3, 'Reading now', 'The Story of Urashima Taro · page 5 of 19', 26)}
      </div>
      <div class="sub" style="position:absolute;left:34px;top:358px;width:364px;font-size:12px;line-height:16.500px">Each story belongs to one level, chosen for its message. Your child can read at any level at any time.</div>
      <div class="lab" style="position:absolute;left:30px;top:412px">Settings</div>
      <div class="card" style="left:30px;top:436px;width:372px;border-radius:20px">
        ${row('Appearance', 'Automatic')}${row('Manage Subscription', 'Free sample')}${row('Restore Purchases', '')}${row('Privacy', 'No ads · No tracking')}${row('Terms and legal', '', true)}
      </div>`,
  }),
});

// ------------------------------------------------------------------ 09 sample paywall (end of sample → parental gate)
const key = (n, sub = '') => `<div style="height:46px;border-radius:12px;background:rgba(255,255,255,.95);box-shadow:0 1px 0 rgba(22,18,61,.22);display:flex;flex-direction:column;align-items:center;justify-content:center;font-family:var(--sys);font-size:23px;font-weight:400;color:#16123D;line-height:1">${n}${sub ? `<span style="font-size:8.500px;font-weight:700;letter-spacing:1.600px;margin-top:2px">${sub}</span>` : ''}</div>`;
const planCard = (dim) => `
  <div style="position:absolute;left:0;right:0;top:0;height:300px;background:linear-gradient(160deg,#3A2BB0,#1B1466 70%)"></div>
  <div style="position:absolute;left:30px;top:62px;font-family:var(--display);font-weight:650;font-size:11px;letter-spacing:.9px;text-transform:uppercase;color:rgba(255,255,255,.6)">Family subscription</div>
  <div style="position:absolute;left:30px;top:84px;width:330px;font-family:var(--display);font-weight:780;font-size:32px;line-height:33px;letter-spacing:-1px;color:#fff;font-variation-settings:'opsz' 48,'wdth' 90">Every story.<br>Every level.<br>One family.</div>`;
screens.push({
  name: '09-sample-paywall',
  html: () => B.duoPage({
    title: 'Omramo — end of the free sample',
    scene: J.riverScene(),
    rClass: 'dark',
    extraCss: uiCss + `.pane.R{--hbc:rgba(22,18,61,.82)}.txt{--tx:#10283A}.croc{--vc:#17694A}.pane.L{--hbc:rgba(255,255,255,.92)}
    .think{letter-spacing:.14em;font-weight:560;font-style:italic}
    .end{position:absolute;left:16px;right:16px;bottom:24px;border-radius:30px;padding:18px 18px 16px;z-index:30;--glass:rgba(255,255,255,.8)}
    .gatebg{position:absolute;inset:0;background:#F4F2FF}
    .dim{position:absolute;inset:0;background:rgba(12,8,40,.46);z-index:21}
    .sheet{position:absolute;left:0;right:0;top:92px;bottom:0;background:#F4F2FB;border-radius:36px 36px 0 0;z-index:22;box-shadow:0 -12px 40px rgba(0,0,0,.3)}
    .grab{position:absolute;left:50%;top:7px;margin-left:-18px;width:36px;height:5px;border-radius:3px;background:rgba(22,18,61,.2)}
    .dg{width:54px;height:62px;border-radius:16px;background:#fff;box-shadow:inset 0 0 0 1.500px rgba(22,18,61,.12);display:flex;align-items:center;justify-content:center;font-family:var(--display);font-weight:760;font-size:30px;color:#16123D}
    .dg.cur{box-shadow:inset 0 0 0 2.500px #6E56FF,0 0 0 4px rgba(110,86,255,.18)}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="crumb"><b>The Monkey and the Crocodile</b><span>Part I · Free sample</span></div>
      <div class="txt t-low" style="left:30px;top:106px;width:374px">
        <p>${who(J.faceCroc('fc2'), '#17694A')}<span class="say croc">“How am I to catch a Monkey?”</span> asked the little Crocodile. <span class="say croc">“I do not travel on land, and the Monkey does not go into the water.”</span></p>
        <p>${who(J.faceCroc('fc3', '#FFE2A8'), '#0E5A55')}<span class="say" style="--vc:#0E5A55">“Put your wits to work, and you’ll find a way,”</span> said the mother.</p>
        <p>And the little Crocodile thought and <span class="think">thought.</span></p>
      </div>
      <div class="end glass">
        <div style="display:flex;gap:12px;align-items:center">
          <div class="cover" style="width:50px;height:62px;border-radius:12px;flex:none">${R.coverLow('pe')}</div>
          <div><div class="h2" style="font-size:19px;letter-spacing:-.4px">The free sample ends here</div><div class="sub" style="margin-top:3px;color:rgba(22,18,61,.72)">12 more pages are waiting in this story.</div></div>
        </div>
        <div class="btn" style="margin-top:14px;height:50px">${I.lock}Ask a grown-up to unlock</div>
      </div>`,
    right: `
      <div class="gatebg">${planCard()}</div>
      <div class="dim"></div>
      <div class="sheet">
        <div class="grab"></div>
        <div style="position:absolute;right:16px;top:16px;width:30px;height:30px;border-radius:15px;background:rgba(22,18,61,.08);color:rgba(22,18,61,.6);display:flex;align-items:center;justify-content:center">${I.x.replace('width="13" height="13"', 'width="10" height="10"')}</div>
        <div style="position:absolute;left:0;right:0;top:34px;text-align:center">
          <div style="width:52px;height:52px;border-radius:26px;background:linear-gradient(180deg,#8E7BFF,#5A3FE0);color:#fff;display:inline-flex;align-items:center;justify-content:center;box-shadow:0 8px 18px rgba(90,63,224,.35)"><span style="transform:scale(1.5)">${I.lock}</span></div>
          <div style="font-family:var(--display);font-weight:780;font-size:25px;letter-spacing:-.7px;color:#16123D;margin-top:12px;font-variation-settings:'opsz' 36,'wdth' 90">Grown-ups only</div>
          <div class="sub" style="font-size:14.500px;line-height:20px;margin-top:6px">To continue, type these numbers:</div>
          <div style="font-family:var(--read);font-weight:700;font-size:21px;letter-spacing:.2px;color:#5A3FE0;margin-top:8px">seven &nbsp;·&nbsp; three &nbsp;·&nbsp; nine</div>
          <div style="display:flex;gap:10px;justify-content:center;margin-top:16px"><div class="dg">7</div><div class="dg">3</div><div class="dg cur"><span style="width:2.500px;height:28px;border-radius:2px;background:#6E56FF;display:block"></span></div></div>
          <div class="sub" style="font-size:12.500px;margin-top:20px">Omramo never asks a child to buy anything.</div>
        </div>
        <div style="position:absolute;left:0;right:0;bottom:0;height:256px;background:#D8D5E6;padding:8px 7px 0">
          <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:7px">${key(1)}${key(2, 'ABC')}${key(3, 'DEF')}${key(4, 'GHI')}${key(5, 'JKL')}${key(6, 'MNO')}${key(7, 'PQRS')}${key(8, 'TUV')}${key(9, 'WXYZ')}<div></div>${key(0)}<div style="display:flex;align-items:center;justify-content:center;color:#16123D"><svg width="26" height="20" viewBox="0 0 26 20" fill="none"><path d="M8.500 1.500h13a3 3 0 0 1 3 3v11a3 3 0 0 1-3 3h-13L1.500 10l7-8.500Z" stroke="currentColor" stroke-width="1.700" stroke-linejoin="round"/><path d="m12 7 6 6m0-6-6 6" stroke="currentColor" stroke-width="1.700" stroke-linecap="round"/></svg></div></div>
        </div>
      </div>`,
  }),
});
const benefit = (icon, t, d) => `<div style="display:flex;gap:13px;align-items:flex-start;margin-top:21px"><span style="width:34px;height:34px;border-radius:12px;background:rgba(255,255,255,.12);box-shadow:inset 0 0 0 .5px rgba(255,255,255,.2);color:#FFD25A;display:flex;align-items:center;justify-content:center;flex:none">${icon}</span><div><div style="font-family:var(--display);font-weight:700;font-size:15.500px;letter-spacing:-.2px;color:#fff">${t}</div><div style="font-family:var(--read);font-size:13px;line-height:18px;color:rgba(255,255,255,.7);margin-top:1px">${d}</div></div></div>`;
screens.push({
  name: '09b-family-subscription',
  html: () => B.duoPage({
    title: 'Omramo — Family subscription',
    scene: R.aurora({ dark: true }),
    lClass: 'dark',
    extraCss: uiCss + `.pane.R{background:#F4F2FF}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.x}</div>
      <div style="position:absolute;left:30px;top:108px;font-family:var(--display);font-weight:650;font-size:11px;letter-spacing:.9px;text-transform:uppercase;color:rgba(255,255,255,.6)">Omramo Family</div>
      <div style="position:absolute;left:30px;top:130px;width:350px;font-family:var(--display);font-weight:780;font-size:36px;line-height:37px;letter-spacing:-1.200px;color:#fff;font-variation-settings:'opsz' 60,'wdth' 90">Every story.<br>Every level.<br>One family.</div>
      <div style="position:absolute;left:30px;top:262px;display:flex">
        <div class="cover" style="width:92px;height:116px;border-radius:16px;transform:rotate(-7deg)">${R.coverLow('f1')}</div>
        <div class="cover" style="width:92px;height:116px;border-radius:16px;margin-left:-14px;transform:translateY(-8px)">${R.coverMed('f2')}</div>
        <div class="cover" style="width:92px;height:116px;border-radius:16px;margin-left:-14px;transform:rotate(7deg)">${R.coverAdv('f3')}</div>
      </div>
      <div style="position:absolute;left:30px;right:30px;top:404px">
        ${benefit(I.book, 'The whole library', 'Low, Medium and Advanced stories, with new ones added.')}
        ${benefit(I.globe, 'Stories from the world’s cultures', 'Each one comes with its place on the map.')}
        ${benefit(I.person2, 'Pages read, for grown-ups', 'See what was read. No screen-time clock.')}
        ${benefit(I.lock, 'No ads. No tracking.', 'Purchases sit behind the grown-up gate.')}
      </div>`,
    right: `
      <div class="lab" style="position:absolute;left:30px;top:62px">Choose a plan</div>
      <div class="card" style="left:30px;top:86px;width:372px;height:176px;padding:18px 20px;background:#fff;box-shadow:inset 0 0 0 2.500px #6E56FF,0 16px 34px rgba(90,63,224,.2)">
        <div style="display:flex;justify-content:space-between;align-items:center"><span class="h2" style="font-size:19px">Omramo Family</span><span style="width:26px;height:26px;border-radius:13px;background:#6E56FF;color:#fff;display:flex;align-items:center;justify-content:center">${I.check}</span></div>
        <div style="display:flex;align-items:baseline;gap:8px;margin-top:14px"><span style="font-family:var(--display);font-weight:800;font-size:46px;letter-spacing:-1.500px;line-height:1;color:#16123D;font-variation-settings:'opsz' 96,'wdth' 90">TBD</span><span style="font-family:var(--display);font-weight:650;font-size:15px;color:rgba(22,18,61,.6)">price not set yet</span></div>
        <div class="sub" style="margin-top:12px">Auto-renewing subscription. The price will be shown here in your local currency before you confirm.</div>
      </div>
      <div class="card" style="left:30px;top:276px;width:372px;height:74px;padding:14px 20px;display:flex;align-items:center;gap:14px">
        <span style="width:40px;height:40px;border-radius:14px;background:#D6F7EC;color:#0B8A6C;display:flex;align-items:center;justify-content:center;flex:none">${I.book}</span>
        <div><div class="h2" style="font-size:15.500px">The free sample stays free</div><div class="sub" style="font-size:12.500px">Browse every cover and read the first two pages of any story.</div></div>
      </div>
      <div class="btn" style="position:absolute;left:30px;width:372px;top:372px;height:56px;font-size:18px;background:linear-gradient(180deg,#8E7BFF,#5A3FE0);box-shadow:inset 0 1.5px 0 rgba(255,255,255,.45),0 12px 24px rgba(90,63,224,.36)">Subscribe</div>
      <div class="btn quiet" style="position:absolute;left:30px;width:372px;top:440px;height:50px;font-size:16px">Restore Purchases</div>
      <div class="sub" style="position:absolute;left:34px;top:510px;width:364px;font-size:12px;line-height:17px">Payment is charged to your Apple Account. The subscription renews automatically until it is cancelled in Settings. You can cancel at any time.</div>
      <div style="position:absolute;left:34px;top:590px;display:flex;gap:18px;font-family:var(--display);font-weight:650;font-size:12.500px;color:#5A3FE0"><span>Terms of Use</span><span>Privacy Policy</span></div>`,
  }),
});

// ------------------------------------------------------------------ 10 folded reading
function rideScene() {
  const w = 432, h = 720, H = 196;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" preserveAspectRatio="xMidYMid slice"><defs>
    <linearGradient id="fs" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#9FE9E0"/><stop offset=".2" stop-color="#DDF8EC"/><stop offset=".27" stop-color="#FFF2B5"/></linearGradient>
    <linearGradient id="fw" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#A9E9D4"/><stop offset=".12" stop-color="#4CC4B4"/><stop offset=".55" stop-color="#1596A0"/><stop offset="1" stop-color="#0E7C90"/></linearGradient>
    <linearGradient id="ff" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#EFFCF8"/><stop offset="1" stop-color="#E2F6F4"/></linearGradient>
    <radialGradient id="fg"><stop offset="0" stop-color="#FFF7C2" stop-opacity=".95"/><stop offset="1" stop-color="#FFEE9E" stop-opacity="0"/></radialGradient>
    ${J.monkeyDefs('rm')}${J.crocDefs('rc')}${B.grainDefs('rg')}</defs>
  <rect width="${w}" height="${h}" fill="url(#fs)"/>
  <circle cx="330" cy="${H - 20}" r="130" fill="url(#fg)"/><circle cx="330" cy="${H - 24}" r="30" fill="#FFF9D6"/>
  ${J.hills(w, H - 16, 20, 4, '#A8DDCF')}${J.hills(w, H - 4, 12, 9, '#7CCAB2')}
  ${[30, 90, 250, 400].map((x, i) => J.palm(x, H, .5 + (i % 3) * .1, i % 2 ? 4 : -4, '#3FA088')).join('')}
  ${J.hills(w, H + 3, 6, 15, '#3FA088', 5)}
  <rect y="${H}" width="${w}" height="160" fill="url(#fw)"/>
  <g transform="translate(250,2) scale(.8)"><path d="M10,${H + 30} C40,${H + 8} 90,${H + 2} 130,${H + 4} C176,${H + 6} 210,${H + 16} 226,${H + 30}Z" fill="#E9D58A"/><path d="M26,${H + 24} C56,${H + 6} 100,${H + 1} 134,${H + 4} C170,${H + 6} 196,${H + 14} 210,${H + 24}Z" fill="#5DBB63"/>${J.mangoTree(70, H + 12, .95, 2)}${J.mangoTree(118, H + 8, 1.2, 5)}${J.mangoTree(166, H + 13, .9, 7)}</g>
  ${J.waterRipples(0, w, H + 8, H + 150, 46, 31)}
  <g transform="translate(60,${H + 86}) scale(.92)">${J.croc({ id: 'rc', lid: 'sleepy', look: [-1, 0], wl: 12, water: '#1596A0' })}<g transform="translate(206,-26) scale(1.02)">${J.monkey({ pose: 'ride', mouth: 'grin', look: [-2, 0], id: 'rm' })}</g></g>
  ${J.ripples(200, H + 100, 300, 3)}
  <path d="M34,${H + 96} q-14,-4 -24,2 M30,${H + 106} q-16,0 -26,8" stroke="#fff" stroke-width="2.200" fill="none" opacity=".8" stroke-linecap="round"/>
  <path d="M0,${H + 140} C40,${H + 124} 80,${H + 150} 130,${H + 136} C180,${H + 122} 220,${H + 150} 270,${H + 136} C320,${H + 122} 370,${H + 150} 432,${H + 132} L432,720 L0,720Z" fill="#BFEFE6" opacity=".7"/>
  <path d="M0,${H + 152} C50,${H + 136} 90,${H + 160} 140,${H + 146} C190,${H + 132} 240,${H + 160} 290,${H + 146} C340,${H + 132} 380,${H + 158} 432,${H + 144} L432,720 L0,720Z" fill="url(#ff)"/>
  <rect width="${w}" height="${h}" filter="url(#rg)" opacity=".5" style="mix-blend-mode:soft-light"/></svg>`;
}
screens.push({
  name: '10-folded',
  folded: true,
  html: () => B.foldedPage({
    title: 'Omramo — folded reading',
    scene: rideScene(),
    extraCss: `.txt{--tx:#10283A}.croc{--vc:#17694A}.mk{--vc:#A8501C}.foot .chip{--glass:rgba(255,255,255,.9);color:#10283A}
    .next{width:54px;height:54px;right:22px;bottom:22px}`,
    body: `
      <div class="rb glass" style="left:18px;top:56px">${I.back}</div>
      <div class="cap glass" style="right:18px;top:56px"><span class="aa">A<small>A</small></span>${I.bookmark}</div>
      <div class="txt t-low" style="left:30px;top:366px;width:376px;font-size:22.500px;line-height:35px">
        <p>The <span class="name mk">Monkey</span> was greedy, and wanted the <span class="tap">ripe fruit</span>, so he jumped down on the Crocodile’s back.</p>
        <p style="margin-top:12px">${who(J.faceCroc('fc9'), '#17694A')}<span class="say croc pop" style="font-size:1.42em;--popc:#17694A">“Off we go!”</span> said the Crocodile.</p>
        <p style="margin-top:12px">${who(J.faceMonkey('fm9'), '#A8501C')}<span class="say mk">“This is a fine ride you are giving me!”</span> said the Monkey.</p>
      </div>
      <div class="foot" style="right:92px"><span class="chip glass" style="color:#0B7A62">${tierGlyph(1)}Low</span><span style="flex:1"></span><span class="chip glass pg">${pages(7, 3)}<span>5 / 14</span></span></div>
      <div class="next">${I.fwd}</div>`,
  }),
});

module.exports = screens;
});
