import { useState, useMemo } from 'react';
import { StatusBadge, SeverityBadge, CategoryBadge } from '../ui/Badge.jsx';
import { IconSearch, IconFilter, IconLocation, IconClock, IconDotsVertical } from '../ui/Icons.jsx';
import {
  CATEGORY_LABELS, SEVERITY_COLOR, STATUS_COLOR,
  timeAgo, formatDate, incidentId
} from '../../utils/statusHelpers.js';

const STATUS_OPTS   = [{ v: '', l: 'Todos los estados' }, { v: 'pendiente', l: 'Pendiente' }, { v: 'en_proceso', l: 'En proceso' }, { v: 'resuelto', l: 'Resuelto' }];
const CATEGORY_OPTS = [{ v: '', l: 'Todas las categorías' }, { v: 'hueco_via', l: 'Hueco / Vía' }, { v: 'servicios_publicos', l: 'Serv. Públicos' }, { v: 'comunitario', l: 'Comunitario' }, { v: 'aseo_parques', l: 'Aseo y Parques' }];
const SEVERITY_OPTS = [{ v: '', l: 'Todas las severidades' }, { v: 'critico', l: 'Crítico' }, { v: 'alta', l: 'Alta' }, { v: 'media', l: 'Media' }, { v: 'baja', l: 'Baja' }];

export default function IncidentTable({ incidents = [], onSelectIncident }) {
  const [search,   setSearch]   = useState('');
  const [status,   setStatus]   = useState('');
  const [category, setCategory] = useState('');
  const [severity, setSeverity] = useState('');
  const [sortCol,  setSortCol]  = useState('created_at');
  const [sortAsc,  setSortAsc]  = useState(false);

  function toggleSort(col) {
    if (sortCol === col) setSortAsc(a => !a);
    else { setSortCol(col); setSortAsc(false); }
  }

  const filtered = useMemo(() => {
    let result = [...incidents];
    if (search)   result = result.filter(i => i.title?.toLowerCase().includes(search.toLowerCase()) || i.address?.toLowerCase().includes(search.toLowerCase()) || incidentId(i.id).toLowerCase().includes(search.toLowerCase()));
    if (status)   result = result.filter(i => i.status   === status);
    if (category) result = result.filter(i => i.category === category);
    if (severity) result = result.filter(i => i.severity === severity);

    result.sort((a, b) => {
      let va = a[sortCol], vb = b[sortCol];
      if (typeof va === 'string') va = va.toLowerCase();
      if (typeof vb === 'string') vb = vb.toLowerCase();
      if (va < vb) return sortAsc ? -1 :  1;
      if (va > vb) return sortAsc ?  1 : -1;
      return 0;
    });
    return result;
  }, [incidents, search, status, category, severity, sortCol, sortAsc]);

  function SortArrow({ col }) {
    if (sortCol !== col) return <span style={{ opacity: 0.25, fontSize: '0.6rem' }}>↕</span>;
    return <span style={{ fontSize: '0.6rem', color: 'var(--color-primary)' }}>{sortAsc ? '↑' : '↓'}</span>;
  }

  return (
    <div className="card" style={{ overflow: 'hidden' }}>
      {/* Toolbar */}
      <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--border-soft)', display: 'flex', gap: 10, alignItems: 'center', flexWrap: 'wrap', background: 'var(--bg-header)' }}>
        <div className="search-input" style={{ flex: '1 1 200px' }}>
          <IconSearch size={13} style={{ color: 'var(--color-text-muted)' }} />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Buscar por título, dirección o REP-ID..."
          />
        </div>
        <select className="select-filter" value={status}   onChange={e => setStatus(e.target.value)}>
          {STATUS_OPTS.map(o   => <option key={o.v} value={o.v}>{o.l}</option>)}
        </select>
        <select className="select-filter" value={category} onChange={e => setCategory(e.target.value)}>
          {CATEGORY_OPTS.map(o => <option key={o.v} value={o.v}>{o.l}</option>)}
        </select>
        <select className="select-filter" value={severity} onChange={e => setSeverity(e.target.value)}>
          {SEVERITY_OPTS.map(o => <option key={o.v} value={o.v}>{o.l}</option>)}
        </select>
        <span style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', marginLeft: 'auto', whiteSpace: 'nowrap' }}>
          {filtered.length} de {incidents.length} reportes
        </span>
      </div>

      {/* Tabla */}
      <div style={{ overflowX: 'auto' }}>
        <table className="incidents-table">
          <thead>
            <tr>
              <th onClick={() => toggleSort('id')}          style={{ width: 90 }}>ID <SortArrow col="id" /></th>
              <th onClick={() => toggleSort('title')}       style={{ minWidth: 200 }}>Título <SortArrow col="title" /></th>
              <th onClick={() => toggleSort('category')}    style={{ width: 130 }}>Categoría <SortArrow col="category" /></th>
              <th onClick={() => toggleSort('severity')}    style={{ width: 90 }}>Severidad <SortArrow col="severity" /></th>
              <th onClick={() => toggleSort('status')}      style={{ width: 110 }}>Estado <SortArrow col="status" /></th>
              <th onClick={() => toggleSort('quadrant')}    style={{ width: 70 }}>Cuadr. <SortArrow col="quadrant" /></th>
              <th onClick={() => toggleSort('created_at')}  style={{ width: 110 }}>Reportado <SortArrow col="created_at" /></th>
              <th style={{ width: 36 }}></th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 && (
              <tr>
                <td colSpan={8}>
                  <div className="empty-state">
                    <IconFilter size={28} className="empty-state-icon" />
                    <div className="empty-state-title">Sin resultados</div>
                    <div className="empty-state-sub">Ajusta los filtros para ver incidentes</div>
                  </div>
                </td>
              </tr>
            )}
            {filtered.map(inc => (
              <tr key={inc.id} onClick={() => onSelectIncident?.(inc)}>
                <td>
                  <span className="incident-id">{incidentId(inc.id)}</span>
                </td>
                <td>
                  <div className="incident-title">{inc.title}</div>
                  {inc.address && (
                    <div className="incident-location" style={{ display: 'flex', alignItems: 'center', gap: 3, marginTop: 2 }}>
                      <IconLocation size={10} />
                      {inc.address}
                    </div>
                  )}
                </td>
                <td><CategoryBadge category={inc.category} /></td>
                <td><SeverityBadge severity={inc.severity} /></td>
                <td><StatusBadge   status={inc.status} /></td>
                <td>
                  <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--color-navy)' }}>
                    {inc.quadrant || '—'}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 3, fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>
                    <IconClock size={10} />
                    {timeAgo(inc.created_at)}
                  </div>
                  <div style={{ fontSize: '0.625rem', color: 'var(--color-text-muted)', marginTop: 1 }}>
                    {formatDate(inc.created_at)}
                  </div>
                </td>
                <td onClick={e => e.stopPropagation()}>
                  <button className="btn btn-ghost btn-icon">
                    <IconDotsVertical size={13} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
