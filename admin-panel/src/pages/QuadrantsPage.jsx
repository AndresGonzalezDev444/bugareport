// pages/QuadrantsPage.jsx
// HU1 - Gestion de cuadrantes geograficos
// CRUD: crear, editar, eliminar cuadrantes. Mapa Leaflet para visualizacion.

import { useState, useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { IconLocation, IconCheck, IconX, IconAlert, IconRefresh } from '../components/ui/Icons.jsx';

const BUGA_CENTER = [3.9001, -76.3000];

const COLORES = [
  '#5B0510', '#7A1E23', '#86521B', '#2B5C8F',
  '#4B4ECC', '#2E5D4B', '#131A36', '#16A34A',
];

function FormCuadrante({ cuadrante, onGuardar, onCancelar }) {
  const [form, setForm] = useState({
    id:          cuadrante?.id          || '',
    nombre:      cuadrante?.nombre      || '',
    descripcion: cuadrante?.descripcion || '',
    lat:         cuadrante?.lat         || 3.9001,
    lon:         cuadrante?.lon         || -76.3000,
    radio:       cuadrante?.radio       || 300,
    color:       cuadrante?.color       || '#5B0510',
  });
  const esEdicion = !!cuadrante;

  function handleChange(e) {
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }));
  }

  function handleSubmit(e) {
    e.preventDefault();
    if (!form.nombre.trim()) return;
    onGuardar(form);
  }

  const inputStyle = {
    width: '100%', padding: '8px 10px', borderRadius: 'var(--radius-md)',
    border: '1px solid var(--border-medium)', background: 'var(--bg-header)',
    fontSize: '0.8125rem', color: 'var(--color-text-dark)', outline: 'none',
    fontFamily: 'Inter, sans-serif',
  };

  return (
    <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1rem', color: 'var(--color-navy)', marginBottom: 4 }}>
        {esEdicion ? 'Editar cuadrante' : 'Nuevo cuadrante'}
      </div>

      <div>
        <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 5 }}>
          Identificador (ej: Q-15)
        </label>
        <input name="id" value={form.id} onChange={handleChange} placeholder="Q-15" style={inputStyle} disabled={esEdicion} required />
      </div>

      <div>
        <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 5 }}>
          Nombre
        </label>
        <input name="nombre" value={form.nombre} onChange={handleChange} placeholder="Sector Centro Norte" style={inputStyle} required />
      </div>

      <div>
        <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 5 }}>
          Descripcion
        </label>
        <textarea name="descripcion" value={form.descripcion} onChange={handleChange}
          placeholder="Barrios y zonas que abarca este cuadrante"
          style={{ ...inputStyle, resize: 'vertical', minHeight: 60 }}
        />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <div>
          <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 5 }}>
            Latitud centro
          </label>
          <input name="lat" type="number" step="0.0001" value={form.lat} onChange={handleChange} style={inputStyle} />
        </div>
        <div>
          <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 5 }}>
            Longitud centro
          </label>
          <input name="lon" type="number" step="0.0001" value={form.lon} onChange={handleChange} style={inputStyle} />
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <div>
          <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 5 }}>
            Radio (metros)
          </label>
          <input name="radio" type="number" min="100" max="2000" value={form.radio} onChange={handleChange} style={inputStyle} />
        </div>
        <div>
          <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 5 }}>
            Color
          </label>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {COLORES.map(c => (
              <div
                key={c}
                onClick={() => setForm(prev => ({ ...prev, color: c }))}
                style={{
                  width: 22, height: 22, borderRadius: '50%', background: c, cursor: 'pointer',
                  border: form.color === c ? '3px solid var(--color-navy)' : '2px solid transparent',
                  flexShrink: 0,
                }}
              />
            ))}
          </div>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
        <button type="submit" className="btn btn-primary" style={{ flex: 1 }}>
          <IconCheck size={12} />
          {esEdicion ? 'Guardar cambios' : 'Crear cuadrante'}
        </button>
        <button type="button" className="btn btn-outline" onClick={onCancelar}>
          <IconX size={12} />
          Cancelar
        </button>
      </div>
    </form>
  );
}

