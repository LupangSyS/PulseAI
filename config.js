// config.js — API key management (stored in localStorage, never in repo)

const Config = {
  get geminiKey()  { return localStorage.getItem('pulseai_gemini') || ''; },
  get newsKey()    { return localStorage.getItem('pulseai_news')   || ''; },
  get stockKey()   { return localStorage.getItem('pulseai_stock')  || ''; },

  save(gemini, news, stock) {
    if (gemini) localStorage.setItem('pulseai_gemini', gemini.trim());
    if (news)   localStorage.setItem('pulseai_news',   news.trim());
    if (stock)  localStorage.setItem('pulseai_stock',  stock.trim());
  },

  isReady() {
    return !!(this.geminiKey);   // Gemini is the minimum requirement
  },

  updateStatusBadge() {
    const dot  = document.getElementById('statusDot');
    const text = document.getElementById('statusText');
    if (!dot || !text) return;
    if (this.geminiKey && this.newsKey && this.stockKey) {
      dot.className = 'status-dot ok';
      text.textContent = 'All APIs connected';
    } else if (this.geminiKey) {
      dot.className = 'status-dot warn';
      const missing = [];
      if (!this.newsKey)  missing.push('NewsAPI');
      if (!this.stockKey) missing.push('Alpha Vantage');
      text.textContent = `Missing: ${missing.join(', ')}`;
    } else {
      dot.className = 'status-dot';
      text.textContent = 'Configure API Keys';
    }
  }
};
