import { defaultMetrics } from '../config.js';
import { analyzeIntent, calculateSimilarity } from './intentAnalyzer.js';

const recentResponses = [];

export function generateResponse(message, metrics, maxRecent = 5) {
  const m = metrics || defaultMetrics;
  const intent = analyzeIntent(message);

  console.log('[AI] Processing:', message);
  console.log('[AI] Intent detected:', JSON.stringify(intent, null, 2));
  console.log('[AI] Using metrics:', {
    heartRate: m.heartRate,
    steps: m.steps,
    water: m.waterIntakeLiters,
    bp: m.bloodPressure,
  });

  if (intent.isGreeting) {
    const greetings = [
      `Hello! Your current stats: ${m.steps.toLocaleString()} steps and ${m.heartRate} bpm. What would you like to know?`,
      `Hi there! I can see you've got ${m.heartRate} bpm heart rate and ${m.waterIntakeLiters}L water intake. How can I help?`,
      `Hey! You've taken ${m.steps.toLocaleString()} steps today. Want insights on any metric?`,
    ];
    return greetings[Math.floor(Math.random() * greetings.length)];
  }

  if (intent.isBloodPressure) {
    console.log('[AI] Blood pressure request detected!');
    const [systolic, diastolic] = m.bloodPressure.split('/').map(Number);
    const isOptimal = systolic < 120 && diastolic < 80;
    const isNormal = systolic < 130 && diastolic < 85;
    const isElevated = systolic < 140 && diastolic < 90;
    const status = isOptimal ? '🟢 Optimal' : isNormal ? '🟢 Normal' : isElevated ? '🟡 Elevated' : '🔴 High';
    const advice = isOptimal
      ? 'Perfect! Continue your healthy lifestyle habits.'
      : isNormal
        ? 'Good reading. Keep monitoring and maintain a balanced diet.'
        : 'Consider reducing sodium intake, increasing exercise, and consulting a healthcare provider if readings stay elevated.';
    return (
      `🩺 Blood Pressure Analysis:\n\n` +
      `Current Reading: ${m.bloodPressure} mmHg\n` +
      `Status: ${status}\n\n` +
      `📊 Reference Ranges:\n` +
      `• Optimal: <120/80 mmHg\n` +
      `• Normal: <130/85 mmHg\n` +
      `• Elevated: 130-139/85-89 mmHg\n\n` +
      `💡 ${advice}`
    );
  }

  if (intent.isHeartRate) {
    const status =
      m.heartRate < 60 ? 'low (bradycardia)' : m.heartRate > 100 ? 'elevated (tachycardia)' : 'perfectly normal';
    const context =
      m.heartRate < 60
        ? 'This can be normal for well-trained athletes. However, if you feel dizzy, fatigued, or have chest pain, consult a doctor.'
        : m.heartRate > 100
          ? 'This could be due to stress, caffeine, recent physical activity, or anxiety. If it persists while resting, consider seeing a healthcare provider.'
          : 'This indicates good cardiovascular health. Your heart is pumping efficiently.';
    return (
      `Your heart rate is currently ${m.heartRate} bpm, which is ${status}.\n\n` +
      `📊 Normal range: 60-100 bpm (resting)\n` +
      `💡 Context: ${context}\n\n` +
      `Your other cardiovascular metrics are also good: Blood pressure ${m.bloodPressure} mmHg, Oxygen ${m.oxygen}%.`
    );
  }

  if (intent.isSteps) {
    const progress = ((m.steps / 10000) * 100).toFixed(0);
    const remaining = Math.max(0, 10000 - m.steps);
    let assessment, advice;
    if (m.steps >= 10000) {
      assessment = "🌟 Outstanding! You've exceeded your daily goal!";
      advice = 'Keep up this excellent activity level. Regular walking reduces heart disease risk by 31%.';
    } else if (m.steps >= 7000) {
      assessment = `💪 Great progress! You're at ${progress}% of your goal.`;
      advice = `Just ${remaining.toLocaleString()} steps more (about a 15-minute walk) to hit 10,000 today.`;
    } else if (m.steps >= 4000) {
      assessment = `👍 You're making progress at ${progress}%.`;
      advice = `You need ${remaining.toLocaleString()} more steps. A brisk 30-minute walk adds ~3,000 steps.`;
    } else {
      assessment = `📈 Current activity: ${m.steps.toLocaleString()} steps (${progress}%).`;
      advice = `Try to reach at least 5,000 steps today. Take the stairs, park farther away, or take short walking breaks every hour.`;
    }
    return (
      `🚶 Step Count Analysis:\n\n` +
      `Current: ${m.steps.toLocaleString()} steps\n` +
      `Goal: 10,000 steps\n` +
      `Progress: ${progress}%\n\n` +
      `${assessment}\n\n` +
      `💡 ${advice}`
    );
  }

  if (intent.isWater) {
    const progress = ((m.waterIntakeLiters / 2.5) * 100).toFixed(0);
    const remaining = Math.max(0, 2.5 - m.waterIntakeLiters).toFixed(1);
    let status, advice;
    if (m.waterIntakeLiters >= 2.5) {
      status = "💯 Perfect! You've met your daily hydration goal.";
      advice = 'Excellent hydration supports kidney function, skin health, and mental clarity.';
    } else if (m.waterIntakeLiters >= 2.0) {
      status = `💧 Good hydration at ${progress}%.`;
      advice = `Just ${remaining}L more (about 2-3 glasses) to reach optimal hydration.`;
    } else if (m.waterIntakeLiters >= 1.5) {
      status = `⚠️ Moderate hydration at ${progress}%.`;
      advice = `Drink ${remaining}L more today. Dehydration can cause fatigue and reduced focus.`;
    } else {
      status = `🚨 Low hydration at ${progress}%.`;
      advice = `You need ${remaining}L more water. Keep a water bottle nearby and set hourly reminders.`;
    }
    return (
      `💧 Hydration Status:\n\n` +
      `Current: ${m.waterIntakeLiters}L\n` +
      `Daily Goal: 2.5L\n` +
      `Progress: ${progress}%\n\n` +
      `${status}\n\n` +
      `💡 ${advice}`
    );
  }

  if (intent.isOxygen) {
    const status =
      m.oxygen >= 95 ? '🟢 Excellent' : m.oxygen >= 90 ? '🟡 Acceptable (monitor)' : '🔴 Low (seek medical attention)';
    const advice =
      m.oxygen >= 95
        ? 'Your lungs and circulatory system are functioning optimally.'
        : m.oxygen >= 90
          ? 'This is on the lower end. Monitor for symptoms like shortness of breath.'
          : 'Levels below 90% require immediate medical evaluation.';
    return (
      `🫁 Blood Oxygen Analysis:\n\n` +
      `Current: ${m.oxygen}%\n` +
      `Status: ${status}\n` +
      `Normal Range: 95-100%\n\n` +
      `💡 ${advice}`
    );
  }

  if (intent.isTemperature) {
    const isNormal = m.temperature >= 36.1 && m.temperature <= 37.2;
    const isFever = m.temperature > 37.5;
    const status = isNormal ? '🟢 Normal' : isFever ? '🔴 Elevated (possible fever)' : '🔵 Below normal';
    const advice = isNormal
      ? 'Your body temperature is in the healthy range.'
      : isFever
        ? 'Monitor for other symptoms. If it rises above 38°C or persists with other symptoms, consult a doctor.'
        : "This is slightly low. Ensure you're warm, rested, and properly nourished.";
    return (
      `🌡️ Body Temperature:\n\n` +
      `Current: ${m.temperature}°C\n` +
      `Status: ${status}\n` +
      `Normal Range: 36.1-37.2°C\n\n` +
      `💡 ${advice}`
    );
  }

  if (intent.isGeneralHealth) {
    const heartOk = m.heartRate >= 60 && m.heartRate <= 100;
    const stepsProgress = ((m.steps / 10000) * 100).toFixed(0);
    const waterProgress = ((m.waterIntakeLiters / 2.5) * 100).toFixed(0);
    const stepsOk = m.steps >= 7000;
    const waterOk = m.waterIntakeLiters >= 2.0;
    const statusEmoji = heartOk && stepsOk ? '✅' : '⚠️';
    return (
      `${statusEmoji} Here's your complete health status:\n\n` +
      `❤️ Heart Rate: ${m.heartRate} bpm ${heartOk ? '(healthy)' : '(check needed)'}\n` +
      `🚶 Steps: ${m.steps.toLocaleString()} (${stepsProgress}% of daily goal)\n` +
      `💧 Water: ${m.waterIntakeLiters}L (${waterProgress}% of daily goal)\n` +
      `🩺 Blood Pressure: ${m.bloodPressure} mmHg (normal)\n` +
      `🫁 Oxygen: ${m.oxygen}% (excellent)\n` +
      `🌡️ Temperature: ${m.temperature}°C (normal)\n\n` +
      `Overall: ${
        heartOk && stepsOk && waterOk
          ? "You're doing great! All key metrics are healthy."
          : "You're doing well, but there's room for improvement in " +
            [!stepsOk && 'activity', !waterOk && 'hydration', !heartOk && 'heart rate'].filter(Boolean).join(' and ') +
            '.'
      }`
    );
  }

  if (intent.isAllMetrics) {
    return (
      `📊 Complete Health Dashboard\n\n` +
      `❤️ HEART RATE: ${m.heartRate} bpm\n` +
      `   Normal: 60-100 bpm | Status: ${m.heartRate >= 60 && m.heartRate <= 100 ? '✓ Healthy' : '⚠ Check'}\n\n` +
      `🩺 BLOOD PRESSURE: ${m.bloodPressure} mmHg\n` +
      `   Normal: <120/80 | Status: ✓ Normal\n\n` +
      `🚶 STEPS: ${m.steps.toLocaleString()}\n` +
      `   Goal: 10,000 | Progress: ${((m.steps / 10000) * 100).toFixed(0)}%\n\n` +
      `💧 WATER: ${m.waterIntakeLiters}L\n` +
      `   Goal: 2.5L | Progress: ${((m.waterIntakeLiters / 2.5) * 100).toFixed(0)}%\n\n` +
      `🫁 OXYGEN: ${m.oxygen}%\n` +
      `   Normal: 95-100% | Status: ✓ Excellent\n\n` +
      `🌡️ TEMPERATURE: ${m.temperature}°C\n` +
      `   Normal: 36.1-37.2°C | Status: ✓ Normal\n\n` +
      `Ask me about any specific metric for detailed insights!`
    );
  }

  if (intent.isRecommendation) {
    const suggestions = [];
    if (m.steps < 5000) {
      suggestions.push(
        `🚶 **Increase Activity**: You're at ${m.steps.toLocaleString()} steps. Aim for 7,000+ today. Even a 20-minute walk adds 2,000 steps.`
      );
    }
    if (m.waterIntakeLiters < 2.0) {
      suggestions.push(
        `💧 **Hydrate More**: At ${m.waterIntakeLiters}L, you need ${(2.5 - m.waterIntakeLiters).toFixed(1)}L more. Try drinking a glass of water every 2 hours.`
      );
    }
    if (m.heartRate > 85) {
      suggestions.push(
        `❤️ **Manage Stress**: Heart rate is ${m.heartRate} bpm. Try deep breathing, meditation, or light stretching exercises.`
      );
    }
    if (m.steps >= 7000 && m.waterIntakeLiters >= 2.0 && m.heartRate >= 60 && m.heartRate <= 85) {
      suggestions.push(`🌟 **You're Crushing It!**: All metrics are in excellent ranges. Keep up your healthy routine!`);
    }
    if (suggestions.length === 0) {
      suggestions.push(
        `✅ **All Metrics Look Great!** Your heart rate (${m.heartRate} bpm), activity level (${m.steps.toLocaleString()} steps), and hydration (${m.waterIntakeLiters}L) are all in healthy ranges. Just maintain your current routine.`
      );
    }
    return (
      `💡 Personalized Health Recommendations:\n\n${suggestions.join('\n\n')}\n\n` +
      `Your blood pressure (${m.bloodPressure} mmHg), oxygen (${m.oxygen}%), and temperature (${m.temperature}°C) are all excellent!`
    );
  }

  const heartStatus =
    m.heartRate >= 60 && m.heartRate <= 100 ? 'healthy' : m.heartRate < 60 ? 'low' : 'elevated';
  const stepsPercent = ((m.steps / 10000) * 100).toFixed(0);
  const waterPercent = ((m.waterIntakeLiters / 2.5) * 100).toFixed(0);
  const responses = [
    `I'm analyzing your health data. Your heart rate is ${m.heartRate} bpm (${heartStatus}), you've taken ${m.steps.toLocaleString()} steps (${stepsPercent}% of goal), and consumed ${m.waterIntakeLiters}L water (${waterPercent}% of goal). Your blood pressure (${m.bloodPressure} mmHg) and temperature (${m.temperature}°C) are both normal. What specific metric would you like to explore?`,
    `Here's what I see: Heart rate at ${m.heartRate} bpm, ${m.steps.toLocaleString()} steps logged, ${m.waterIntakeLiters}L water intake. Your BP reads ${m.bloodPressure} mmHg and oxygen is ${m.oxygen}%. All vitals are stable. Ask me about any metric for detailed insights!`,
    `Current health snapshot: ${m.heartRate} bpm heart rate (${heartStatus}), ${m.steps.toLocaleString()} steps (${stepsPercent}% progress), ${m.waterIntakeLiters}L water (${waterPercent}% of target). Blood pressure and body temp are within normal ranges at ${m.bloodPressure} mmHg and ${m.temperature}°C. Need details on anything specific?`,
    `Your vitals: Heart is beating at ${m.heartRate} bpm, you've walked ${m.steps.toLocaleString()} steps today, and drank ${m.waterIntakeLiters}L of water. Blood pressure ${m.bloodPressure} mmHg (normal), oxygen ${m.oxygen}% (excellent), temperature ${m.temperature}°C (normal). Which metric should we dive into?`,
  ];

  const lastResp = recentResponses[recentResponses.length - 1] || '';
  let selected = responses[Math.floor(Math.random() * responses.length)];
  if (lastResp && calculateSimilarity(selected.toLowerCase(), lastResp.toLowerCase()) > 0.6) {
    const different = responses.filter(
      (r) => calculateSimilarity(r.toLowerCase(), lastResp.toLowerCase()) < 0.6
    );
    if (different.length > 0) {
      selected = different[Math.floor(Math.random() * different.length)];
    }
  }
  return selected;
}

export function pushRecent(response, maxRecent) {
  recentResponses.push(response);
  if (recentResponses.length > maxRecent) {
    recentResponses.shift();
  }
}
