import { useState } from 'react';
import { IconUser, IconLock, IconEye, IconEyeOff, IconAlert, IconValidate } from '../components/ui/Icons.jsx';
import { useAuth } from '../hooks/useAuth.jsx';

export default function Login() {
  const { login } = useAuth();        // ← usa el contexto global
  const [username,  setUsername]  = useState('');
  const [password,  setPassword]  = useState('');
  const [showPass,  setShowPass]  = useState(false);
  const [loading,   setLoading]   = useState(false);
  const [error,     setError]     = useState('');
  const [success,   setSuccess]   = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!username.trim() || !password) return;
    setLoading(true);
    setError('');

    // Delay mínimo anti-timing-attack
    await new Promise(r => setTimeout(r, 350));

    const result = login(username, password);

    if (result.success) {
      setSuccess(true);
      // La redirección ocurre automáticamente porque App.jsx
      // reacciona al cambio de isAuthenticated en el contexto compartido.
      // El mensaje de éxito se verá ~400ms antes de que el router redirija.
    } else {
      setError(result.error);
      setLoading(false);
    }
  }

  return (
    <div className="login-page">
      <div className="login-bg-pattern" />

      <div className="login-card">
        {/* Logo y título */}
        <div className="login-logo-wrap">
          <img
            src="/assets/images/logo-buga-report.png"
            alt="BugaReport"
            className="login-logo"
            onError={e => { e.target.style.display = 'none'; }}
          />
          <div>
            <div className="login-title">BugaReport</div>
            <div className="login-subtitle">Panel Administrativo</div>
          </div>
        </div>

        {/* Mensaje de éxito */}
        {success && (
          <div className="login-success">
            <IconValidate size={15} />
            Acceso verificado — entrando al panel...
          </div>
        )}

        {/* Formulario */}
        {!success && (
          <form className="login-form" onSubmit={handleSubmit} autoComplete="off">
            <div className="form-group">
              <label className="form-label" htmlFor="login-user">Usuario</label>
              <div className={`form-input-wrap${error ? ' error' : ''}`}>
                <IconUser size={14} />
                <input
                  id="login-user"
                  type="text"
                  value={username}
                  onChange={e => { setUsername(e.target.value); setError(''); }}
                  placeholder="Ingresa tu usuario"
                  autoComplete="off"
                  spellCheck={false}
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label" htmlFor="login-pass">Contraseña</label>
              <div className={`form-input-wrap${error ? ' error' : ''}`}>
                <IconLock size={14} />
                <input
                  id="login-pass"
                  type={showPass ? 'text' : 'password'}
                  value={password}
                  onChange={e => { setPassword(e.target.value); setError(''); }}
                  placeholder="Ingresa tu contraseña"
                  autoComplete="new-password"
                  required
                />
                <button
                  type="button"
                  className="toggle-pass"
                  onClick={() => setShowPass(s => !s)}
                  tabIndex={-1}
                  aria-label={showPass ? 'Ocultar contraseña' : 'Mostrar contraseña'}
                >
                  {showPass ? <IconEyeOff size={14} /> : <IconEye size={14} />}
                </button>
              </div>
            </div>

            {error && (
              <div className="login-error">
                <IconAlert size={13} />
                {error}
              </div>
            )}

            <button
              type="submit"
              className="login-btn"
              disabled={loading || !username.trim() || !password}
            >
              {loading ? (
                <span style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
                  <span className="loading-spinner" style={{ borderColor: 'rgba(255,255,255,0.3)', borderTopColor: 'white', width: 14, height: 14 }} />
                  Verificando...
                </span>
              ) : (
                'Ingresar al Panel'
              )}
            </button>
          </form>
        )}

        <div className="login-footer">
          ACCESO RESTRINGIDO — PERSONAL AUTORIZADO ÚNICAMENTE<br />
          Alcaldía Municipal de Guadalajara de Buga · {new Date().getFullYear()}
        </div>
      </div>
    </div>
  );
}
