/**
 * Shared validation helpers for API routes
 */
const USER_ID_REGEX = /^[a-zA-Z0-9_]{1,128}$/;
const UUID_REGEX =
  /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/i;
const MAX_CHAT_MESSAGE = 8000;

function isValidUserId(userId) {
  if (typeof userId !== 'string') return false;
  const t = userId.trim();
  return USER_ID_REGEX.test(t) || UUID_REGEX.test(t);
}

function sanitizeUserId(userId, fallback = 'testUser') {
  if (typeof userId !== 'string') return fallback;
  const t = userId.trim();
  return isValidUserId(t) ? t : fallback;
}

module.exports = {
  USER_ID_REGEX,
  UUID_REGEX,
  MAX_CHAT_MESSAGE,
  isValidUserId,
  sanitizeUserId
};
