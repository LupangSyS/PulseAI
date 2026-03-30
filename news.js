// news.js — News fetching, rendering, topic classification

const News = {
  articles: [],
  currentTopic: 'all',
  cache: null,
  cacheTime: 0,
  CACHE_TTL: 10 * 60 * 1000, // 10 minutes

  // Fetch from NewsAPI (or mock if key not set)
  async fetch() {
    const key = Config.newsKey;
// Use real API if key available
    if (key) {
      try {
        // แปะ corsproxy กันเหนียวไว้ก่อน เผื่อโดนบล็อก CORS
        const url = `https://corsproxy.io/?https://newsdata.io/api/1/latest?apikey=${key}&language=en`;
        const res = await fetch(url);
        if (!res.ok) throw new Error('NewsData API error');
        const data = await res.json();
        
        // แปลงร่าง (Map) Data ของ NewsData ให้หน้าตาเหมือน NewsAPI
        // โค้ดส่วนอื่นของมึงอย่าง renderCard() จะได้ทำงานต่อได้เลยโดยไม่ต้องแก้!
        const results = data.results || [];
        return results.map(item => ({
          title: item.title,
          description: item.description,
          source: { name: item.source_id || 'News' }, // ค่ายนี้ใช้ source_id
          publishedAt: item.pubDate,                  // ค่ายนี้ใช้ pubDate
          url: item.link,                             // ค่ายนี้ใช้ link
          urlToImage: item.image_url,                 // ค่ายนี้ใช้ image_url
          _topic: null 
        }));

      } catch (e) {
        console.warn('NewsAPI failed, using fallback:', e.message);
      }
    }

    // Fallback: use NewsAPI without key for limited access, or show demo data
    return this.getDemoArticles();
  },

  getDemoArticles() {
    const now = new Date().toISOString();
    return [
      {
        title: "AI Models Achieve New Benchmarks in Reasoning Tasks",
        description: "Leading AI labs report significant breakthroughs in mathematical reasoning and code generation, pushing state-of-the-art performance across multiple domains.",
        source: { name: "Tech Review" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "technology"
      },
      {
        title: "Federal Reserve Signals Cautious Approach to Rate Cuts",
        description: "Fed officials indicate they need more evidence of sustained inflation decline before cutting interest rates, tempering market expectations for near-term easing.",
        source: { name: "Financial Times" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "business"
      },
      {
        title: "Global Climate Summit Reaches Landmark Carbon Agreement",
        description: "World leaders agree on binding emissions targets with enforcement mechanisms, marking the most significant climate deal in a decade.",
        source: { name: "Reuters" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "politics"
      },
      {
        title: "Breakthrough in Quantum Computing Achieves Error Correction Milestone",
        description: "Scientists demonstrate reliable quantum error correction at scale, a critical step toward practical quantum computers that could revolutionize drug discovery and cryptography.",
        source: { name: "Nature" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "science"
      },
      {
        title: "New Study Links Ultra-Processed Foods to Accelerated Brain Aging",
        description: "A comprehensive 10-year study of 30,000 participants finds strong correlations between ultra-processed food consumption and cognitive decline, adding to growing evidence about diet-brain health connections.",
        source: { name: "Health Wire" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "health"
      },
      {
        title: "EV Adoption Surges as Battery Costs Hit Record Low",
        description: "Battery pack prices fall below $90/kWh, a threshold analysts consider the tipping point for price parity with combustion vehicles in key markets.",
        source: { name: "Bloomberg" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "technology"
      },
      {
        title: "Southeast Asia Emerges as New Manufacturing Hub for Tech Giants",
        description: "Apple, Samsung and other tech companies accelerate supply chain diversification into Vietnam, Indonesia and Thailand, reshaping regional economies.",
        source: { name: "WSJ" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "business"
      },
      {
        title: "Cybersecurity Threats Rise as AI-Powered Attacks Increase",
        description: "Security firms report a 340% increase in AI-generated phishing attacks, prompting calls for new regulatory frameworks and industry cooperation.",
        source: { name: "Wired" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "technology"
      },
      {
        title: "Historic Mars Mission Returns First Human Crew Safely",
        description: "The first crewed Mars mission completes its 3-year journey, with astronauts returning healthy and carrying scientific samples that scientists say could rewrite our understanding of planetary formation.",
        source: { name: "Space.com" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "science"
      },
      {
        title: "Global Trade Tensions Ease as Major Economies Sign New Pact",
        description: "A landmark multilateral trade agreement between the US, EU and 14 other nations reduces tariffs on clean energy technology, semiconductors and agricultural goods.",
        source: { name: "AP News" },
        publishedAt: now,
        url: "#",
        urlToImage: null,
        _topic: "world"
      }
    ];
  },

  async classifyArticles(articles) {
    // If Gemini key available, classify in batches
    if (Config.geminiKey) {
      const unclassified = articles.filter(a => !a._topic);
      // Classify first 15 to avoid rate limits
      const batch = unclassified.slice(0, 15);
      await Promise.allSettled(batch.map(async (article) => {
        try {
          article._topic = await Gemini.classifyTopic(article.title, article.description);
        } catch {
          article._topic = 'world';
        }
      }));
      // Rest get 'world' as fallback
      unclassified.slice(15).forEach(a => { a._topic = a._topic || 'world'; });
    } else {
      articles.forEach(a => { a._topic = a._topic || 'world'; });
    }
    return articles;
  },

  timeAgo(dateStr) {
    const diff = Date.now() - new Date(dateStr).getTime();
    const m = Math.floor(diff / 60000);
    if (m < 1)  return 'just now';
    if (m < 60) return `${m}m ago`;
    const h = Math.floor(m / 60);
    if (h < 24) return `${h}h ago`;
    return `${Math.floor(h / 24)}d ago`;
  },

  renderCard(article, index) {
    const div = document.createElement('div');
    div.className = 'news-card';
    div.style.animationDelay = `${index * 0.04}s`;

    const imageUrl = article.image || article.urlToImage;
const imgHtml = imageUrl
  ? `<img class="news-img" src="${imageUrl}" alt="" onerror="this.style.display='none'" loading="lazy" />`
  : '';

    div.innerHTML = `
      <div class="news-card-top">
        <div class="news-title">${article.title || 'Untitled'}</div>
        ${imgHtml}
      </div>
      <div class="news-meta">
        <span class="news-source">${article.source?.name || 'Unknown'}</span>
        <span class="news-time">${this.timeAgo(article.publishedAt)}</span>
        <span class="news-topic ${article._topic || ''}">${article._topic || 'general'}</span>
      </div>
      ${article.description ? `<div class="news-desc">${article.description}</div>` : ''}
      <div class="news-actions">
        <button class="btn-summarize">✦ AI Summary</button>
        ${article.url && article.url !== '#' ? `<a href="${article.url}" target="_blank" rel="noopener" style="font-size:0.72rem;color:var(--text3);text-decoration:none;">Read full →</a>` : ''}
      </div>
    `;

    // AI Summary button
    const btn = div.querySelector('.btn-summarize');
    btn.addEventListener('click', async (e) => {
      e.stopPropagation();
      if (btn.classList.contains('loading')) return;

      // Check if summary already shown
      const existing = div.querySelector('.news-ai-summary');
      if (existing) { existing.remove(); btn.textContent = '✦ AI Summary'; return; }

      btn.textContent = '…loading';
      btn.classList.add('loading');

      try {
        const summary = await Gemini.summarizeArticle(article.title, article.description, article.url);
        const summaryEl = document.createElement('div');
        summaryEl.className = 'news-ai-summary';
        summaryEl.textContent = summary;
        div.appendChild(summaryEl);
        btn.textContent = '✕ Close';
      } catch (err) {
        showToast('⚠ ' + err.message);
        btn.textContent = '✦ AI Summary';
      }
      btn.classList.remove('loading');
    });

    return div;
  },

  render() {
    const feed = document.getElementById('newsFeed');
    if (!feed) return;

    const filtered = this.currentTopic === 'all'
      ? this.articles
      : this.articles.filter(a => a._topic === this.currentTopic);

    feed.innerHTML = '';

    if (!filtered.length) {
      feed.innerHTML = '<div class="empty-state">No articles found for this topic.</div>';
      return;
    }

    filtered.forEach((article, i) => {
      feed.appendChild(this.renderCard(article, i));
    });
  },

  async load(forceRefresh = false) {
    const loading = document.getElementById('newsLoading');
    const feed    = document.getElementById('newsFeed');
    if (loading) { feed.innerHTML = ''; feed.appendChild(loading); loading.style.display = 'flex'; }

    try {
      let articles = await this.fetch();
      articles = await this.classifyArticles(articles);
      this.articles = articles;
      this.render();
    } catch (err) {
      if (feed) feed.innerHTML = `<div class="empty-state">Failed to load news: ${err.message}</div>`;
    }
  },

  getContextString() {
    return this.articles.slice(0, 20).map(a => `• ${a.title} (${a._topic})`).join('\n');
  }
};
