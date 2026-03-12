export function analyzeIntent(message) {
  const text = message.toLowerCase();
  return {
    isGreeting: /^(hi|hello|hey|greetings)$/i.test(text.trim()),
    isGeneralHealth: /how (am i|are my)|my health|overall|status|summary|doing/i.test(text),
    isHeartRate: /heart|pulse|bpm|heartbeat/i.test(text),
    isSteps: /steps|walk|activity|exercise|movement/i.test(text),
    isWater: /water|hydrat|drink/i.test(text),
    isBloodPressure: /blood pressure|pressure|bp/i.test(text),
    isOxygen: /oxygen|spo2|o2/i.test(text),
    isTemperature: /temperature|temp|fever/i.test(text),
    isAllMetrics: /all metrics|everything|full report|complete/i.test(text),
    isRecommendation: /recommend|advice|suggest|tip|should i|what to do/i.test(text),
  };
}

export function calculateSimilarity(str1, str2) {
  const words1 = str1.split(/\s+/).filter((w) => w.length > 3);
  const words2 = str2.split(/\s+/).filter((w) => w.length > 3);
  const commonWords = words1.filter((w) => words2.includes(w));
  return commonWords.length / Math.max(words1.length, words2.length, 1);
}
