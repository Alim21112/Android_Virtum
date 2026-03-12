import { Router } from 'express';
import { normalize } from '../utils/normalize.js';
import * as users from '../store/users.js';

const router = Router();

router.post('/register', (req, res) => {
  console.log('[REGISTER] New registration attempt:', {
    name: req.body.name,
    email: req.body.email,
    hasPassword: !!req.body.password,
  });

  const name = String(req.body.name ?? '').trim();
  const email = String(req.body.email ?? '').trim().toLowerCase();
  const password = String(req.body.password ?? '').trim();

  if (!name || !email || !password) {
    console.log('[REGISTER] ❌ Missing fields');
    return res.status(400).json({ error: 'Missing fields' });
  }

  const exists = users.findByEmail(email, normalize);
  if (exists) {
    console.log('[REGISTER] ❌ Email already exists:', email);
    return res.status(409).json({ error: 'Email already registered' });
  }

  const user = {
    id: users.nextId(),
    name,
    email,
    password,
  };
  users.add(user);
  console.log('[REGISTER] ✅ User created successfully:', email);
  return res.json({ user: users.toUser(user) });
});

router.post('/login', (req, res) => {
  const identifier = normalize(req.body.email);
  const password = String(req.body.password ?? '');

  if (!identifier || !password) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  const user = users.findByIdentifierAndPassword(identifier, password, normalize);
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  return res.json({ token: 'demo-token', user: users.toUser(user) });
});

export default router;
