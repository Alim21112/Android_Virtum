import { Router } from 'express';
import { getCurrentMetrics } from '../services/metrics.js';
import { processHealthQuery } from '../services/chatEngine.js';

const router = Router();

router.post('/', async (req, res) => {
  if (!req.headers.authorization) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const { message } = req.body;

  try {
    const currentMetrics = getCurrentMetrics();
    console.log('\n[CHAT] ========================================');
    console.log('[CHAT] New message:', message);
    console.log('[CHAT] Current metrics:', currentMetrics);

    const reply = processHealthQuery(String(message ?? ''), currentMetrics);

    console.log('[CHAT] Generated reply (first 150 chars):', reply.substring(0, 150));
    console.log('[CHAT] ========================================\n');

    return res.json({ reply });
  } catch (error) {
    console.error('[CHAT] Error:', error);
    const currentMetrics = getCurrentMetrics();
    return res.json({ reply: processHealthQuery(message, currentMetrics) });
  }
});

export default router;
