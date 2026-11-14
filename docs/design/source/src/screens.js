// Screen definitions for Omramo designs v2.
OMDEF('./screens', function (require, module) {
const B = require('./base');
const J = require('./art-jataka');
const A = require('./art-anansi');
const U = require('./art-urashima') || {};
const { I, tierGlyph } = B;

const who = (svg, vc, vb) => `<span class="who" style="--vc:${vc};--vb:${vb || '#fff'}">${svg}</span>`;
const pages = (n, now) => `<span class="pages">${Array.from({ length: n }, (_, i) => `<i class="${i + 1 < now ? 'done' : i + 1 === now ? 'now' : ''}"></i>`).join('')}</span>`;
const tierChip = (n, label, extra = '') => `<span class="chip glass" style="${extra}">${tierGlyph(n)}${label}</span>`;
const pinChip = (label, c, extra = '') => `<span class="chip glass" style="${extra}">${I.pin(c, 10)}${label}</span>`;

const screens = [];

// ------------------------------------------------------------------ 03 read: Low
screens.push({
  name: '03-read-low',
  html: () => B.duoPage({
    title: 'Omramo — The Monkey and the Crocodile',
    scene: J.riverScene(),
    rClass: 'dark',
    extraCss: `.txt{--tx:#10283A}.croc{--vc:#17694A}.pane.R .sb{--sbc:#fff}.pane.L{--hbc:rgba(255,255,255,.92)}.foot{--chrome2:#fff}.foot .chip{--glass:rgba(255,255,255,.84);color:#10283A}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="crumb"><b>The Monkey and the Crocodile</b><span>Part I</span></div>
      <div class="txt t-low" style="left:30px;top:106px;width:374px">
        <p><span class="lead">A monkey lived in a great tree on a <span class="tap">river bank</span>.</span></p>
        <p>In the river there were many Crocodiles.</p>
        <p style="margin-right:-6px">A <span class="name croc">Crocodile</span> watched the Monkeys for a long time, and one day she said to her son: ${who(J.faceCroc('fc1'), '#17694A')}<span class="say croc">“My son, get one of those Monkeys for me. I want the heart of a Monkey to eat.”</span></p>
      </div>
      <div class="foot">${tierChip(1, 'Low', 'color:#0B7A62')}${pinChip('Ancient India', '#FF6A4D')}</div>`,
    right: `
      <div class="cap glass" style="right:20px;top:50px"><span class="aa">A<small>A</small></span>${I.bookmark}</div>
      <div class="foot" style="right:100px"><span class="chip glass pg">${pages(7, 1)}<span>1 / 14</span></span></div>
      <div class="next">${I.fwd}</div>`,
  }),
});

// ------------------------------------------------------------------ 04 read: Medium
screens.push({
  name: '04-read-medium',
  html: () => B.duoPage({
    title: 'Omramo — How Wisdom Became the Property of the Human Race',
    scene: A.forestScene(),
    lClass: 'dark', rClass: 'dark',
    extraCss: `.txt{--tx:#FBF2E2}.an{--vc:#FFB86B}.kw{--vc:#FFD25A}.tap{--tapbg:rgba(255,196,61,.3);--tapbg2:rgba(255,160,61,.22);--tapline:#FFC43D;--tapline2:#FFD25A}.foot .chip{--glass:rgba(30,18,70,.55);color:#fff}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="crumb"><b>How Wisdom Became the Property of the Human Race</b><span>An Anansi story</span></div>
      <div class="txt t-med" style="left:30px;top:108px;width:372px">
        <p><span class="lead">Now, <span class="name an">Father Anansi</span> had a son, whose name was <span class="name kw">Kweku Tsin</span>.</span></p>
        <p style="margin-top:14px">This boy began to suspect his father of some secret design, so he made up his mind to watch carefully. Next day he saw his father quietly slip out of the house, with his <span class="tap">precious pot</span> hung round his neck. Kweku Tsin followed.</p>
        <p>Father Anansi went through the forest till he had left the village far behind. Then, selecting the highest and most inaccessible-looking tree, he began to climb.</p>
      </div>
      <div class="foot">${tierChip(2, 'Medium', 'color:#FFC43D')}${pinChip('Akan · Ghana', '#FF6A4D')}</div>`,
    right: `
      <div class="cap glass" style="right:20px;top:50px"><span class="aa">A<small>A</small></span>${I.bookmark}</div>
      <div class="foot" style="right:100px"><span class="chip glass pg">${pages(6, 3)}<span>3 / 6</span></span></div>
      <div class="next" style="--nx1:#FFD76B;--nx2:#FFB020;--nx3:#F08A12;--nxs:rgba(255,160,20,.4);color:#3A1B08">${I.fwd}</div>`,
  }),
});

// ------------------------------------------------------------------ 05 read: Advanced
const advCss = `.txt{--tx:#13264A}.ur{--vc:#1B4C93}.to{--vc:#2F6B45}.tap{--tapbg:rgba(255,150,120,.34);--tapbg2:rgba(255,120,100,.26);--tapline:#F4503F;--tapline2:#F4503F}.foot .chip{--glass:rgba(255,255,255,.8);color:#13264A}.pane{--hbc:rgba(255,255,255,.92)}`;
screens.push({
  name: '05-read-advanced',
  html: () => B.duoPage({
    title: 'Omramo — The Story of Urashima Taro',
    scene: U.seaScene(),
    extraCss: advCss + `.call{position:absolute;left:18px;top:86px;width:400px;height:96px;z-index:10}`,
    left: `
      <div class="rb glass" style="left:20px;top:50px">${I.back}</div>
      <div class="crumb"><b>The Story of Urashima Taro</b><span>The Fisher Lad</span></div>
      <div class="txt t-adv" style="left:30px;top:108px;width:374px">
        <p><span class="lead">The next morning Urashima went out as usual in his boat.</span></p>
        <p>The weather was fine and the sea and sky were both blue and soft in the tender haze of the summer morning. Urashima got into his boat and dreamily pushed out to sea, throwing his line as he did so. He soon passed the other <span class="tap">fishing boats</span> and left them behind him till they were lost to sight in the distance, and his boat drifted further and further out upon the blue waters.</p>
        <p>Somehow, he knew not why, he felt unusually happy that morning; and he could not help wishing that, like the <span class="name to">tortoise</span> he set free the day before, he had thousands of years to live instead of his own short span of human life.</p>
        <p>He was suddenly startled from his reverie by hearing his own name called:</p>
      </div>
      <div class="foot">${tierChip(3, 'Advanced', 'color:#5A3FE0')}${pinChip('Japan', '#F4503F')}</div>`,
    right: `
      <div class="cap glass" style="right:20px;top:50px"><span class="aa">A<small>A</small></span>${I.bookmark}</div>
      <svg class="call" viewBox="0 0 400 96"><defs><path id="callp" d="M14,66 C70,22 120,84 190,52 C250,26 300,70 388,30"/><linearGradient id="callg" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#1B4C93"/><stop offset="1" stop-color="#2F8FCB"/></linearGradient></defs>
        <path d="M14,82 C70,38 120,100 190,68 C250,42 300,86 388,46" fill="none" stroke="#7FB9DB" stroke-width="1.500" stroke-dasharray="1 7" stroke-linecap="round" opacity=".9"/>
        <text font-family="Bricolage" font-weight="720" font-size="33" letter-spacing=".5" fill="url(#callg)" style="font-variation-settings:'opsz' 40,'wdth' 92"><textPath href="#callp" startOffset="1%">“Urashima, Urashima!”</textPath></text></svg>
      <div class="txt t-adv" style="left:30px;top:186px;width:372px">
        <p>Clear as a bell and soft as the summer wind the name floated over the sea.</p>
        <p>He stood up and looked in every direction, thinking that one of the other boats had overtaken him, but gaze as he might over the wide expanse of water, near or far there was no sign of a boat, so the voice could not have come from any human being.</p>
      </div>
      <div class="foot" style="right:100px"><span class="chip glass pg">${pages(9, 5)}<span>5 / 19</span></span></div>
      <div class="next" style="--nx1:#FF8A70;--nx2:#F4503F;--nx3:#D8342B">${I.fwd}</div>`,
  }),
});

module.exports = screens;
});
