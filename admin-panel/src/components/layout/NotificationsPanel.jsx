// components/layout/NotificationsPanel.jsx
// HU10 - Panel desplegable de notificaciones administrativas

import { useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { IconBell, IconCheck, IconX, IconAlert, IconValidate } from '../ui/Icons.jsx';
import { NOTIF_LABELS } from '../../hooks/useNotifications.js';

function tiempoAtras(isoStr) {
  if (!isoStr) return '';
  const diff = Date.now() - new Date(isoStr).getTime();
  const mins = Math.floor(diff / 60000);
  const hrs  = Math.floor(diff / 3600000);
  if (mins < 1)  return 'Ahora';
  if (mins < 60) return `Hace ${mins} min`;
  if (hrs < 24)  return `Hace ${hrs}h`;
  return new Date(isoStr).toLocaleDateString('es-CO', { day: '2-digit', month: '2-digit' });
}

const TIPO_ICON = {
  nuevo_incidente:    IconBell,
  estado_cambiado:    IconValidate,
  incidente_critico:  IconAlert,
  cuadrante_asignado: IconCheck,
  personal_asignado:  IconCheck,
};

const TIPO_COLOR = {
  nuevo_incidente:    'var(--color-primary)',
  estado_cambiado:    'var(--color-navy)',
  incidente_critico:  '#BA1A1A',
  cuadrante_asignado: 'var(--color-success)',
  personal_asignado:  '#4B4ECC',
};

export default function NotificationsPanel({ notifications, noLeidas, onMarcarLeida, onMarcarTodas, onEliminar, onClose }) {
  const panelRef = useRef(null);
  const navigate = useNavigate();

  // Cerrar al hacer clic fuera
  useEffect(() => {
    function handleOutside(e) {
      if (panelRef.current && !panelRef.current.contains(e.target)) {
        onClose?.();
      }
    }
    document.addEventListener('mousedown', handleOutside);
    return () => document.removeEventListener('mousedown', handleOutside);
  }, [onClose]);

  function handleClickNotif(notif) {
    onMarcarLeida(notif.id);
    if (notif.incidentId) {
      navigate('/incidentes');
    }
    onClose?.();
  }

  return (
    <div
      ref={panelRef}
      style={{
        position: 'absolute', top: 'calc(100% + 8px)', right: 0,
        width: 340, maxHeight: 480,
        background: 'var(--bg-card)',
        border: '1px solid var(--border-medium)',
        borderRadius: 'var(--radius-lg)',
        boxShadow: '0 8px 32px rgba(0,0,0,0.18)',
        zIndex: 1000,
        display: 'flex', flexDirection: 'column',
        overflow: 'hidden',
      }}
    >
      {/* Cabecera */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '12px 16px', borderBottom: '1px solid var(--border-soft)',
        background: 'var(--bg-header)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <IconBell size={14} style={{ color: 'var(--color-navy)' }} />
          <span style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '0.875rem', color: 'var(--color-navy)' }}>
            Notificaciones
          </span>
          {noLeidas > 0 && (
            <span style={{
              background: 'var(--color-primary)', color: 'white',
              padding: '1px 7px', borderRadius: 'var(--radius-pill)',
              fontSize: '0.625rem', fontWeight: 700,
            }}>
              {noLeidas}
            </span>
          )}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          {noLeidas > 0 && (
            <button
              onClick={onMarcarTodas}
              style={{
                fontSize: '0.6875rem', fontWeight: 600, color: 'var(--color-primary)',
                background: 'none', border: 'none', cursor: 'pointer', padding: 0,
              }}
            >
              Marcar todas
            </button>
          )}
          <button
            onClick={onClose}
            style={{ background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', padding: 0 }}
          >
            <IconX size={12} style={{ color: 'var(--color-text-muted)' }} />
          </button>
        </div>
      </div>

      {/* Lista */}
      <div style={{ flex: 1, overflowY: 'auto' }}>
        {notifications.length === 0 ? (
          <div style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center',
            justifyContent: 'center', padding: '32px 16px', gap: 8,
          }}>
            <IconBell size={28} style={{ color: 'var(--color-text-muted)', opacity: 0.3 }} />
            <div style={{ fontSize: '0.8125rem', color: 'var(--color-text-muted)', textAlign: 'center' }}>
              Sin notificaciones
            </div>
            <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', textAlign: 'center' }}>
              Las alertas de nuevos reportes y cambios apareceran aqui
            </div>
          </div>
        ) : (
          notifications.map(notif => {
            const IconComp = TIPO_ICON[notif.tipo] || IconBell;
            const color    = TIPO_COLOR[notif.tipo] || 'var(--color-navy)';
            return (
              <div
                key={notif.id}
                onClick={() => handleClickNotif(notif)}
                style={{
                  display: 'flex', gap: 10, padding: '10px 16px',
                  borderBottom: '1px solid var(--border-soft)',
                  background: notif.leida ? 'transparent' : 'rgba(91,5,16,0.04)',
                  cursor: 'pointer',
                  transition: 'background 150ms',
                }}
                onMouseEnter={e => e.currentTarget.style.background = 'var(--bg-header)'}
                onMouseLeave={e => e.currentTarget.style.background = notif.leida ? 'transparent' : 'rgba(91,5,16,0.04)'}
              >
                {/* Icono */}
                <div style={{
                  width: 32, height: 32, borderRadius: '50%',
                  background: color + '18',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  flexShrink: 0, marginTop: 2,
                }}>
                  <IconComp size={14} style={{ color }} />
                </div>

                {/* Contenido */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 4 }}>
                    <div style={{
                      fontWeight: notif.leida ? 600 : 700,
                      fontSize: '0.75rem', color: 'var(--color-navy)',
                    }}>
                      {notif.titulo}
                    </div>
                    <span style={{ fontSize: '0.5625rem', color: 'var(--color-text-muted)', whiteSpace: 'nowrap', flexShrink: 0 }}>
                      {tiempoAtras(notif.createdAt)}
                    </span>
                  </div>
                  {notif.descripcion && (
                    <div style={{
                      fontSize: '0.6875rem', color: 'var(--color-text-muted)',
                      marginTop: 2,
                      overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                    }}>
                      {notif.descripcion}
                    </div>
                  )}
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4 }}>
                    <span style={{
                      fontSize: '0.5625rem', fontWeight: 700, letterSpacing: '0.04em',
                      textTransform: 'uppercase', color: color, opacity: 0.8,
                    }}>
                      {NOTIF_LABELS[notif.tipo] || notif.tipo}
                    </span>
                    {!notif.leida && (
                      <span style={{
                        width: 6, height: 6, borderRadius: '50%',
                        background: 'var(--color-primary)', flexShrink: 0,
                      }} />
                    )}
                  </div>
                </div>

                {/* Boton eliminar */}
                <button
                  onClick={e => { e.stopPropagation(); onEliminar(notif.id); }}
                  style={{
                    background: 'none', border: 'none', cursor: 'pointer',
                    display: 'flex', alignItems: 'center', padding: '2px', opacity: 0.4,
                    flexShrink: 0,
                  }}
                  title="Eliminar notificacion"
                >
                  <IconX size={10} />
                </button>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}

