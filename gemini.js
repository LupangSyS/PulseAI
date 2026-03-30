// gemini.js — All Gemini Flash API calls

const Gemini = {
  MODEL: 'gemini-1.5-flash',
  BASE:  'https://generativelanguage.googleapis.com/v1beta/models',

  async ask(prompt, options = {}) {
    const key = Config.geminiKey;
    if (!key) throw new Error('Gemini API key not set. Click ⚙ to configure.');

    const url = `${this.BASE}/${this.MODEL}:generateContent?key=${key}`;
    const body = {
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: {
        temperature:     options.temperature     ?? 0.7,
        maxOutputTokens: options.maxOutputTokens ?? 512,
        topP:            options.topP            ?? 0.9,
      }
    };

    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err?.error?.message || `Gemini error ${res.status}`);
    }

    const data = await res.json();
    return data.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ?? '';
  },

  // Classify a news article into a topic
  async classifyTopic(title, description) {
    const topics = ['technology', 'business', 'politics', 'science', 'health', 'sports', 'world'];
    const prompt = `Classify the following news article into exactly ONE of these topics: ${topics.join(', ')}.
Respond with ONLY the single topic word, nothing else.

Title: ${title}
Description: ${description || ''}`;

    const result = await this.ask(prompt, { temperature: 0.1, maxOutputTokens: 10 });
    const clean = result.toLowerCase().trim();
    return topics.includes(clean) ? clean : 'world';
  },

  // Summarize & add insight to a news article
  async summarizeArticle(title, description, url) {
    const prompt = `You are a sharp news analyst. Summarize this article in 2–3 concise sentences, then add one "💡 Key Insight" sentence explaining why it matters.

Title: ${title}
Description: ${description || 'No description available.'}

Keep it under 120 words total. Be direct and insightful.`;
    return this.ask(prompt, { temperature: 0.6, maxOutputTokens: 180 });
  },

  // Answer a user question about current news context
  async answerNewsQuestion(question, newsContext) {
    const prompt = `You are PulseAI, an expert news analyst. Answer the following question based on today's top news headlines provided below.
Be concise, insightful, and use bullet points where helpful.

TODAY'S NEWS HEADLINES:
${newsContext}

USER QUESTION: ${question}

Provide a clear, well-structured answer in under 200 words.`;
    return this.ask(prompt, { temperature: 0.7, maxOutputTokens: 350 });
  },

  // Stock recommendation
  async stockRecommendation(symbol, name, price, change, changePercent) {
    const trend = changePercent >= 0 ? 'up' : 'down';
    const prompt = `You are a financial AI advisor. Analyze this stock and give a recommendation.

Stock: ${symbol} (${name})
Current Price: $${price}
Today's Change: ${change > 0 ? '+' : ''}${change} (${changePercent > 0 ? '+' : ''}${changePercent}%)
Trend: ${trend}

Respond in EXACTLY this JSON format (no markdown, no extra text):
{"action":"BUY","reason":"Brief 6-word reason","confidence":75}

action must be BUY, SELL, or HOLD.
confidence is 0-100.
reason is max 8 words.`;

    try {
      const result = await this.ask(prompt, { temperature: 0.3, maxOutputTokens: 80 });
      // Strip any markdown code fences
      const cleaned = result.replace(/```json|```/g, '').trim();
      return JSON.parse(cleaned);
    } catch (e) {
      // Fallback
      return { action: 'HOLD', reason: 'Insufficient data', confidence: 50 };
    }
  },

  // Market briefing
  async marketBriefing(stockData) {
    const lines = stockData.map(s =>
      `${s.symbol}: $${s.price} (${s.changePercent > 0 ? '+' : ''}${s.changePercent}%)`
    ).join('\n');

    const prompt = `You are a market strategist. Write a brief market overview (4–5 sentences) based on these current stock prices. Highlight trends, what's driving moves, and 1 actionable takeaway for investors.

CURRENT PRICES:
${lines}

Keep it professional, under 120 words.`;
    return this.ask(prompt, { temperature: 0.65, maxOutputTokens: 200 });
  }
};
