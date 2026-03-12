import { Router } from 'express';
import { getCurrentMetrics } from '../services/metrics.js';

const router = Router();

router.get('/', (req, res) => {
  if (!req.headers.authorization) {
    return res.status(401).json({ error: 'Missing token' });
  }
  const metrics = getCurrentMetrics();
  return res.json(metrics);
});

export default router;
