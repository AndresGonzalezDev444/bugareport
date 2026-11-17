import { useState, useEffect } from 'react';
import { IconUser, IconLock, IconEye, IconEyeOff, IconAlert, IconValidate } from '../components/ui/Icons.jsx';
import { useAuth } from '../hooks/useAuth.jsx';

function IconSun({ size = 18 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="5"/>
      <line x1="12" y1="1" x2="12" y2="3"/>
      <line x1="12" y1="21" x2="12" y2="23"/>
      <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
      <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
      <line x1="1" y1="12" x2="3" y2="12"/>
      <line x1="21" y1="12" x2="23" y2="12"/>
      <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
      <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
    </svg>
  );
}

function IconMoon({ size = 18 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
    </svg>
  );
}

export default function Login() {
  const { login } = useAuth();
  const [username,  setUsername]  = useState('');
  const [password,  setPassword]  = useState('');
  const [showPass,  setShowPass]  = useState(false);
  const [loading,   setLoading]   = useState(false);
  const [error,     setError]     = useState('');
  const [success,   setSuccess]   = useState(false);
  const [darkMode,  setDarkMode]  = useState(false);

  // Aplica/quita clase al elemento raíz del login
  useEffect(() => {
    document.documentElement.setAttribute('data-login-theme', darkMode ? 'dark' : 'light');
    return () => document.documentElement.removeAttribute('data-login-theme');
  }, [darkMode]);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!username.trim() || !password) return;
    setLoading(true);
    setError('');

    await new Promise(r => setTimeout(r, 350));

    const result = login(username, password);

    if (result.success) {
      setSuccess(true);
    } else {
      setError(result.error);
      setLoading(false);
    }
  }

  return (
    <div className={`login-page-v2${darkMode ? ' dark' : ''}`}>

      {/* ── Columna izquierda: imagen + branding ── */}
      <div className="login-left">
        <img
          src="/assets/images/buga-fond.jpg"
          alt="Guadalajara de Buga"
          className="login-bg-img"
        />
        <div className="login-left-overlay" />
        <div className="login-brand-block">
          <img
            src="/assets/images/logo-buga-report.png"
            alt="BugaReport"
            className="login-brand-logo"
            onError={e => { e.target.style.display = 'none'; }}
          />

          {/* Texto descriptivo */}
          <div className="login-brand-desc-block">
            <p className="login-brand-desc-main">
              Plataforma Digital de Reporte Ciudadano<br />Georreferenciado para Cuadrantes de Buga
            </p>
            <p className="login-brand-desc-sub">
              Ciudadanos que reportan · Una ciudad que avanza
            </p>
          </div>

          {/* Sponsor / Alcaldía */}
          <div className="login-sponsor">
            <span className="login-sponsor-label">Una plataforma para</span>
            <div className="login-sponsor-logo-wrap">
              <img
                src="/assets/images/logo-alcaldia-buga.png"
                alt="Alcaldía de Guadalajara de Buga"
                className="login-sponsor-logo"
                onError={e => { e.target.style.display = 'none'; }}
              />
              <span className="login-sponsor-name">Alcaldía de<br />Guadalajara de Buga</span>
            </div>
          </div>
        </div>
      </div>

      {/* ── Columna derecha: formulario ── */}
      <div className="login-right">

        {/* Toggle tema */}
        <div className="login-theme-toggle">
          <button
            className={`theme-toggle-btn${!darkMode ? ' active' : ''}`}
            onClick={() => setDarkMode(false)}
            aria-label="Modo claro"
            title="Modo claro"
          >
            <IconSun size={16} />
          </button>
          <button
            className={`theme-toggle-btn${darkMode ? ' active' : ''}`}
            onClick={() => setDarkMode(true)}
            aria-label="Modo oscuro"
            title="Modo oscuro"
          >
            <IconMoon size={16} />
          </button>
        </div>

        <div className="login-form-wrapper">
          {/* Encabezado */}
          <div className="login-heading">
            <h1 className="login-hello">¡Hola!<br />Bienvenido</h1>
            <p className="login-panel-label">PANEL ADMINISTRATIVO</p>
          </div>

          {/* Mensaje de éxito */}
          {success && (
            <div className="login-success-v2">
              <IconValidate size={16} />
              Acceso verificado — entrando al panel...
            </div>
          )}

          {/* Formulario */}
          {!success && (
            <form className="login-form-v2" onSubmit={handleSubmit} autoComplete="off">

              <div className={`login-input-wrap${error ? ' error' : ''}`}>
                <span className="login-input-icon"><IconUser size={18} /></span>
                <input
                  id="login-user"
                  type="text"
                  value={username}
                  onChange={e => { setUsername(e.target.value); setError(''); }}
                  placeholder="Usuario o Correo"
                  autoComplete="off"
                  spellCheck={false}
                  required
                />
              </div>

              <div className={`login-input-wrap${error ? ' error' : ''}`}>
                <span className="login-input-icon"><IconLock size={18} /></span>
                <input
                  id="login-pass"
                  type={showPass ? 'text' : 'password'}
                  value={password}
                  onChange={e => { setPassword(e.target.value); setError(''); }}
                  placeholder="Contraseña"
                  autoComplete="new-password"
                  required
                />
                <button
                  type="button"
                  className="login-toggle-pass"
                  onClick={() => setShowPass(s => !s)}
                  tabIndex={-1}
                  aria-label={showPass ? 'Ocultar contraseña' : 'Mostrar contraseña'}
                >
                  {showPass ? <IconEyeOff size={18} /> : <IconEye size={18} />}
                </button>
              </div>

              {error && (
                <div className="login-error-v2">
                  <IconAlert size={14} />
                  {error}
                </div>
              )}

              <button
                type="submit"
                className="login-submit-btn"
                disabled={loading || !username.trim() || !password}
              >
                {loading ? (
                  <span style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
                    <span className="loading-spinner" style={{ borderColor: 'rgba(255,255,255,0.35)', borderTopColor: 'white', width: 16, height: 16 }} />
                    Verificando...
                  </span>
                ) : (
                  <>Ingresar al Panel &nbsp;↗</>
                )}
              </button>

            </form>
          )}

          <p className="login-footer-v2">
            Acceso restringido a personal autorizado
          </p>
        </div>
      </div>
    </div>
  );
}
