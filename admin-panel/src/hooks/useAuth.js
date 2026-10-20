import { useState, useEffect } from 'react';
import { getSession, saveSession, clearSession, validateCredentials } from '../config/auth.js';

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading]                 = useState(true);

  useEffect(() => {
    const session = getSession();
    setIsAuthenticated(Boolean(session));
    setLoading(false);
  }, []);

  function login(username, password) {
    const valid = validateCredentials(username, password);
    if (valid) {
      saveSession();
      setIsAuthenticated(true);
      return { success: true };
    }
    return { success: false, error: 'Credenciales incorrectas. Acceso denegado.' };
  }

  function logout() {
    clearSession();
    setIsAuthenticated(false);
  }

  return { isAuthenticated, loading, login, logout };
}
