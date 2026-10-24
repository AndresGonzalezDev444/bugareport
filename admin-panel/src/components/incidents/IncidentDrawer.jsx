import { useState } from 'react';
import {
  IconClose, IconLocation, IconCamera,
  IconLink, IconSquad, IconValidate, IconX, IconAlert, IconUser
} from '../ui/Icons.jsx';
import { StatusBadge, SeverityBadge, CategoryBadge } from '../ui/Badge.jsx';
import { CATEGORY_LABELS, formatDateTime, timeAgo, incidentId } from '../../utils/statusHelpers.js';

// Cuadrillas sugeridas por categoría — referencia operativa (no vienen de DB aún)
const CUADRILLAS = {
  hueco_via:          { nombre: 'Cuadrilla 03 — Vías y Bacheo',        operarios: '3 operarios · Camión Volqueta #08', dist: '1.2 km' },
  servicios_publicos: { nombre: 'Cuadrilla 07 — Redes y Alumbrado',    operarios: '2 operarios · Camioneta #03',      dist: '0.8 km' },
  comunitario:        { nombre: 'Cuadrilla 11 — Gestión Social',        operarios: '2 gestores · Vehículo #12',        dist: '2.1 km' },
  aseo_parques:       { nombre: 'Cuadrilla 02 — Aseo Urbano',           operarios: '4 operarios · Camión compactador #05', dist: '0.5 km' },
};

