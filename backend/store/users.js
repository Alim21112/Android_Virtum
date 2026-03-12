const users = [];

export function getAll() {
  return users;
}

export function add(user) {
  users.push(user);
  return user;
}

export function findByEmail(email, normalizeFn) {
  return users.find((u) => normalizeFn(u.email) === email);
}

export function findByIdentifierAndPassword(identifier, password, normalizeFn) {
  return users.find(
    (entry) =>
      (normalizeFn(entry.email) === identifier || normalizeFn(entry.name) === identifier) &&
      entry.password === password
  );
}

export function nextId() {
  return `user-${getAll().length + 1}`;
}

export function toUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
  };
}
