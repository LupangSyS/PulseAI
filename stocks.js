// stocks.js — Stock price fetching, rendering, favorites

const Stocks = {
  watchlist: [],
  popular: ['AAPL', 'MSFT', 'GOOGL', 'NVDA', 'TSLA', 'AMZN', 'META', 'BRK.B'],
  stockData: {},         // symbol -> { price, change, changePercent, name }
  recommendations: {},   // symbol -> { action, reason, confidence }
  recQueue: [],
  recPending: false,

  KNOWN_NAMES: {
    AAPL: 'Apple Inc.', MSFT: 'Microsoft', GOOGL: 'Alphabet', NVDA: 'NVIDIA',
    TSLA: 'Tesla', AMZN: 'Amazon', META: 'Meta Platforms', 'BRK.B': 'Berkshire',
    SPY: 'S&P 500 ETF', QQQ: 'Nasdaq ETF', NFLX: 'Netflix', AMD: 'AMD',
    INTC: 'Intel', DIS: 'Disney', BABA: 'Alibaba', UBER: 'Uber',
    COIN: 'Coinbase', PLTR: 'Palantir', SOFI: 'SoFi', NIO: 'NIO Inc.',
  },

  loadFavorites() {
    try {
      this.watchlist = JSON.parse(localStorage.getItem('pulseai_watchlist') || '[]');
    } catch { this.watchlist = []; }
  },

  saveFavorites() {
    localStorage.setItem('pulseai_watchlist', JSON.stringify(this.watchlist));
  },

  toggleFavorite(symbol) {
    const idx = this.watchlist.indexOf(symbol);
    if (idx >= 0) this.watchlist.splice(idx, 1);
    else           this.watchlist.unshift(symbol);
    this.saveFavorites();
    this.renderWatchlist();
    this.renderPopular();
  },

  isFavorite(symbol) { return this.watchlist.includes(symbol); },

  // Fetch real price from Alpha Vantage (or use demo data)
  async fetchPrice(symbol) {
    const key = Config.stockKey;
    if (!key) return this.getDemoPrice(symbol);

    try {
      const url = `https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${symbol}&apikey=${key}`;
      const res  = await fetch(url);
      const data = await res.json();
      const q    = data['Global Quote'];
      if (!q || !q['05. price']) return this.getDemoPrice(symbol);

      return {
        symbol,
        name:          this.KNOWN_NAMES[symbol] || symbol,
        price:         parseFloat(q['05. price']).toFixed(2),
        change:        parseFloat(q['09. change']).toFixed(2),
        changePercent: parseFloat(q['10. change percent']).replace('%','').trim()
      };
    } catch {
      return this.getDemoPrice(symbol);
    }
  },

  getDemoPrice(symbol) {
    // Deterministic demo prices based on symbol hash
    const seed = symbol.split('').reduce((a, c) => a + c.charCodeAt(0), 0);
    const base  = 50 + (seed % 450);
    const chg   = ((seed % 21) - 10) * 0.5;
    return {
      symbol,
      name:          this.KNOWN_NAMES[symbol] || symbol,
      price:         (base + chg).toFixed(2),
      change:        chg.toFixed(2),
      changePercent: ((chg / base) * 100).toFixed(2)
    };
  },

  // Queue-based AI recommendation (avoid rate limits)
  async getRecommendation(stockInfo) {
    if (this.recommendations[stockInfo.symbol]) return this.recommendations[stockInfo.symbol];
    if (!Config.geminiKey) return { action: 'HOLD', reason: 'API key required', confidence: 50 };

    return new Promise((resolve) => {
      this.recQueue.push({ stockInfo, resolve });
      this.processQueue();
    });
  },

  async processQueue() {
    if (this.recPending || !this.recQueue.length) return;
    this.recPending = true;
    const { stockInfo, resolve } = this.recQueue.shift();
    try {
      const rec = await Gemini.stockRecommendation(
        stockInfo.symbol, stockInfo.name,
        stockInfo.price, stockInfo.change, stockInfo.changePercent
      );
      this.recommendations[stockInfo.symbol] = rec;
      resolve(rec);
    } catch {
      resolve({ action: 'HOLD', reason: 'Analysis unavailable', confidence: 50 });
    }
    this.recPending = false;
    // Throttle: 1 request per 2s
    setTimeout(() => this.processQueue(), 2000);
  },

  createStockCard(stockInfo) {
    const div = document.createElement('div');
    div.className = 'stock-card';
    div.dataset.symbol = stockInfo.symbol;

    const up   = parseFloat(stockInfo.changePercent) >= 0;
    const sign = up ? '+' : '';
    const isFav = this.isFavorite(stockInfo.symbol);

    div.innerHTML = `
      <div class="stock-sym">${stockInfo.symbol}</div>
      <div class="stock-price">$${stockInfo.price}</div>
      <div class="stock-name">${stockInfo.name}</div>
      <div class="stock-change ${up ? 'up' : 'down'}">${sign}${stockInfo.change} (${sign}${stockInfo.changePercent}%)</div>
      <div class="stock-rec">
        <span class="rec-badge loading">…</span>
        <span class="rec-reason"></span>
      </div>
      <button class="stock-fav-btn ${isFav ? 'active' : ''}" title="${isFav ? 'Remove from watchlist' : 'Add to watchlist'}">
        ${isFav ? '⭐' : '☆'}
      </button>
    `;

    // Favorite toggle
    const favBtn = div.querySelector('.stock-fav-btn');
    favBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      this.toggleFavorite(stockInfo.symbol);
    });

    // Load AI recommendation asynchronously
    this.getRecommendation(stockInfo).then(rec => {
      const badge  = div.querySelector('.rec-badge');
      const reason = div.querySelector('.rec-reason');
      if (badge && rec) {
        badge.className = `rec-badge ${rec.action}`;
        badge.textContent = rec.action;
        if (reason) reason.textContent = rec.reason || '';
      }
    });

    return div;
  },

  async renderWatchlist() {
    const container = document.getElementById('watchlist');
    if (!container) return;
    container.innerHTML = '';

    if (!this.watchlist.length) {
      container.innerHTML = '<div style="font-size:0.75rem;color:var(--text3);padding:8px 4px">Search for stocks and ☆ to add</div>';
      return;
    }

    for (const symbol of this.watchlist) {
      let info = this.stockData[symbol];
      if (!info) {
        info = await this.fetchPrice(symbol);
        this.stockData[symbol] = info;
      }
      container.appendChild(this.createStockCard(info));
    }
  },

  async renderPopular() {
    const container = document.getElementById('popularStocks');
    if (!container) return;
    container.innerHTML = '';

    for (const symbol of this.popular) {
      let info = this.stockData[symbol];
      if (!info) {
        info = await this.fetchPrice(symbol);
        this.stockData[symbol] = info;
      }
      container.appendChild(this.createStockCard(info));
    }
  },

  async search(query) {
    const symbol = query.trim().toUpperCase().replace(/[^A-Z.]/g, '');
    if (!symbol || symbol.length > 6) { showToast('Enter a valid ticker symbol'); return; }

    const info = await this.fetchPrice(symbol);
    this.stockData[symbol] = info;

    // Show result temporarily highlighted
    const container = document.getElementById('popularStocks');
    if (container) {
      const card = this.createStockCard(info);
      card.style.border = '1px solid var(--accent)';
      card.style.background = 'rgba(79,124,255,0.06)';
      container.prepend(card);
      setTimeout(() => { card.style.border = ''; card.style.background = ''; }, 3000);
    }

    // Auto-add to watchlist
    if (!this.isFavorite(symbol)) {
      this.watchlist.unshift(symbol);
      this.saveFavorites();
      this.renderWatchlist();
    }
  },

  updateTicker() {
    const inner = document.getElementById('tickerInner');
    if (!inner || !Object.keys(this.stockData).length) return;

    const items = Object.values(this.stockData).map(s => {
      const up = parseFloat(s.changePercent) >= 0;
      return `<span class="ticker-item">
        <span class="ticker-symbol">${s.symbol}</span>
        <span class="ticker-price">$${s.price}</span>
        <span class="ticker-change ${up ? 'up' : 'down'}">${up ? '▲' : '▼'}${Math.abs(s.changePercent)}%</span>
      </span>`;
    }).join('');

    // Duplicate for seamless loop
    inner.innerHTML = items + items;
  },

  updateMarketTime() {
    const el = document.getElementById('marketTime');
    if (!el) return;
    const now = new Date();
    const ny  = new Date(now.toLocaleString('en-US', { timeZone: 'America/New_York' }));
    const h   = ny.getHours();
    const isOpen = ny.getDay() >= 1 && ny.getDay() <= 5 && h >= 9 && (h < 16 || (h === 9 && ny.getMinutes() >= 30));
    el.innerHTML = `<span style="color:${isOpen ? 'var(--green)' : 'var(--red)'}">${isOpen ? '● OPEN' : '● CLOSED'}</span> NYSE`;
  },

  async init() {
    this.loadFavorites();
    this.updateMarketTime();
    setInterval(() => this.updateMarketTime(), 30000);

    await this.renderWatchlist();
    await this.renderPopular();
    this.updateTicker();
  }
};
