import { useState } from 'react';
import { IconSettings, IconValidate, IconAlert, IconRefresh } from '../components/ui/Icons.jsx';
import { isSupabaseConfigured } from '../config/supabase.js';

export default function ConfigPage({ isDemo }) {
  const [supabaseUrl,  setSupabaseUrl]  = useState('');
  const [supabaseKey,  setSupabaseKey]  = useState('');
  const [testStatus,   setTestStatus]   = useState(null); // null | 'testing' | 'ok' | 'error'
  const [testMsg,      setTestMsg]      = useState('');

  async function testConnection() {
    if (!supabaseUrl || !supabaseKey) {
      setTestStatus('error');
      setTestMsg('Ingresa la URL y la Anon Key antes de probar.');
      return;
    }
    setTestStatus('testing');
    setTestMsg('Probando conexión...');
    try {
      const { createClient } = await import('@supabase/supabase-js');
      const client = createClient(supabaseUrl.trim(), supabaseKey.trim());
      const { error } = await client.from('incidents').select('id').limit(1);
      if (error) throw error;
      setTestStatus('ok');
      setTestMsg('Conexión exitosa. Actualiza el archivo .env y reinicia el servidor para activar.');
    } catch (err) {
      setTestStatus('error');
      setTestMsg(`Error: ${err.message}`);
    }
  }

  return (
    <>
      <div className="page-sub-header">
        <div className="page-heading">
          <h1>Configuración del Panel</h1>
          <div className="page-heading-sub">Conexión con Supabase y ajustes del sistema</div>
        </div>
      </div>

      <div className="page-content">
        {/* Estado de conexión actual */}
        <div className="card" style={{ padding: 24 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20 }}>
            <div style={{
              width: 40, height: 40, borderRadius: 10,
              background: isDemo ? 'var(--color-warning-light)' : 'var(--color-success-light)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <IconSettings size={18} style={{ color: isDemo ? 'var(--color-warning)' : 'var(--color-success)' }} />
            </div>
            <div>
              <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1rem', color: 'var(--color-navy)' }}>
                Estado de la conexión
              </div>
              <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', marginTop: 2 }}>
                {isDemo
                  ? 'Modo demo activo — mostrando datos de ejemplo'
                  : 'Conectado a Supabase — datos reales en tiempo real'}
              </div>
            </div>
            <div style={{ marginLeft: 'auto' }}>
              <span style={{
                padding: '4px 12px', borderRadius: 'var(--radius-pill)', fontSize: '0.75rem', fontWeight: 700,
                background: isDemo ? 'var(--color-warning-light)' : 'var(--color-success-light)',
                color:      isDemo ? 'var(--color-warning)'       : 'var(--color-success)',
              }}>
                {isDemo ? 'Sin conexión' : 'Activo'}
              </span>
            </div>
          </div>

          {isDemo && (
            <div style={{
              background: 'var(--color-warning-light)', border: '1px solid rgba(134, 82, 27, 0.25)',
              borderRadius: 'var(--radius-md)', padding: '12px 16px', marginBottom: 24,
              fontSize: '0.8125rem', color: 'var(--color-warning)',
            }}>
              <strong>Para activar la conexión real:</strong> edita el archivo <code style={{ background: 'rgba(134,82,27,0.1)', padding: '1px 6px', borderRadius: 4 }}>.env</code> en la raíz del proyecto y agrega tu Supabase URL y Anon Key, luego reinicia el servidor con <code style={{ background: 'rgba(134,82,27,0.1)', padding: '1px 6px', borderRadius: 4 }}>npm run dev</code>.
            </div>
          )}

          {/* Instrucciones paso a paso */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '0.875rem', color: 'var(--color-navy)', marginBottom: 4 }}>
              Pasos para conectar con Supabase
            </div>

            {[
              {
                n: '01',
                title: 'Obtén tus credenciales de Supabase',
                body: 'Abre tu proyecto en supabase.com → Settings → API. Copia la "Project URL" y la "anon / public" key.',
              },
              {
                n: '02',
                title: 'Ejecuta el script SQL de políticas',
                body: 'Abre el archivo supabase_admin_setup.sql en la raíz del proyecto, cópialo en Supabase Dashboard → SQL Editor y ejecútalo. Habilita también el Realtime para la tabla incidents.',
              },
              {
                n: '03',
                title: 'Edita el archivo .env',
                body: 'En la carpeta admin-panel, abre el archivo .env y llena VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY con los valores del paso 01.',
              },
              {
                n: '04',
                title: 'Reinicia el servidor de desarrollo',
                body: 'Detén el servidor actual y ejecuta npm run dev. El panel se conectará automáticamente a Supabase y el badge "Modo Demo" desaparecerá.',
              },
            ].map(step => (
              <div key={step.n} style={{ display: 'flex', gap: 16, alignItems: 'flex-start' }}>
                <div style={{
                  width: 32, height: 32, borderRadius: '50%', background: 'var(--color-navy)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                  fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: '0.6875rem', color: 'white',
                }}>
                  {step.n}
                </div>
                <div style={{ flex: 1, paddingTop: 4 }}>
                  <div style={{ fontWeight: 700, fontSize: '0.8125rem', color: 'var(--color-text-dark)', marginBottom: 4 }}>{step.title}</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', lineHeight: 1.6 }}>{step.body}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Verificador de conexión */}
        <div className="card" style={{ padding: 24 }}>
          <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '0.9375rem', color: 'var(--color-navy)', marginBottom: 4 }}>
            Verificar conexión manualmente
          </div>
          <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', marginBottom: 20 }}>
            Ingresa tus credenciales para probar la conexión antes de editar el .env
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-main)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                Supabase Project URL
              </label>
              <input
                type="url"
                value={supabaseUrl}
                onChange={e => setSupabaseUrl(e.target.value)}
                placeholder="https://XXXXXXXXXXXXXXXX.supabase.co"
                style={{
                  width: '100%', padding: '9px 12px', borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-medium)', background: 'var(--bg-header)',
                  fontSize: '0.875rem', fontFamily: 'JetBrains Mono, monospace', color: 'var(--color-text-dark)',
                  outline: 'none',
                }}
              />
            </div>
            <div>
              <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-main)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                Anon / Public Key
              </label>
              <input
                type="text"
                value={supabaseKey}
                onChange={e => setSupabaseKey(e.target.value)}
                placeholder="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                style={{
                  width: '100%', padding: '9px 12px', borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-medium)', background: 'var(--bg-header)',
                  fontSize: '0.75rem', fontFamily: 'JetBrains Mono, monospace', color: 'var(--color-text-dark)',
                  outline: 'none',
                }}
              />
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <button
                className="btn btn-primary"
                onClick={testConnection}
                disabled={testStatus === 'testing' || !supabaseUrl || !supabaseKey}
              >
                {testStatus === 'testing'
                  ? <><span className="loading-spinner" style={{ width: 12, height: 12, borderWidth: 2 }} /> Probando...</>
                  : <><IconRefresh size={13} /> Probar conexión</>
                }
              </button>

              {testStatus && testStatus !== 'testing' && (
                <div style={{
                  display: 'flex', alignItems: 'center', gap: 7,
                  color: testStatus === 'ok' ? 'var(--color-success)' : 'var(--color-danger)',
                  fontSize: '0.8125rem', fontWeight: 600,
                }}>
                  {testStatus === 'ok'
                    ? <IconValidate size={14} />
                    : <IconAlert size={14} />
                  }
                  {testMsg}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Información del .env actual */}
        <div className="card" style={{ padding: 24 }}>
          <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '0.9375rem', color: 'var(--color-navy)', marginBottom: 16 }}>
            Estado del archivo .env
          </div>
          <div style={{ background: 'var(--color-navy)', borderRadius: 'var(--radius-md)', padding: '16px 20px' }}>
            <pre style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: '0.75rem', color: 'rgba(255,255,255,0.85)', margin: 0, lineHeight: 1.7 }}>
{`# admin-panel/.env
VITE_ADMIN_USER_HASH=••••••••••••••••••• (configurado)
VITE_ADMIN_PASS_HASH=••••••••••••••••••• (configurado)

VITE_SUPABASE_URL=${isDemo ? '[vacío — pendiente]' : '[configurado]'}
VITE_SUPABASE_ANON_KEY=${isDemo ? '[vacío — pendiente]' : '[configurado]'}`}
            </pre>
          </div>
          <div style={{ marginTop: 12, fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>
            El archivo .env está en .gitignore — nunca se sube al repositorio.
          </div>
        </div>
      </div>
    </>
  );
}
