import sha256 from 'js-sha256';

const ADMIN_USER_HASH = import.meta.env.VITE_ADMIN_USER_HASH || '';
const ADMIN_PASS_HASH = import.meta.env.VITE_ADMIN_PASS_HASH || '';


export function validateCredentials(username, password) {
  const userHash = sha256(username.trim());
  const passHash = sha256(password);
  return userHash === ADMIN_USER_HASH && passHash === ADMIN_PASS_HASH;
}

const SESSION_KEY = 'bugareport_admin_session';

export function saveSession() {
  const expiry = Date.now() + 8 * 60 * 60 * 1000; // 8 horas
  sessionStorage.setItem(SESSION_KEY, JSON.stringify({ valid: true, expiry }));
}

export function getSession() {
  try {
    const raw = sessionStorage.getItem(SESSION_KEY);
    if (!raw) return null;
    const session = JSON.parse(raw);
    if (Date.now() > session.expiry) {
      sessionStorage.removeItem(SESSION_KEY);
      return null;
    }
    return session;
  } catch {
    return null;
  }
}

export function clearSession() {
  sessionStorage.removeItem(SESSION_KEY);
}
