import { useState, useEffect, useContext, createContext, useCallback } from 'react';
import { getSession, saveSession, clearSession, validateCredentials } from '../config/auth.js';

// Contexto compartido — una sola fuente de verdad para toda la app
const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading]                 = useState(true);

  useEffect(() => {
    const session = getSession();
    setIsAuthenticated(Boolean(session));
    setLoading(false);
  }, []);

  const login = useCallback((username, password) => {
    const valid = validateCredentials(username, password);
    if (valid) {
      saveSession();
      setIsAuthenticated(true);      // ← actualiza el estado global compartido
      return { success: true };
    }
    return { success: false, error: 'Credenciales incorrectas. Acceso denegado.' };
  }, []);

  const logout = useCallback(() => {
    clearSession();
    setIsAuthenticated(false);
  }, []);

  return (
    <AuthContext.Provider value={{ isAuthenticated, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// Hook para consumir el contexto
export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth debe usarse dentro de <AuthProvider>');
  return ctx;
}
