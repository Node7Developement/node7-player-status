const hud = document.getElementById('hud');
const leftStatus = document.getElementById('left-status');
const economy = document.getElementById('economy');

const values = {
    job: document.getElementById('job-value'),
    duty: document.getElementById('duty-value'),
    time: document.getElementById('time-value'),
    radio: document.getElementById('radio-value'),
    online: document.getElementById('online-value'),
};

const rows = {
    job: document.querySelector('[data-row="job"]'),
    duty: document.querySelector('[data-row="duty"]'),
    time: document.querySelector('[data-row="time"]'),
    radio: document.querySelector('[data-row="radio"]'),
    online: document.querySelector('[data-row="online"]'),
};

const economyEntries = {
    bank: document.querySelector('[data-economy="bank"]'),
    gold: document.querySelector('[data-economy="gold"]'),
    cash: document.querySelector('[data-economy="cash"]'),
};

let lastLayout = {};
const lastAmounts = { bank: null, gold: null, cash: null };
const changeTimers = {};

function finiteNumber(value, fallback = 0) {
    const number = Number(value);
    return Number.isFinite(number) ? number : fallback;
}

function setVisible(visible) {
    const show = visible === true;
    hud.classList.toggle('visible', show);
    hud.setAttribute('aria-hidden', show ? 'false' : 'true');
}

function applyLayout(layout = {}) {
    lastLayout = layout;
    const referenceWidth = Math.max(1, finiteNumber(layout.referenceWidth, 1920));
    const referenceHeight = Math.max(1, finiteNumber(layout.referenceHeight, 1080));
    const configuredScale = Math.max(.5, Math.min(2, finiteNumber(layout.scale, 1)));
    const responsiveScale = Math.min(window.innerWidth / referenceWidth, window.innerHeight / referenceHeight);
    const scale = configuredScale * responsiveScale;

    document.documentElement.style.setProperty('--layout-scale', String(scale));
    document.documentElement.style.setProperty('--left-x', `${finiteNumber(layout.leftX, 22)}px`);
    document.documentElement.style.setProperty('--left-y', `${finiteNumber(layout.leftY, 54)}px`);
    document.documentElement.style.setProperty('--left-gap', `${finiteNumber(layout.leftRowGap, 34)}px`);
    document.documentElement.style.setProperty('--economy-top', `${finiteNumber(layout.economyTop, 30)}px`);
    document.documentElement.style.setProperty('--economy-right', `${finiteNumber(layout.economyRight, 250)}px`);
    document.documentElement.style.setProperty('--economy-gap', `${finiteNumber(layout.economyGap, 52)}px`);
}

function splitAmount(value) {
    const number = Math.max(0, finiteNumber(value));
    const fixed = number.toFixed(2);
    const [whole, decimal] = fixed.split('.');
    return {
        whole: Number(whole).toLocaleString('en-US'),
        decimal,
    };
}

function setAmount(prefix, value) {
    const amount = splitAmount(value);
    const normalized = `${amount.whole}.${amount.decimal}`;
    const changed = lastAmounts[prefix] !== null && lastAmounts[prefix] !== normalized;

    document.getElementById(`${prefix}-main`).textContent = amount.whole;
    document.getElementById(`${prefix}-decimal`).textContent = amount.decimal;
    lastAmounts[prefix] = normalized;

    if (!changed) return;

    const entry = economyEntries[prefix];
    entry.classList.remove('changed');
    void entry.offsetWidth;
    entry.classList.add('changed');

    clearTimeout(changeTimers[prefix]);
    changeTimers[prefix] = setTimeout(() => entry.classList.remove('changed'), 320);
}

function setSectionVisibility(sections = {}) {
    const left = sections.left || {};
    const money = sections.economy || {};

    leftStatus.style.display = left.enabled === false ? 'none' : 'flex';
    economy.style.display = money.enabled === false ? 'none' : 'flex';

    rows.job.style.display = left.showJob === false ? 'none' : 'flex';
    rows.duty.style.display = left.showDuty === false ? 'none' : 'flex';
    rows.time.style.display = left.showGameTime === false ? 'none' : 'flex';
    rows.radio.style.display = left.showRadio === false ? 'none' : 'flex';
    rows.online.style.display = left.showOnlinePlayers === false ? 'none' : 'flex';

    economyEntries.bank.style.display = money.showBank === false ? 'none' : 'flex';
    economyEntries.gold.style.display = money.showGold === false ? 'none' : 'flex';
    economyEntries.cash.style.display = money.showCash === false ? 'none' : 'flex';
}

function update(data) {
    applyLayout(data.layout || {});
    setSectionVisibility(data.sections || {});

    const status = data.status || {};
    const money = data.economy || {};

    values.job.textContent = String(status.job || 'UNEMPLOYED_0');
    values.duty.textContent = String(status.duty || 'OFF DUTY');
    values.time.textContent = String(status.time || '12:00 AM');
    values.radio.textContent = String(status.radio || 'OFF');
    values.online.textContent = String(Math.max(0, Math.floor(finiteNumber(status.online))));

    rows.duty.classList.toggle('active', status.dutyActive === true);
    rows.radio.classList.toggle('active', status.radioActive === true);

    setAmount('bank', money.bank);
    setAmount('gold', money.gold);
    setAmount('cash', money.cash);
    setVisible(data.visible === true);
}

window.addEventListener('message', (event) => {
    const message = event.data || {};

    if (message.action === 'visibility') {
        setVisible(message.visible === true);
        return;
    }

    if (message.action === 'update') {
        update(message);
    }
});

window.addEventListener('resize', () => applyLayout(lastLayout));

// Browser preview only. CFX NUI never supplies this query parameter.
if (new URLSearchParams(window.location.search).has('preview')) {
    update({
        visible: true,
        layout: {},
        sections: {
            left: { enabled: true },
            economy: { enabled: true },
        },
        status: {
            job: 'VALLAW_1',
            duty: 'OFF DUTY',
            dutyActive: false,
            time: '03:42 AM',
            radio: 'OFF',
            radioActive: false,
            online: 1,
        },
        economy: {
            bank: 0,
            gold: 3.50,
            cash: 4180,
        },
    });
}
