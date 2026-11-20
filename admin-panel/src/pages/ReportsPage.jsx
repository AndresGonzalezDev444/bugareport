import { useState, useMemo } from 'react';
import { jsPDF } from 'jspdf';
import { IconDownload, IconCheck, IconLocation, IconCamera, IconFilter } from '../components/ui/Icons.jsx';
import { StatusBadge, SeverityBadge, CategoryBadge } from '../components/ui/Badge.jsx';
import { CATEGORY_COLOR, SEVERITY_COLOR, formatDate, incidentId } from '../utils/statusHelpers.js';
import { queryIncidents, toCSVRows } from '../utils/queryService.js';

const CATEGORY_LABEL_MAP = {
  hueco_via: 'Hueco / Vía',
  servicios_publicos: 'Serv. Públicos',
  comunitario: 'Comunitario',
  aseo_parques: 'Aseo y Parques',
};

const STATUS_LABEL_MAP = {
  pendiente: 'Pendiente',
  en_proceso: 'En proceso',
  resuelto: 'Resuelto',
};

export default function ReportsPage({ incidents }) {
  const [selected, setSelected] = useState(new Set());

  // Filtros
  const [filtroDesde,     setFiltroDesde]     = useState('');
  const [filtroHasta,     setFiltroHasta]     = useState('');
  const [filtroCategoria, setFiltroCategoria] = useState('');
  const [filtroEstado,    setFiltroEstado]    = useState('');
  const [filtroCuadrante, setFiltroCuadrante] = useState('');

  // Solo incidentes validados (en_proceso o resuelto)
  const validated = useMemo(
    () => incidents.filter(i => i.status === 'en_proceso' || i.status === 'resuelto'),
    [incidents]
  );

  // Aplicar filtros encima de los validados
  const filtrados = useMemo(() => queryIncidents(validated, {
    categoria:   filtroCategoria,
    estado:      filtroEstado,
    cuadrante:   filtroCuadrante,
    fechaDesde:  filtroDesde,
    fechaHasta:  filtroHasta,
  }), [validated, filtroCategoria, filtroEstado, filtroCuadrante, filtroDesde, filtroHasta]);

  const hayFiltros = filtroDesde || filtroHasta || filtroCategoria || filtroEstado || filtroCuadrante;

  function limpiarFiltros() {
    setFiltroDesde(''); setFiltroHasta('');
    setFiltroCategoria(''); setFiltroEstado(''); setFiltroCuadrante('');
  }

  // Periodo descriptivo para el encabezado del informe
  const periodoLabel = useMemo(() => {
    if (filtroDesde && filtroHasta) return `${filtroDesde} — ${filtroHasta}`;
    if (filtroDesde) return `Desde ${filtroDesde}`;
    if (filtroHasta) return `Hasta ${filtroHasta}`;
    return new Date().toLocaleDateString('es-CO', { month: 'long', year: 'numeric' });
  }, [filtroDesde, filtroHasta]);

  function toggleSelect(id) {
    setSelected(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  }

  function toggleAll() {
    if (selected.size === filtrados.length) {
      setSelected(new Set());
    } else {
      setSelected(new Set(filtrados.map(i => i.id)));
    }
  }

  const selectedIncidents = filtrados.filter(i => selected.has(i.id));

  // ── Exportar CSV ──────────────────────────────────────────────
  function exportCSV() {
    const rows = toCSVRows(selectedIncidents);
    const csv  = rows.map(r => r.map(c => `"${String(c).replace(/"/g, '""')}"`).join(',')).join('\n');
    const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' });
    const url  = URL.createObjectURL(blob);
    const a    = document.createElement('a');
    a.href = url; a.download = `bugareport_incidentes_${Date.now()}.csv`;
    a.click(); URL.revokeObjectURL(url);
  }

  // ── Generar PDF con jsPDF ─────────────────────────────────────
  function generatePDF() {
    const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
    const pageW = 210;
    const margin = 18;
    const colW = pageW - margin * 2;

    // Encabezado
    doc.setFillColor(91, 5, 16);
    doc.rect(0, 0, pageW, 28, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(14);
    doc.setFont('helvetica', 'bold');
    doc.text('BugaReport — Informe Oficial de Incidentes', margin, 11);
    doc.setFontSize(8);
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado: ${new Date().toLocaleString('es-CO')}  |  Periodo: ${periodoLabel}  |  Validez Juridica Municipal`, margin, 19);

    // Subtitulo
    doc.setTextColor(91, 5, 16);
    doc.setFontSize(10);
    doc.setFont('helvetica', 'bold');
    doc.text(`Incidentes Seleccionados: ${selectedIncidents.length}`, margin, 36);

    // Cabecera de tabla
    let y = 44;
    const cols = [
      { label: 'ID',         w: 22 },
      { label: 'Título',     w: 54 },
      { label: 'Categoría',  w: 28 },
      { label: 'Estado',     w: 24 },
      { label: 'Cuadrante',  w: 22 },
      { label: 'GPS',        w: 30 },
      { label: 'Fecha',      w: 22 },
    ];
    const totalW = cols.reduce((s, c) => s + c.w, 0);

    doc.setFillColor(19, 26, 54);
    doc.rect(margin, y, totalW, 7, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(7);
    doc.setFont('helvetica', 'bold');
    let cx = margin;
    cols.forEach(col => {
      doc.text(col.label, cx + 2, y + 5);
      cx += col.w;
    });
    y += 7;

    // Filas
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(7);
    selectedIncidents.forEach((inc, idx) => {
      if (y > 268) {
        doc.addPage();
        y = 20;
      }
      const bg = idx % 2 === 0 ? [255, 255, 255] : [249, 249, 252];
      doc.setFillColor(...bg);
      doc.rect(margin, y, totalW, 7, 'F');
      doc.setTextColor(19, 26, 54);

      const values = [
        incidentId(inc.id),
        (inc.title || '').substring(0, 28),
        CATEGORY_LABEL_MAP[inc.category] || inc.category || '',
        STATUS_LABEL_MAP[inc.status]     || inc.status    || '',
        inc.quadrant || '—',
        `${inc.latitude?.toFixed(4) ?? '—'}, ${inc.longitude?.toFixed(4) ?? '—'}`,
        formatDate(inc.created_at),
      ];

      cx = margin;
      values.forEach((val, vi) => {
        doc.text(String(val), cx + 2, y + 5);
        cx += cols[vi].w;
      });

      // Línea separadora
      doc.setDrawColor(230, 230, 235);
      doc.line(margin, y + 7, margin + totalW, y + 7);
      y += 7;
    });

    // Footer
    y += 10;
    if (y > 268) { doc.addPage(); y = 20; }
    doc.setFontSize(7);
    doc.setTextColor(140, 140, 140);
    doc.text(
      'Alcaldia Municipal de Guadalajara de Buga · Secretaria de Infraestructura y Servicios Publicos · BugaReport Civic Console v1.0',
      margin, y
    );

    doc.save(`bugareport_informe_${Date.now()}.pdf`);
  }

  // Cuadrantes disponibles en la lista actual
  const cuadrantesDisponibles = [...new Set(validated.map(i => i.quadrant).filter(Boolean))].sort();

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
            Exportar CSV
          </button>
          <button className="btn btn-primary" onClick={generatePDF} disabled={selected.size === 0}>
            <IconDownload size={13} />
            Generar Informe PDF Oficial
          </button>
        </div>
      </div>

      <div className="page-content" style={{ flex: 1 }}>
        {/* Filtros de periodo y categoría */}
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', alignItems: 'center', marginBottom: 14, padding: '10px 14px', background: 'var(--bg-header)', border: '1px solid var(--border-soft)', borderRadius: 'var(--radius-md)' }}>
          <IconFilter size={13} style={{ color: 'var(--color-text-muted)' }} />
          <input
            type="date"
            value={filtroDesde}
            onChange={e => setFiltroDesde(e.target.value)}
            className="select-filter"
            title="Fecha desde"
            style={{ fontSize: '0.8rem' }}
          />
          <input
            type="date"
            value={filtroHasta}
            onChange={e => setFiltroHasta(e.target.value)}
            className="select-filter"
            title="Fecha hasta"
            style={{ fontSize: '0.8rem' }}
          />
          <select className="select-filter" value={filtroCategoria} onChange={e => setFiltroCategoria(e.target.value)}>
            <option value="">Todas las categorías</option>
            {Object.entries(CATEGORY_LABEL_MAP).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
          </select>
          <select className="select-filter" value={filtroEstado} onChange={e => setFiltroEstado(e.target.value)}>
            <option value="">Todos los estados</option>
            <option value="en_proceso">En proceso</option>
            <option value="resuelto">Resuelto</option>
          </select>
          <select className="select-filter" value={filtroCuadrante} onChange={e => setFiltroCuadrante(e.target.value)}>
            <option value="">Todos los cuadrantes</option>
            {cuadrantesDisponibles.map(q => <option key={q} value={q}>{q}</option>)}
          </select>
          {hayFiltros && (
            <button className="btn btn-ghost" onClick={limpiarFiltros} style={{ fontSize: '0.75rem', padding: '5px 10px' }}>
              Limpiar filtros
            </button>
          )}
          <span style={{ marginLeft: 'auto', fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>
            {filtrados.length} de {validated.length} validados
          </span>
        </div>

        <div className="evidence-layout">
          {/* Panel izquierdo — lista de incidentes */}
          <div className="evidence-list-panel">
            <div className="evidence-list-header">
              <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
                <div
                  className={`evidence-checkbox${selected.size === filtrados.length && filtrados.length > 0 ? ' checked' : ''}`}
                  onClick={toggleAll}
                  style={{ cursor: 'pointer' }}
                >
                  {selected.size === filtrados.length && filtrados.length > 0 && (
                    <IconCheck size={11} style={{ color: 'white' }} />
                  )}
                </div>
                <span style={{ fontWeight: 700, fontSize: '0.875rem', color: 'var(--color-navy)' }}>
                  Reportes seleccionados ({selected.size})
                </span>
              </div>
              <span style={{ fontSize: '0.6875rem', color: 'var(--color-primary)', fontWeight: 600 }}>
                {periodoLabel}
              </span>
            </div>

            <div className="evidence-list-filter">
              <span style={{ color: 'var(--color-text-muted)', fontSize: '0.75rem' }}>
                Filtro: Validados para Despacho
              </span>
              <span style={{ color: 'var(--color-primary)', fontWeight: 600, fontSize: '0.75rem' }}>
                {selected.size}/{filtrados.length} seleccionados
              </span>
            </div>

            <div className="evidence-list-body">
              {filtrados.length === 0 && (
                <div className="empty-state">
                  <IconCamera size={24} className="empty-state-icon" />
                  <div className="empty-state-title">Sin incidentes validados</div>
                  <div className="empty-state-sub">Valida reportes desde la sección Incidentes o ajusta los filtros</div>
                </div>
              )}
              {filtrados.map(inc => (
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

                  {/* Thumbnail */}
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
                          Alcaldía Municipal de Guadalajara de Buga · {periodoLabel}
                        </div>
                      </div>
                    </div>
                    <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
                      {[
                        { label: 'Incidentes', val: selected.size },
                        { label: 'Periodo', val: periodoLabel },
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
