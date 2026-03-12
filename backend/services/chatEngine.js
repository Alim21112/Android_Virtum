import { chat as chatConfig } from '../config.js';
import { generateResponse, pushRecent } from './responseGenerator.js';

export function processHealthQuery(message, metrics) {
  const response = generateResponse(message, metrics, chatConfig.maxRecentResponses);
  pushRecent(response, chatConfig.maxRecentResponses);
  return response;
}
