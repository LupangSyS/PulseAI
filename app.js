// app.js — Main application controller

function showToast(message, duration = 3000) {
  const existing = document.querySelector('.toast');
  if (existing) existing.remove();
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), duration);
}

// ── SETTINGS MODAL ────────────────────────────────
const settingsModal = document.getElementById('settingsModal');
const btnSettings   = document.getElementById('btnSettings');
const modalClose    = document.getElementById('modalClose');
const saveKeys      = document.getElementById('saveKeys');

btnSettings.addEventListener('click', () => {
  document.getElementById('geminiKey').value = Config.geminiKey;
  document.getElementById('newsKey').value   = Config.newsKey;
  document.getElementById('stockKey').value  = Config.stockKey;
  settingsModal.classList.add('open');
});

modalClose.addEventListener('click', () => settingsModal.classList.remove('open'));
settingsModal.addEventListener('click', (e) => { if (e.target === settingsModal) settingsModal.classList.remove('open'); });

saveKeys.addEventListener('click', () => {
  Config.save(
    document.getElementById('geminiKey').value,
    document.getElementById('newsKey').value,
    document.getElementById('stockKey').value
  );
  Config.updateStatusBadge();
  settingsModal.classList.remove('open');
  showToast('✓ API keys saved');

  // Reload data with new keys
  News.load();
  Stocks.init();
});

// ── TOPIC FILTER ──────────────────────────────────
document.querySelectorAll('.topic-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.topic-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    News.currentTopic = btn.dataset.topic;
    News.render();
  });
});

// ── REFRESH NEWS ──────────────────────────────────
document.getElementById('btnRefreshNews').addEventListener('click', async function () {
  this.classList.add('spinning');
  await News.load(true);
  this.classList.remove('spinning');
  showToast('News refreshed');
});

// ── AI ASK BAR ────────────────────────────────────
const aiQuestion    = document.getElementById('aiQuestion');
const btnAskAI      = document.getElementById('btnAskAI');
const aiResponseBox = document.getElementById('aiResponseBox');
const aiResponseText = document.getElementById('aiResponseText');
const closeAiBox    = document.getElementById('closeAiBox');

async function askAI() {
  const q = aiQuestion.value.trim();
  if (!q) return;
  if (!Config.geminiKey) { showToast('⚙ Set your Gemini API key first'); settingsModal.classList.add('open'); return; }

  btnAskAI.textContent = '…';
  btnAskAI.disabled = true;
  aiResponseBox.style.display = 'block';
  aiResponseText.textContent = 'Thinking…';

  try {
    const context = News.getContextString();
    const answer  = await Gemini.answerNewsQuestion(q, context);
    aiResponseText.textContent = answer;
  } catch (err) {
    aiResponseText.textContent = '⚠ ' + err.message;
  }

  btnAskAI.textContent = 'Ask';
  btnAskAI.disabled = false;
}

btnAskAI.addEventListener('click', askAI);
aiQuestion.addEventListener('keydown', (e) => { if (e.key === 'Enter') askAI(); });
closeAiBox.addEventListener('click', () => {
  aiResponseBox.style.display = 'none';
  aiQuestion.value = '';
});

// ── STOCK SEARCH ──────────────────────────────────
const stockSearch  = document.getElementById('stockSearch');
const btnStockSearch = document.getElementById('btnStockSearch');

async function doStockSearch() {
  const q = stockSearch.value.trim();
  if (!q) return;
  await Stocks.search(q);
  stockSearch.value = '';
  // Refresh ticker
  setTimeout(() => Stocks.updateTicker(), 1000);
}

btnStockSearch.addEventListener('click', doStockSearch);
stockSearch.addEventListener('keydown', (e) => { if (e.key === 'Enter') doStockSearch(); });

// ── MARKET BRIEFING ───────────────────────────────
document.getElementById('btnMarketBrief').addEventListener('click', async function () {
  if (!Config.geminiKey) { showToast('⚙ Set your Gemini API key first'); settingsModal.classList.add('open'); return; }
  const el = document.getElementById('briefingText');
  el.textContent = '✦ Analyzing markets…';
  try {
    const stockList = Object.values(Stocks.stockData).slice(0, 8);
    if (!stockList.length) { el.textContent = 'No stock data yet. Stocks will load shortly.'; return; }
    const brief = await Gemini.marketBriefing(stockList);
    el.textContent = brief;
  } catch (err) {
    el.textContent = '⚠ ' + err.message;
  }
});

// ── INIT ──────────────────────────────────────────
async function init() {
  Config.updateStatusBadge();

  // If no keys configured, prompt user
  if (!Config.isReady()) {
    setTimeout(() => {
      showToast('👋 Welcome! Click ⚙ to add your API keys (Gemini is free)', 5000);
    }, 1500);
  }

  // Load data in parallel
  await Promise.all([
    News.load(),
    Stocks.init()
  ]);

  // Update ticker after stocks load
  setTimeout(() => Stocks.updateTicker(), 2000);

  // Auto-refresh every 15 minutes
  setInterval(async () => {
    await News.load(true);
    await Stocks.renderPopular();
    Stocks.updateTicker();
  }, 15 * 60 * 1000);
}

document.addEventListener('DOMContentLoaded', init);
