/**
 * Strip dangerous MongoDB operators from object keys
 * Prevents NoSQL injection via $gt, $ne, $regex, etc.
 */
const stripMongoOperators = (obj) => {
  if (typeof obj !== "object" || obj === null) return obj;

  if (Array.isArray(obj)) {
    return obj.map(stripMongoOperators);
  }

  const sanitized = {};
  for (const [key, value] of Object.entries(obj)) {
    // Skip keys starting with $ or containing dots (MongoDB operator/path traversal)
    if (key.startsWith("$") || key.includes(".")) continue;
    sanitized[key] = stripMongoOperators(value);
  }
  return sanitized;
};

/**
 * Sanitize string values by stripping HTML tags
 */
const sanitizeStrings = (obj) => {
  if (typeof obj === "string") {
    return obj.replace(/<[^>]*>/g, "");
  }
  if (Array.isArray(obj)) {
    return obj.map(sanitizeStrings);
  }
  if (obj && typeof obj === "object") {
    const sanitized = {};
    for (const [key, value] of Object.entries(obj)) {
      sanitized[key] = sanitizeStrings(value);
    }
    return sanitized;
  }
  return obj;
};

const sanitizeInput = (req, res, next) => {
  if (req.body && typeof req.body === "object") {
    req.body = sanitizeStrings(stripMongoOperators(req.body));
  }

  // req.query and req.params are read-only in Express 5
  // Store sanitized versions on custom properties
  if (req.query && typeof req.query === "object") {
    req.sanitizedQuery = sanitizeStrings(stripMongoOperators(req.query));
  }
  if (req.params && typeof req.params === "object") {
    req.sanitizedParams = sanitizeStrings(stripMongoOperators(req.params));
  }

  next();
};

export default sanitizeInput;
