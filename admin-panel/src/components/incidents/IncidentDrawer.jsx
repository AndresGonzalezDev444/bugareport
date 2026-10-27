import { useState } from 'react';
import {
  IconClose, IconLocation, IconCamera,
  IconLink, IconSquad, IconValidate, IconX, IconAlert, IconUser, IconCheck
} from '../ui/Icons.jsx';
import { StatusBadge, SeverityBadge, CategoryBadge } from '../ui/Badge.jsx';
import { CATEGORY_LABELS, formatDateTime, timeAgo, incidentId } from '../../utils/statusHelpers.js';

// Cuadrillas disponibles por categoría (operativas — asignación manual en Fase 2 con DB)
const CUADRILLAS = {
  hueco_via:          { nombre: 'Cuadrilla 03 — Vías y Bacheo',      operarios: '3 operarios · Camión Volqueta #08',       dist: '1.2 km' },
  servicios_publicos: { nombre: 'Cuadrilla 07 — Redes y Alumbrado',  operarios: '2 operarios · Camioneta #03',             dist: '0.8 km' },
  comunitario:        { nombre: 'Cuadrilla 11 — Gestión Social',      operarios: '2 gestores · Vehículo #12',               dist: '2.1 km' },
  aseo_parques:       { nombre: 'Cuadrilla 02 — Aseo Urbano',         operarios: '4 operarios · Camión compactador #05',    dist: '0.5 km' },
};

// Roles disponibles para asignar al caso
const ROLES_DISPONIBLES = [
  'Ingeniero Civil',
  'Técnico de Campo',
  'Inspector Municipal',
  'Supervisor de Cuadrilla',
  'Operario de Maquinaria',
  'Gestor Social',
  'Coordinador de Zona',
];

// Colores de estado para la barra de progreso del ciudadano
const PROGRESS_STEPS = [
  { key: 'pendiente',  label: 'Radicado',   desc: 'Reporte recibido y en validación' },
  { key: 'en_proceso', label: 'En Gestión', desc: 'Cuadrilla asignada, trabajo en curso' },
  { key: 'resuelto',   label: 'Resuelto',   desc: 'Problema atendido y cerrado' },
];

function StatusProgressBar({ status }) {
  const idx = status === 'pendiente' ? 0 : status === 'en_proceso' ? 1 : 2;
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', gap: 0, marginBottom: 4 }}>
      {PROGRESS_STEPS.map((step, i) => (
        <div key={step.key} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', position: 'relative' }}>
          {/* Línea conectora izquierda */}
          {i > 0 && (
            <div style={{
              position: 'absolute', top: 12, right: '50%', left: '-50%', height: 2,
              background: i <= idx ? 'var(--color-success)' : 'var(--border-medium)',
              transition: 'background 400ms ease',
            }} />
          )}
          {/* Círculo */}
          <div style={{
            width: 24, height: 24, borderRadius: '50%', zIndex: 1,
            background: i < idx ? 'var(--color-success)' : i === idx ? 'var(--color-navy)' : 'var(--border-medium)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            transition: 'background 400ms ease',
            border: i === idx ? '2px solid var(--color-navy)' : 'none',
          }}>
            {i < idx
              ? <IconCheck size={11} style={{ color: 'white' }} />
              : <span style={{ fontSize: '0.5625rem', fontWeight: 700, color: 'white' }}>{i + 1}</span>
            }
          </div>
          <div style={{ fontSize: '0.5625rem', fontWeight: i === idx ? 700 : 500, marginTop: 4, textAlign: 'center',
            color: i === idx ? 'var(--color-navy)' : i < idx ? 'var(--color-success)' : 'var(--color-text-muted)' }}>
            {step.label}
          </div>
        </div>
      ))}
    </div>
  );
}

