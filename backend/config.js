export const port = Number(process.env.PORT) || 3000;

export const defaultMetrics = {
  heartRate: 74,
  bloodPressure: '118/76',
  steps: 6500,
  waterIntakeLiters: 1.8,
  oxygen: 97,
  temperature: 36.6,
  insight: 'Your health metrics are within normal ranges.',
};

export const chat = {
  maxRecentResponses: 5,
};