export default function QuadrantsPage({ quadrants, incidents, crearCuadrante, actualizarCuadrante, eliminarCuadrante, resetearCuadrantes }) {
  const [modo, setModo]       = useState(null); // null | 'crear' | 'editar'
  const [editando, setEditando] = useState(null);
  const [mensaje, setMensaje] = useState(null); // { tipo: 'ok'|'error', texto }
  const mapRef      = useRef(null);
  const mapInstance = useRef(null);
  const circlesRef  = useRef([]);

  function mostrarMensaje(tipo, texto) {
    setMensaje({ tipo, texto });
    setTimeout(() => setMensaje(null), 3500);
  }

  // Inicializar mapa
  useEffect(() => {
    if (mapInstance.current) return;
    mapInstance.current = L.map(mapRef.current, { center: BUGA_CENTER, zoom: 14, zoomControl: true });
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap', maxZoom: 19,
    }).addTo(mapInstance.current);
    return () => { mapInstance.current?.remove(); mapInstance.current = null; };
  }, []);

  // Renderizar circulos de cuadrantes en el mapa
  useEffect(() => {
    if (!mapInstance.current) return;
    circlesRef.current.forEach(c => c.remove());
    circlesRef.current = [];

    quadrants.forEach(q => {
      const circle = L.circle([q.lat, q.lon], {
        radius:      q.radio,
        color:       q.color,
        fillColor:   q.color,
        fillOpacity: 0.12,
        weight:      2,
      });
      circle.bindPopup(`<strong>${q.nombre}</strong><br/>${q.descripcion}`);
      circle.addTo(mapInstance.current);
      circlesRef.current.push(circle);

      const label = L.marker([q.lat, q.lon], {
        icon: L.divIcon({
          html: `<div style="background:${q.color};color:white;padding:2px 7px;border-radius:4px;font-family:JetBrains Mono,monospace;font-size:9px;font-weight:700;white-space:nowrap;">${q.id}</div>`,
          className: '', iconAnchor: [20, 10],
        }), interactive: false,
      }).addTo(mapInstance.current);
      circlesRef.current.push(label);
    });
  }, [quadrants]);

  function handleGuardar(form) {
    if (modo === 'crear') {
      crearCuadrante(form);
      mostrarMensaje('ok', `Cuadrante ${form.id} creado correctamente.`);
    } else {
      actualizarCuadrante(editando.id, form);
      mostrarMensaje('ok', `Cuadrante ${editando.id} actualizado.`);
    }
    setModo(null); setEditando(null);
  }

  function handleEliminar(q) {
    const result = eliminarCuadrante(q.id, incidents);
    if (result.ok) {
      mostrarMensaje('ok', `Cuadrante ${q.id} eliminado.`);
    } else {
      mostrarMensaje('error', result.mensaje);
    }
  }

  // Contar reportes por cuadrante
  function contarReportes(qId) {
    return incidents.filter(inc => inc.quadrant === qId).length;
  }
  function contarActivos(qId) {
    return incidents.filter(inc => inc.quadrant === qId && inc.status !== 'resuelto').length;
  }

  return (
    <>
      <div className="page-sub-header">
        <div className="page-heading">
          <h1>Gestion de Cuadrantes</h1>
          <div className="page-heading-sub">Crea, modifica y administra los cuadrantes geograficos de Guadalajara de Buga</div>
        </div>
        <div className="page-actions">
          <button className="btn btn-outline" onClick={resetearCuadrantes}>
            <IconRefresh size={13} />
            Restaurar por defecto
          </button>
          <button className="btn btn-primary" onClick={() => { setModo('crear'); setEditando(null); }}>
            <IconLocation size={13} />
            Nuevo cuadrante
          </button>
        </div>
      </div>

      {mensaje && (
        <div style={{
          margin: '0 24px 12px', padding: '10px 16px', borderRadius: 'var(--radius-md)', fontSize: '0.8125rem', fontWeight: 600,
          background: mensaje.tipo === 'ok' ? 'rgba(22,163,74,0.1)' : 'rgba(186,26,26,0.1)',
          border: `1px solid ${mensaje.tipo === 'ok' ? 'rgba(22,163,74,0.3)' : 'rgba(186,26,26,0.3)'}`,
          color: mensaje.tipo === 'ok' ? 'var(--color-success)' : 'var(--color-danger)',
          display: 'flex', alignItems: 'center', gap: 8,
        }}>
          {mensaje.tipo === 'ok' ? <IconCheck size={14} /> : <IconAlert size={14} />}
          {mensaje.texto}
        </div>
      )}

      <div className="page-content" style={{ display: 'grid', gridTemplateColumns: 'minmax(0,1fr) 340px', gap: 20, alignItems: 'start' }}>

        {/* Columna izquierda: mapa + tabla */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>

          {/* Mapa */}
          <div className="card" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div className="card-title">Mapa de cuadrantes — Guadalajara de Buga</div>
              <div className="card-subtitle">Cada circulo representa el area de cobertura del cuadrante</div>
            </div>
            <div ref={mapRef} style={{ height: 380, width: '100%' }} />
          </div>

          {/* Tabla de cuadrantes */}
          <div className="card" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div className="card-title">Lista de cuadrantes ({quadrants.length})</div>
            </div>
            <div style={{ overflowX: 'auto' }}>
              <table className="incidents-table">
                <thead>
                  <tr>
                    <th style={{ width: 70 }}>ID</th>
                    <th>Nombre</th>
                    <th style={{ width: 90, textAlign: 'center' }}>Reportes</th>
                    <th style={{ width: 90, textAlign: 'center' }}>Activos</th>
                    <th style={{ width: 80, textAlign: 'center' }}>Radio</th>
                    <th style={{ width: 72 }}></th>
                  </tr>
                </thead>
                <tbody>
                  {quadrants.map(q => (
                    <tr key={q.id}>
                      <td>
                        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                          <span style={{ width: 10, height: 10, borderRadius: '50%', background: q.color, flexShrink: 0 }} />
                          <span style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: '0.75rem', color: 'var(--color-primary)' }}>{q.id}</span>
                        </span>
                      </td>
                      <td>
                        <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-navy)' }}>{q.nombre}</div>
                        {q.descripcion && (
                          <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', marginTop: 1 }}>{q.descripcion}</div>
                        )}
                      </td>
                      <td style={{ textAlign: 'center' }}>
                        <span style={{ fontWeight: 700, fontSize: '0.875rem', color: 'var(--color-navy)' }}>{contarReportes(q.id)}</span>
                      </td>
                      <td style={{ textAlign: 'center' }}>
                        <span style={{
                          fontWeight: 700, fontSize: '0.75rem',
                          color: contarActivos(q.id) > 0 ? 'var(--color-warning)' : 'var(--color-text-muted)',
                        }}>
                          {contarActivos(q.id)}
                        </span>
                      </td>
                      <td style={{ textAlign: 'center', fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>
                        {q.radio}m
                      </td>
                      <td>
                        <div style={{ display: 'flex', gap: 4, justifyContent: 'flex-end' }}>
                          <button
                            className="btn btn-ghost btn-icon"
                            title="Editar"
                            onClick={() => { setEditando(q); setModo('editar'); }}
                          >
                            <IconLocation size={12} />
                          </button>
                          <button
                            className="btn btn-ghost btn-icon"
                            title="Eliminar"
                            onClick={() => handleEliminar(q)}
                            style={{ color: 'var(--color-danger)' }}
                          >
                            <IconX size={12} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Columna derecha: formulario */}
        {modo ? (
          <div className="card" style={{ padding: 20 }}>
            <FormCuadrante
              cuadrante={modo === 'editar' ? editando : null}
              onGuardar={handleGuardar}
              onCancelar={() => { setModo(null); setEditando(null); }}
            />
          </div>
        ) : (
          <div className="card" style={{ padding: 20 }}>
            <div style={{ textAlign: 'center', padding: '20px 0' }}>
              <div style={{ marginBottom: 16 }}>
                <div style={{ width: 48, height: 48, borderRadius: '50%', background: 'var(--color-primary)', opacity: 0.1, margin: '0 auto 12px' }} />
                <IconLocation size={24} style={{ color: 'var(--color-primary)', opacity: 0.5 }} />
              </div>
              <div style={{ fontWeight: 700, fontSize: '0.9375rem', color: 'var(--color-navy)', marginBottom: 8 }}>
                Administra los cuadrantes
              </div>
              <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', lineHeight: 1.6, marginBottom: 20 }}>
                Haz clic en "Nuevo cuadrante" para agregar un sector, o selecciona uno de la tabla para editarlo.
              </div>
              <button className="btn btn-primary" style={{ width: '100%' }} onClick={() => setModo('crear')}>
                <IconLocation size={13} />
                Crear primer cuadrante
              </button>
            </div>
          </div>
        )}
      </div>
    </>
  );
}