export default function IncidentDrawer({ incident, onClose, onUpdateStatus, onUpdateQuadrant }) {
  const [feedback,     setFeedback]    = useState(null);   // null | 'validating' | 'en_proceso' | 'resuelto' | 'error'
  const [imgError,     setImgError]    = useState(false);
  const [quadEdit,     setQuadEdit]    = useState(incident?.quadrant || '');
  const [savingQuad,   setSavingQuad]  = useState(false);
  const [quadFb,       setQuadFb]      = useState(null);
  const [roleInput,    setRoleInput]   = useState('');
  const [assignedRoles, setAssignedRoles] = useState(
    incident?.admin_notes
      ? incident.admin_notes.split('|').filter(Boolean)
      : []
  );

  if (!incident) return null;

  const repId     = incidentId(incident.id);
  const cuadrilla = CUADRILLAS[incident.category] || CUADRILLAS.hueco_via;
  const gpsStr    = `${incident.latitude?.toFixed(5) ?? '—'}, ${incident.longitude?.toFixed(5) ?? '—'}`;
  const mapsUrl   = `https://maps.google.com/?q=${incident.latitude},${incident.longitude}`;
  const reporter  = incident.reporter || incident.perfiles_ciudadanos || null;

  const isValidated = incident.status !== 'pendiente';
  const isResolved  = incident.status === 'resuelto';

  // ── Cambiar status ────────────────────────────────────────────
  async function handleStatus(newStatus) {
    setFeedback('updating');
    const result = await onUpdateStatus(incident.id, newStatus);
    if (result.success) {
      setFeedback(newStatus);        // muestra feedback del estado nuevo
    } else {
      setFeedback('error');
    }
    // El drawer NO se cierra — solo muestra el feedback y el incident se actualiza
    // via el selectedId pattern en Dashboard/IncidentsPage
    setTimeout(() => setFeedback(null), 4000);
  }

  // ── Guardar cuadrante ─────────────────────────────────────────
  async function handleSaveQuadrant() {
    if (!onUpdateQuadrant) return;
    setSavingQuad(true);
    const result = await onUpdateQuadrant(incident.id, quadEdit);
    setQuadFb(result.success ? 'ok' : 'error');
    setSavingQuad(false);
    setTimeout(() => setQuadFb(null), 2500);
  }

  // ── Agregar rol asignado (guardado en admin_notes temporalmente) ──
  async function handleAddRole(role) {
    if (!role || assignedRoles.includes(role)) return;
    const updated = [...assignedRoles, role];
    setAssignedRoles(updated);
    setRoleInput('');
    // Persistir en admin_notes como lista separada por |
    await onUpdateStatus && onUpdateStatus(incident.id, incident.status); // mantiene status
    // TODO Fase 2: guardar en tabla incident_assignments
  }

  function handleRemoveRole(role) {
    setAssignedRoles(prev => prev.filter(r => r !== role));
  }

  return (
    <>
      <div className="drawer-overlay" onClick={onClose} />
      <aside className="drawer">

        {/* ── Cabecera ── */}
        <div className="drawer-header">
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6, flexWrap: 'wrap' }}>
              <span style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: '0.75rem', color: 'var(--color-primary)' }}>
                {repId}
              </span>
              <CategoryBadge category={incident.category} />
              <SeverityBadge severity={incident.severity} />
              <StatusBadge   status={incident.status} />
            </div>
            <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1rem', color: 'var(--color-navy)', lineHeight: 1.3 }}>
              {incident.title}
            </div>
          </div>
          <button className="btn btn-ghost btn-icon" onClick={onClose} aria-label="Cerrar">
            <IconClose size={16} />
          </button>
        </div>

        {/* ── Cuerpo scrollable ── */}
        <div className="drawer-body">

          {/* Barra de progreso — igual a la que ve el ciudadano en la app */}
          <div className="drawer-section" style={{ paddingBottom: 8 }}>
            <div className="drawer-section-title" style={{ marginBottom: 10 }}>
              Progreso del caso — visible para el ciudadano en tiempo real
            </div>
            <StatusProgressBar status={incident.status} />
          </div>

          {/* Feedback de acción */}
          {feedback && (
            <div className="drawer-section" style={{ paddingTop: 0 }}>
              <div style={{
                display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px',
                borderRadius: 'var(--radius-md)', fontSize: '0.8125rem', fontWeight: 600,
                background: feedback === 'error'
                  ? 'rgba(186,26,26,0.12)' : feedback === 'updating'
                  ? 'rgba(91,5,16,0.08)' : 'rgba(22,163,74,0.12)',
                color: feedback === 'error'
                  ? 'var(--color-danger)' : feedback === 'updating'
                  ? 'var(--color-text-muted)' : 'var(--color-success)',
                border: `1px solid ${feedback === 'error' ? 'rgba(186,26,26,0.25)' : feedback === 'updating' ? 'var(--border-soft)' : 'rgba(22,163,74,0.25)'}`,
              }}>
                {feedback === 'updating' && <span className="loading-spinner" style={{ width: 13, height: 13, borderWidth: 2 }} />}
                {feedback === 'error'    && <IconAlert size={14} />}
                {feedback === 'en_proceso' && <IconValidate size={14} />}
                {feedback === 'resuelto'   && <IconCheck size={14} />}
                {feedback === 'pendiente'  && <IconX size={14} />}
                {feedback === 'updating'  && 'Actualizando estado...'}
                {feedback === 'en_proceso' && 'Reporte validado — el ciudadano ya ve el cambio en su app'}
                {feedback === 'resuelto'   && 'Caso marcado como resuelto — ciudadano notificado'}
                {feedback === 'pendiente'  && 'Reporte devuelto a pendiente'}
                {feedback === 'error'      && 'Error al actualizar — intenta de nuevo'}
              </div>
            </div>
          )}

          {/* 1. Fotografía real del ciudadano */}
          <div className="drawer-section" style={{ paddingTop: 8, paddingBottom: 0 }}>
            <div className="drawer-section-title">Evidencia fotográfica</div>
            <div className="photo-exif-wrapper">
              {incident.photo_url && !imgError ? (
                <img
                  src={incident.photo_url}
                  alt="Evidencia fotográfica del reporte ciudadano"
                  className="photo-main"
                  onError={() => setImgError(true)}
                />
              ) : (
                <div className="photo-no-image">
                  <IconCamera size={28} style={{ opacity: 0.3 }} />
                  <span>{incident.photo_url ? 'Error al cargar imagen' : 'Sin fotografía adjunta'}</span>
                </div>
              )}
              <div className="exif-overlay">
                <span className="exif-chip">EXIF</span>
                <span className="exif-value">{formatDateTime(incident.created_at)}</span>
                <span className="exif-value" style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: '0.5625rem' }}>
                  {gpsStr}
                </span>
              </div>
            </div>
          </div>

          {/* 2. GPS */}
          <div className="drawer-section">
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
              <IconLocation size={11} />
              <span className="drawer-section-title" style={{ margin: 0 }}>Coordenadas GPS</span>
            </div>
            <div style={{ background: 'var(--bg-header)', border: '1px solid var(--border-soft)', borderRadius: 'var(--radius-sm)', padding: '6px 10px', marginBottom: 6 }}>
              <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: '0.75rem', color: 'var(--color-navy)' }}>{gpsStr}</span>
            </div>
            {incident.address && (
              <div style={{ fontSize: '0.8125rem', color: 'var(--color-text-dark)', marginBottom: 6 }}>
                <span style={{ color: 'var(--color-text-muted)', fontSize: '0.75rem' }}>Dirección: </span>
                {incident.address}
              </div>
            )}
            <a href={mapsUrl} target="_blank" rel="noreferrer"
              style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontSize: '0.75rem', fontWeight: 600, color: 'var(--color-primary)', textDecoration: 'none' }}>
              <IconLink size={12} /> Ver en Google Maps
            </a>
          </div>

          {/* 3. Cuadrante + tiempos */}
          <div className="drawer-section">
            <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap', alignItems: 'flex-start' }}>
              <div style={{ minWidth: 140 }}>
                <div className="drawer-section-title">Cuadrante</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4 }}>
                  <select value={quadEdit} onChange={e => setQuadEdit(e.target.value)}
                    className="select-filter" style={{ fontSize: '0.8125rem', fontWeight: 700, padding: '4px 8px' }}>
                    <option value="">Sin asignar</option>
                    {Array.from({ length: 14 }, (_, i) => {
                      const q = `Q-${String(i + 1).padStart(2, '0')}`;
                      return <option key={q} value={q}>{q}</option>;
                    })}
                  </select>
                  {quadEdit !== (incident.quadrant || '') && (
                    <button className="btn btn-primary" style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                      onClick={handleSaveQuadrant} disabled={savingQuad}>
                      {savingQuad ? '...' : 'Guardar'}
                    </button>
                  )}
                </div>
                {quadFb && (
                  <div style={{ fontSize: '0.6875rem', marginTop: 3, fontWeight: 600,
                    color: quadFb === 'ok' ? 'var(--color-success)' : 'var(--color-danger)' }}>
                    {quadFb === 'ok' ? 'Cuadrante guardado' : 'Error al guardar'}
                  </div>
                )}
              </div>
              <div>
                <div className="drawer-section-title">Reportado</div>
                <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)', marginTop: 4 }}>
                  {formatDateTime(incident.created_at)}
                </div>
                <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>{timeAgo(incident.created_at)}</div>
              </div>
              <div>
                <div className="drawer-section-title">Última actualización</div>
                <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)', marginTop: 4 }}>
                  {formatDateTime(incident.updated_at)}
                </div>
              </div>
            </div>
          </div>

          {/* 4. Ciudadano reportante */}
          {reporter && (
            <div className="drawer-section" style={{ background: 'rgba(243,242,255,0.5)', borderRadius: 'var(--radius-md)', margin: '0 -12px', padding: '10px 16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 8 }}>
                <IconUser size={12} style={{ color: 'var(--color-purple)' }} />
                <span className="drawer-section-title" style={{ margin: 0, color: 'var(--color-purple)' }}>Ciudadano reportante</span>
              </div>
              <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
                {reporter.nombre_completo && <div><div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Nombre</div><div style={{ fontWeight: 600, fontSize: '0.8125rem' }}>{reporter.nombre_completo}</div></div>}
                {reporter.email          && <div><div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Email</div><div style={{ fontWeight: 600, fontSize: '0.8125rem' }}>{reporter.email}</div></div>}
                {reporter.celular        && <div><div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Celular</div><div style={{ fontWeight: 600, fontSize: '0.8125rem' }}>{reporter.celular}</div></div>}
                {reporter.comuna         && <div><div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Comuna</div><div style={{ fontWeight: 600, fontSize: '0.8125rem' }}>{reporter.comuna}</div></div>}
              </div>
            </div>
          )}

          {/* 5. Descripción del ciudadano */}
          <div className="drawer-section">
            <div className="drawer-section-title">Descripción del ciudadano</div>
            <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border-purple)', borderRadius: 'var(--radius-sm)', padding: '10px 12px', fontStyle: 'italic', fontSize: '0.875rem', lineHeight: 1.65, color: 'var(--color-text-dark)' }}>
              {incident.description || 'Sin descripción adicional.'}
            </div>
          </div>

          {/* 6. Asignación de personal — solo visible si el reporte está validado */}
          {isValidated && (
            <div className="drawer-section" style={{
              background: 'var(--color-success-pale)', border: '1px solid rgba(159, 209, 186, 0.4)',
              borderRadius: 'var(--radius-lg)', margin: '0 -12px', padding: '14px 16px',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
                <IconSquad size={14} style={{ color: 'var(--color-success)' }} />
                <span style={{ fontWeight: 700, fontSize: '0.8125rem', color: 'var(--color-success)' }}>
                  Asignación de personal al caso
                </span>
              </div>

              {/* Cuadrilla recomendada */}
              <div style={{ background: 'var(--bg-card)', border: '1px solid rgba(159,209,186,0.5)', borderRadius: 'var(--radius-md)', padding: '10px 12px', marginBottom: 12, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 8 }}>
                <div>
                  <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-navy)' }}>{cuadrilla.nombre}</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', marginTop: 2 }}>{cuadrilla.operarios}</div>
                </div>
                <span style={{ background: 'var(--color-success-lighter)', color: 'var(--color-success)', padding: '3px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600 }}>
                  Disponible · {cuadrilla.dist}
                </span>
              </div>

              {/* Roles asignados */}
              <div style={{ marginBottom: 10 }}>
                <div className="drawer-section-title" style={{ marginBottom: 8 }}>Roles / especialistas asignados</div>
                {assignedRoles.length === 0 ? (
                  <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', fontStyle: 'italic' }}>
                    Sin personal asignado aún — añade roles abajo
                  </div>
                ) : (
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                    {assignedRoles.map(role => (
                      <span key={role} style={{
                        display: 'inline-flex', alignItems: 'center', gap: 5,
                        background: 'rgba(91,5,16,0.08)', border: '1px solid rgba(91,5,16,0.2)',
                        borderRadius: 'var(--radius-pill)', padding: '3px 10px', fontSize: '0.6875rem', fontWeight: 600, color: 'var(--color-navy)',
                      }}>
                        {role}
                        <button onClick={() => handleRemoveRole(role)}
                          style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, display: 'flex', alignItems: 'center', opacity: 0.5 }}>
                          <IconX size={9} />
                        </button>
                      </span>
                    ))}
                  </div>
                )}
              </div>

              {/* Selector para añadir rol */}
              <div style={{ display: 'flex', gap: 8 }}>
                <select
                  value={roleInput}
                  onChange={e => setRoleInput(e.target.value)}
                  className="select-filter"
                  style={{ flex: 1, fontSize: '0.8125rem' }}
                >
                  <option value="">Seleccionar rol / especialista...</option>
                  {ROLES_DISPONIBLES.filter(r => !assignedRoles.includes(r)).map(r => (
                    <option key={r} value={r}>{r}</option>
                  ))}
                </select>
                <button
                  className="btn btn-outline"
                  style={{ whiteSpace: 'nowrap', fontSize: '0.75rem', padding: '6px 12px' }}
                  onClick={() => handleAddRole(roleInput)}
                  disabled={!roleInput}
                >
                  + Asignar
                </button>
              </div>
            </div>
          )}

          {/* 7. Cuadrilla recomendada (si aún pendiente) */}
          {!isValidated && (
            <div className="drawer-section" style={{ background: 'var(--color-success-pale)', border: '1px solid rgba(159,209,186,0.4)', borderRadius: 'var(--radius-lg)', margin: '0 -12px', padding: '12px 16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
                <IconSquad size={14} style={{ color: 'var(--color-success)' }} />
                <span style={{ fontWeight: 700, fontSize: '0.8125rem', color: 'var(--color-success)' }}>Cuadrilla recomendada</span>
                <span style={{ fontSize: '0.6rem', color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em' }}>(disponible al validar)</span>
              </div>
              <div style={{ background: 'var(--bg-card)', border: '1px solid rgba(159,209,186,0.5)', borderRadius: 'var(--radius-md)', padding: '10px 12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 8 }}>
                <div>
                  <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-navy)' }}>{cuadrilla.nombre}</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', marginTop: 2 }}>{cuadrilla.operarios}</div>
                </div>
                <span style={{ background: 'var(--color-success-lighter)', color: 'var(--color-success)', padding: '3px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600 }}>
                  Disponible · {cuadrilla.dist}
                </span>
              </div>
            </div>
          )}
        </div>

        {/* ── Footer — acciones de estado ── */}
        <div className="drawer-footer">
          <div className="drawer-actions-primary">
            {/* Validar — solo si está pendiente */}
            {!isValidated && (
              <button
                className="btn btn-blue btn-lg"
                onClick={() => handleStatus('en_proceso')}
                disabled={feedback === 'updating'}
              >
                <IconValidate size={13} />
                Validar reporte
              </button>
            )}
            {/* Marcar resuelto — si ya está en proceso */}
            {isValidated && !isResolved && (
              <button
                className="btn btn-success btn-lg"
                onClick={() => handleStatus('resuelto')}
                disabled={feedback === 'updating'}
              >
                <IconCheck size={13} />
                Marcar como resuelto
              </button>
            )}
            {/* Resuelto — badge informativo */}
            {isResolved && (
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '10px 16px', background: 'var(--color-success-lighter)', borderRadius: 'var(--radius-md)', color: 'var(--color-success)', fontWeight: 700, fontSize: '0.8125rem' }}>
                <IconCheck size={14} />
                Caso cerrado y resuelto
              </div>
            )}
          </div>
          <div className="drawer-actions-secondary">
            {/* Devolver a pendiente — si está validado */}
            {isValidated && (
              <button className="btn btn-danger"
                onClick={() => handleStatus('pendiente')}
                disabled={feedback === 'updating'}>
                <IconX size={11} />
                Devolver a pendiente
              </button>
            )}
          </div>
        </div>
      </aside>
    </>
  );
}
