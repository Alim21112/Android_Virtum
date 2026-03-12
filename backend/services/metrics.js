import { defaultMetrics } from '../config.js';

function jitter(value, delta) {
  return Math.max(0, Math.round(value + (Math.random() * delta - delta / 2)));
}

export function getCurrentMetrics() {
  return {
    ...defaultMetrics,
    heartRate: jitter(defaultMetrics.heartRate, 8),
    steps: jitter(defaultMetrics.steps, 1200),
    waterIntakeLiters: Math.max(
      0,
      Number((defaultMetrics.waterIntakeLiters + Math.random() * 0.3).toFixed(1))
    ),
  };
}
