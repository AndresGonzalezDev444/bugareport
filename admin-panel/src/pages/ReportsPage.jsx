import { useState, useMemo } from 'react';
import { IconDownload, IconCheck, IconLocation, IconCamera } from '../components/ui/Icons.jsx';
import { StatusBadge, SeverityBadge, CategoryBadge } from '../components/ui/Badge.jsx';
import { CATEGORY_COLOR, SEVERITY_COLOR, formatDate, incidentId } from '../utils/statusHelpers.js';

export default function ReportsPage({ incidents }) {
  const [selected, setSelected] = useState(new Set());
  const [period, setPeriod]     = useState('Oct 2026');

  const validated = useMemo(
    () => incidents.filter(i => i.status === 'en_proceso' || i.status === 'resuelto'),
    [incidents]
  );

  function toggleSelect(id) {
    setSelected(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  }

  function toggleAll() {
    if (selected.size === validated.length) {
      setSelected(new Set());
    } else {
      setSelected(new Set(validated.map(i => i.id)));
    }
  }

  const selectedIncidents = validated.filter(i => selected.has(i.id));

  function exportCSV() {
    const rows = [
      ['ID', 'Título', 'Categoría', 'Severidad', 'Estado', 'Cuadrante', 'Dirección', 'Lat', 'Lon', 'Fecha'],
      ...selectedIncidents.map(i => [
        incidentId(i.id), i.title, i.category, i.severity,
        i.status, i.quadrant || '', i.address || '',
        i.latitude, i.longitude, formatDate(i.created_at),
      ])
    ];
    const csv  = rows.map(r => r.map(c => `"${c}"`).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url  = URL.createObjectURL(blob);
    const a    = document.createElement('a');
    a.href = url; a.download = `bugareport_incidentes_${Date.now()}.csv`;
    a.click(); URL.revokeObjectURL(url);
  }

  function generatePDF() {
    const win = window.open('', '_blank');
    const html = `
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8" />
        <title>Informe Oficial BugaReport</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 40px; color: #131A36; }
          h1 { font-size: 20px; color: #5B0510; border-bottom: 2px solid #5B0510; padding-bottom: 8px; }
          h2 { font-size: 14px; color: #131A36; margin-top: 20px; }
          table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: 11px; }
          th { background: #131A36; color: white; padding: 6px 8px; text-align: left; }
          td { padding: 5px 8px; border-bottom: 1px solid #eee; }
          tr:nth-child(even) td { background: #f9f9f9; }
          .footer { margin-top: 40px; font-size: 10px; color: #888; border-top: 1px solid #ddd; padding-top: 8px; }
          .badge { padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: bold; }
        </style>
      </head>
      <body>
        <h1>BugaReport — Informe Oficial de Incidentes</h1>
        <p style="font-size:12px;color:#564241;">
          Generado: ${new Date().toLocaleString('es-CO')} &nbsp;|&nbsp;
          Periodo: ${period} &nbsp;|&nbsp;
          Validez Jurídica Municipal
        </p>
        <h2>Incidentes Seleccionados (${selectedIncidents.length})</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th><th>Título</th><th>Categoría</th><th>Severidad</th>
              <th>Estado</th><th>Cuadrante</th><th>Coordenadas GPS</th><th>Fecha</th>
            </tr>
          </thead>
          <tbody>
            ${selectedIncidents.map(i => `
              <tr>
                <td><strong>${incidentId(i.id)}</strong></td>
                <td>${i.title}</td>
                <td>${i.category}</td>
                <td>${i.severity}</td>
                <td>${i.status}</td>
                <td>${i.quadrant || '—'}</td>
                <td style="font-family:monospace;font-size:10px;">${i.latitude?.toFixed(5)}, ${i.longitude?.toFixed(5)}</td>
                <td>${formatDate(i.created_at)}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
        <div class="footer">
          Alcaldía Municipal de Guadalajara de Buga · Secretaría de Infraestructura y Servicios Públicos ·
          Documento generado por BugaReport Civic Console v1.0
        </div>
      </body>
      </html>
    `;
    win.document.write(html);
    win.document.close();
    win.print();
  }

  return (
    <>
      {/* Sub-header */}
      <div className="page-sub-header">
        <div className="page-heading">
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <h1>Colección de Evidencias y Generación de Informes</h1>
            <span style={{ background: 'var(--color-success-lighter)', color: 'var(--color-success)', padding: '3px 10px', borderRadius: 'var(--radius-pill)', fontSize: '0.6875rem', fontWeight: 600 }}>
              Validez Jurídica
            </span>
          </div>
          <div className="page-heading-sub">
            Selecciona incidentes validados y exporta informes ejecutivos con validez jurídica municipal
          </div>
        </div>
        <div className="page-actions">
          <button className="btn btn-outline-primary" onClick={exportCSV} disabled={selected.size === 0}>
            <IconDownload size={13} />
            Exportar CSV / GeoJSON
          </button>
          <button className="btn btn-primary" onClick={generatePDF} disabled={selected.size === 0}>
            <IconDownload size={13} />
            Generar Informe PDF Oficial
          </button>
        </div>
      </div>

      <div className="page-content" style={{ flex: 1 }}>
        <div className="evidence-layout">
          {/* Panel izquierdo — lista de incidentes */}
          <div className="evidence-list-panel">
            <div className="evidence-list-header">
              <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
                <div
                  className={`evidence-checkbox${selected.size === validated.length && validated.length > 0 ? ' checked' : ''}`}
                  onClick={toggleAll}
                  style={{ cursor: 'pointer' }}
                >
                  {selected.size === validated.length && validated.length > 0 && (
                    <IconCheck size={11} style={{ color: 'white' }} />
                  )}
                </div>
                <span style={{ fontWeight: 700, fontSize: '0.875rem', color: 'var(--color-navy)' }}>
                  Reportes seleccionados ({selected.size})
                </span>
              </div>
              <select className="select-filter" value={period} onChange={e => setPeriod(e.target.value)}>
                <option>Oct 2026</option>
                <option>Sep 2026</option>
                <option>Ago 2026</option>
              </select>
            </div>

            <div className="evidence-list-filter">
              <span style={{ color: 'var(--color-text-muted)', fontSize: '0.75rem' }}>
                Filtro: Validados para Despacho
              </span>
              <span style={{ color: 'var(--color-primary)', fontWeight: 600, fontSize: '0.75rem' }}>
                {selected.size}/{validated.length} seleccionados
              </span>
            </div>

            <div className="evidence-list-body">
              {validated.length === 0 && (
                <div className="empty-state">
                  <IconCamera size={24} className="empty-state-icon" />
                  <div className="empty-state-title">Sin incidentes validados</div>
                  <div className="empty-state-sub">Valida reportes desde la sección Incidentes</div>
                </div>
              )}
              {validated.map(inc => (
                <div
                  key={inc.id}
                  className={`evidence-card${selected.has(inc.id) ? ' selected' : ''}`}
                  onClick={() => toggleSelect(inc.id)}
                >
                  <div
                    className={`evidence-checkbox${selected.has(inc.id) ? ' checked' : ''}`}
                    style={{ marginTop: 0, flexShrink: 0 }}
                  >
                    {selected.has(inc.id) && <IconCheck size={11} style={{ color: 'white' }} />}
                  </div>

                  {/* Thumbnail con badge de severidad */}
                  <div style={{ position: 'relative', flexShrink: 0 }}>
                    {inc.photo_url ? (
                      <img src={inc.photo_url} alt="" className="evidence-thumb" />
                    ) : (
                      <div className="evidence-thumb-placeholder">
                        <IconCamera size={18} style={{ color: 'var(--color-text-muted)', opacity: 0.4 }} />
                      </div>
                    )}
                    <div style={{
                      position: 'absolute', top: 2, left: 2,
                      background: SEVERITY_COLOR[inc.severity] || 'var(--color-primary)',
                      color: 'white', padding: '1px 5px',
                      borderRadius: 3, fontSize: '0.5rem', fontWeight: 700,
                      letterSpacing: '0.06em', textTransform: 'uppercase',
                    }}>
                      {inc.severity?.toUpperCase()}
                    </div>
                  </div>

                  <div className="evidence-info">
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span className="evidence-rep">{incidentId(inc.id)}</span>
                      <span style={{ fontSize: '0.625rem', color: 'var(--color-text-muted)' }}>{formatDate(inc.created_at)}</span>
                    </div>
                    <div className="evidence-title">{inc.title}</div>
                    <div className="evidence-loc">
                      <IconLocation size={9} />
                      {inc.quadrant || '—'} · {inc.address?.split(',')[0] || '—'}
                    </div>
                    <div className="evidence-gps">
                      GPS: {inc.latitude?.toFixed(4)}, {inc.longitude?.toFixed(4)}
                    </div>
                    <div style={{ marginTop: 4 }}>
                      <StatusBadge status={inc.status} />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Panel derecho — vista previa */}
          <div className="report-preview-panel">
            <div className="card-header" style={{ borderRadius: 'var(--radius-lg) var(--radius-lg) 0 0' }}>
              <div>
                <div className="card-title">Vista previa del informe</div>
                <div className="card-subtitle">
                  {selected.size > 0 ? `${selected.size} incidente${selected.size > 1 ? 's' : ''} incluido${selected.size > 1 ? 's' : ''}` : 'Selecciona incidentes para generar el informe'}
                </div>
              </div>
            </div>

            <div style={{ flex: 1, overflow: 'auto', padding: 24 }}>
              {selected.size === 0 ? (
                <div className="empty-state" style={{ paddingTop: 80 }}>
                  <IconDownload size={32} className="empty-state-icon" />
                  <div className="empty-state-title">Informe vacío</div>
                  <div className="empty-state-sub">Selecciona al menos un incidente validado para generar el informe PDF oficial</div>
                </div>
              ) : (
                <div>
                  {/* Encabezado del informe */}
                  <div style={{
                    border: '2px solid var(--color-primary)', borderRadius: '12px',
                    padding: 20, marginBottom: 20, background: 'rgba(91,5,16,0.03)'
                  }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
                      <img src="/assets/images/logo-buga-report.png" alt="" style={{ width: 36, height: 36, objectFit: 'contain' }} />
                      <div>
                        <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1rem', color: 'var(--color-primary)' }}>
                          BugaReport — Informe Oficial
                        </div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>
                          Alcaldía Municipal de Guadalajara de Buga · {period}
                        </div>
                      </div>
                    </div>
                    <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
                      {[
                        { label: 'Incidentes', val: selected.size },
                        { label: 'Periodo', val: period },
                        { label: 'Generado', val: new Date().toLocaleDateString('es-CO') },
                        { label: 'Validez', val: 'Jurídica Municipal' },
                      ].map(({ label, val }) => (
                        <div key={label}>
                          <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em' }}>{label}</div>
                          <div style={{ fontWeight: 700, fontSize: '0.875rem', color: 'var(--color-navy)' }}>{val}</div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Lista de incidentes seleccionados */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                    {selectedIncidents.map((inc, idx) => (
                      <div key={inc.id} style={{
                        display: 'flex', alignItems: 'flex-start', gap: 12,
                        padding: '10px 12px', background: 'var(--bg-header)',
                        border: '1px solid var(--border-soft)', borderRadius: 'var(--radius-md)'
                      }}>
                        <span style={{ fontWeight: 700, fontSize: '0.75rem', color: 'var(--color-text-muted)', minWidth: 20 }}>
                          {idx + 1}.
                        </span>
                        <div style={{ flex: 1 }}>
                          <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 4 }}>
                            <span style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: '0.75rem', color: 'var(--color-primary)' }}>
                              {incidentId(inc.id)}
                            </span>
                            <CategoryBadge category={inc.category} />
                            <SeverityBadge severity={inc.severity} />
                          </div>
                          <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-navy)', marginBottom: 3 }}>
                            {inc.title}
                          </div>
                          <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
                            <span style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', display: 'flex', alignItems: 'center', gap: 3 }}>
                              <IconLocation size={9} />{inc.quadrant} · {inc.address?.split(',')[0]}
                            </span>
                            <span style={{ fontSize: '0.625rem', color: 'var(--color-text-muted)', fontFamily: 'JetBrains Mono, monospace' }}>
                              {inc.latitude?.toFixed(4)}, {inc.longitude?.toFixed(4)}
                            </span>
                          </div>
                        </div>
                        <StatusBadge status={inc.status} />
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