export default function IncidentDrawer({ incident, onClose, onUpdateStatus, onUpdateQuadrant }) {
  const [updating,      setUpdating]      = useState(false);
  const [feedback,      setFeedback]      = useState(null);
  const [imgError,      setImgError]      = useState(false);
  const [quadrantEdit,  setQuadrantEdit]  = useState(incident.quadrant || '');
  const [savingQuad,    setSavingQuad]    = useState(false);
  const [quadFeedback,  setQuadFeedback]  = useState(null);

  if (!incident) return null;

  const repId     = incidentId(incident.id);
  const cuadrilla = CUADRILLAS[incident.category] || CUADRILLAS.hueco_via;
  const gpsStr    = `Lat: ${incident.latitude?.toFixed(5) ?? '—'}, Lon: ${incident.longitude?.toFixed(5) ?? '—'}`;
  const mapsUrl   = `https://maps.google.com/?q=${incident.latitude},${incident.longitude}`;

  // Datos del reportante (join con perfiles_ciudadanos)
  const reporter = incident.reporter || incident.perfiles_ciudadanos || null;

  async function handleStatus(newStatus) {
    setUpdating(true);
    setFeedback(null);
    const result = await onUpdateStatus(incident.id, newStatus);
    setFeedback(result.success ? 'success' : 'error');
    setUpdating(false);
    setTimeout(() => setFeedback(null), 3000);
  }

  async function handleSaveQuadrant() {
    if (!onUpdateQuadrant) return;
    setSavingQuad(true);
    setQuadFeedback(null);
    const result = await onUpdateQuadrant(incident.id, quadrantEdit);
    setQuadFeedback(result.success ? 'ok' : 'error');
    setSavingQuad(false);
    setTimeout(() => setQuadFeedback(null), 2500);
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

          {/* 1. Fotografía real del ciudadano + overlay EXIF */}
          <div className="drawer-section" style={{ paddingTop: 12, paddingBottom: 0 }}>
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
                  {incident.latitude?.toFixed(5) ?? '—'}, {incident.longitude?.toFixed(5) ?? '—'}
                </span>
              </div>
            </div>
            <div style={{ background: 'var(--color-purple-light)', borderRadius: 'var(--radius-sm)', padding: '6px 10px', marginTop: 8, display: 'flex', gap: 16, flexWrap: 'wrap' }}>
              <span style={{ fontSize: '0.6875rem', color: 'var(--color-text-main)' }}>
                <strong>Precisión GPS:</strong> {incident.latitude ? '~8 metros (GPS App)' : 'No disponible'}
              </span>
              <span style={{ fontSize: '0.6875rem', color: 'var(--color-text-main)' }}>
                <strong>Fuente:</strong> GPS App + EXIF validado (&lt;40 días)
              </span>
            </div>
          </div>

          {/* 2. Geolocalización */}
          <div className="drawer-section">
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
              <IconLocation size={11} />
              <span className="drawer-section-title" style={{ margin: 0 }}>Coordenadas GPS</span>
            </div>
            <div style={{ background: 'var(--bg-header)', border: '1px solid var(--border-soft)', borderRadius: 'var(--radius-sm)', padding: '6px 10px', marginBottom: 8 }}>
              <span className="mono" style={{ color: 'var(--color-navy)' }}>{gpsStr}</span>
            </div>
            {incident.address && (
              <div style={{ marginBottom: 8 }}>
                <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>Dirección: </span>
                <span style={{ fontSize: '0.8125rem', fontWeight: 600, color: 'var(--color-text-dark)' }}>
                  {incident.address}
                </span>
              </div>
            )}
            <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
              <a href={mapsUrl} target="_blank" rel="noreferrer"
                style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.75rem', fontWeight: 600, color: 'var(--color-primary)', textDecoration: 'none' }}>
                <IconLink size={12} /> Ver en Google Maps
              </a>
            </div>
          </div>

          {/* 3. Cuadrante y tiempo */}
          <div className="drawer-section">
            <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap' }}>
              <div style={{ minWidth: 140 }}>
                <div className="drawer-section-title">Cuadrante</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4 }}>
                  <select
                    value={quadrantEdit}
                    onChange={e => setQuadrantEdit(e.target.value)}
                    className="select-filter"
                    style={{ fontSize: '0.8125rem', fontWeight: 700, minWidth: 80, padding: '4px 8px' }}
                  >
                    <option value="">Sin asignar</option>
                    {Array.from({ length: 14 }, (_, i) => {
                      const q = `Q-${String(i + 1).padStart(2, '0')}`;
                      return <option key={q} value={q}>{q}</option>;
                    })}
                  </select>
                  {quadrantEdit !== (incident.quadrant || '') && (
                    <button
                      className="btn btn-primary"
                      style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                      onClick={handleSaveQuadrant}
                      disabled={savingQuad}
                    >
                      {savingQuad ? 'Guardando...' : 'Guardar'}
                    </button>
                  )}
                </div>
                {quadFeedback && (
                  <div style={{ fontSize: '0.6875rem', marginTop: 4, fontWeight: 600,
                    color: quadFeedback === 'ok' ? 'var(--color-success)' : 'var(--color-danger)' }}>
                    {quadFeedback === 'ok' ? 'Cuadrante guardado' : 'Error al guardar'}
                  </div>
                )}
              </div>
              <div>
                <div className="drawer-section-title">Reportado</div>
                <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)', marginTop: 2 }}>
                  {formatDateTime(incident.created_at)}
                </div>
                <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>{timeAgo(incident.created_at)}</div>
              </div>
              <div>
                <div className="drawer-section-title">Última actualización</div>
                <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)', marginTop: 2 }}>
                  {formatDateTime(incident.updated_at)}
                </div>
              </div>
            </div>
          </div>

          {/* 4. Ciudadano reportante (datos reales de perfiles_ciudadanos) */}
          {reporter && (
            <div className="drawer-section" style={{ background: 'rgba(243,242,255,0.4)', borderRadius: 'var(--radius-md)', margin: '0 -12px', padding: '10px 16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 8 }}>
                <IconUser size={12} style={{ color: 'var(--color-purple)' }} />
                <span className="drawer-section-title" style={{ margin: 0, color: 'var(--color-purple)' }}>Ciudadano reportante</span>
              </div>
              <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
                {reporter.nombre_completo && (
                  <div>
                    <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Nombre</div>
                    <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)' }}>{reporter.nombre_completo}</div>
                  </div>
                )}
                {reporter.email && (
                  <div>
                    <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Email</div>
                    <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)' }}>{reporter.email}</div>
                  </div>
                )}
                {reporter.celular && (
                  <div>
                    <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Celular</div>
                    <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)' }}>{reporter.celular}</div>
                  </div>
                )}
                {reporter.comuna && (
                  <div>
                    <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>Comuna</div>
                    <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)' }}>{reporter.comuna}</div>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* 5. Descripción del ciudadano */}
          <div className="drawer-section">
            <div className="drawer-section-title">Descripción del ciudadano</div>
            <div style={{
              background: 'var(--bg-card)', border: '1px solid var(--border-purple)',
              borderRadius: 'var(--radius-sm)', padding: '10px 12px',
              fontStyle: 'italic', fontSize: '0.875rem', lineHeight: 1.65,
              color: 'var(--color-text-dark)',
            }}>
              {incident.description || 'El ciudadano no proporcionó descripción adicional.'}
            </div>
          </div>

          {/* 6. Cuadrilla operativa recomendada por categoría */}
          <div className="drawer-section" style={{
            background: 'var(--color-success-pale)',
            border: '1px solid rgba(159, 209, 186, 0.4)',
            borderRadius: 'var(--radius-lg)',
            margin: '0 -12px',
            padding: '12px 16px',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
              <IconSquad size={14} style={{ color: 'var(--color-success)' }} />
              <span style={{ fontWeight: 700, fontSize: '0.8125rem', color: 'var(--color-success)' }}>
                Cuadrilla Operativa Recomendada
              </span>
              <span style={{ fontSize: '0.6rem', fontWeight: 700, color: 'var(--color-text-muted)', marginLeft: 4, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                (Por categoría — asignación manual en Fase 2)
              </span>
            </div>
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              background: 'var(--bg-card)', border: '1px solid rgba(159, 209, 186, 0.5)',
              borderRadius: 'var(--radius-md)', padding: '10px 12px', flexWrap: 'wrap', gap: 8,
            }}>
              <div>
                <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-navy)' }}>{cuadrilla.nombre}</div>
                <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', marginTop: 2 }}>{cuadrilla.operarios}</div>
              </div>
              <span style={{ background: 'var(--color-success-lighter)', color: 'var(--color-success)', padding: '3px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600 }}>
                Disponible · {cuadrilla.dist}
              </span>
            </div>
          </div>

          {/* Feedback de acción */}
          {feedback && (
            <div className="drawer-section">
              <div style={{
                display: 'flex', alignItems: 'center', gap: 8, padding: '8px 12px',
                borderRadius: 'var(--radius-md)',
                background: feedback === 'success' ? 'var(--color-success-light)' : 'var(--color-primary-light)',
                color: feedback === 'success' ? 'var(--color-success-mid)' : 'var(--color-primary-muted)',
                fontSize: '0.75rem', fontWeight: 600,
              }}>
                {feedback === 'success' ? <IconValidate size={13} /> : <IconAlert size={13} />}
                {feedback === 'success'
                  ? 'Estado actualizado — el ciudadano lo verá en tiempo real en su app'
                  : 'Error al actualizar el estado — intenta de nuevo'}
              </div>
            </div>
          )}
        </div>

        {/* ── Footer — acciones ── */}
        <div className="drawer-footer">
          <div className="drawer-actions-primary">
            <button
              className="btn btn-blue btn-lg"
              onClick={() => handleStatus('en_proceso')}
              disabled={updating || incident.status === 'en_proceso'}
            >
              <IconValidate size={13} />
              {incident.status === 'en_proceso' ? 'Ya en proceso' : 'Validar reporte'}
            </button>
            <button
              className="btn btn-success btn-lg"
              onClick={() => handleStatus('resuelto')}
              disabled={updating || incident.status === 'resuelto'}
            >
              <IconSquad size={13} />
              {incident.status === 'resuelto' ? 'Ya resuelto' : 'Marcar resuelto'}
            </button>
          </div>
          <div className="drawer-actions-secondary">
            <button className="btn btn-outline" disabled>
              <IconCamera size={12} />
              Seleccionar evidencia
            </button>
            <button
              className="btn btn-danger"
              onClick={() => handleStatus('pendiente')}
              disabled={updating || incident.status === 'pendiente'}
            >
              <IconX size={11} />
              {incident.status === 'pendiente' ? 'Ya pendiente' : 'Rechazar / Duplicado'}
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
