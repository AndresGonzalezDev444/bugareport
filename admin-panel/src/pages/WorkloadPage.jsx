// pages/WorkloadPage.jsx
// HU5 - Control de carga de trabajo del personal con CRUD completo

import { useMemo, useState } from 'react';
import { IconSquad, IconAlert, IconX, IconCheck, IconUser } from '../components/ui/Icons.jsx';

function BarraCarga({ valor, maximo }) {
  const pct = maximo > 0 ? Math.round((valor / maximo) * 100) : 0;
  const color =
    pct >= 80 ? '#BA1A1A' :
    pct >= 50 ? '#86521B' :
    'var(--color-success)';

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, flex: 1 }}>
      <div style={{
        flex: 1, height: 6, background: 'var(--border-soft)', borderRadius: 3, overflow: 'hidden',
      }}>
        <div style={{
          height: '100%', width: `${pct}%`, background: color,
          borderRadius: 3, transition: 'width 300ms ease',
        }} />
      </div>
      <span style={{ fontSize: '0.6875rem', fontWeight: 700, color, minWidth: 28, textAlign: 'right' }}>
        {pct}%
      </span>
    </div>
  );
}

const CARGOS_DISPONIBLES = [
  'Ingeniero Civil',
  'Ingeniero de Redes',
  'Tecnico de Campo',
  'Inspector Municipal',
  'Supervisor de Cuadrilla',
  'Gestor Social',
  'Operario de Maquinaria',
  'Coordinador de Zona',
  'Asistente Administrativo',
];

const ESPECIALIDADES = [
  'Vias y Pavimento',
  'Servicios Publicos',
  'Bacheo y Reparacion',
  'Control Comunitario',
  'Aseo Urbano y Parques',
  'Atencion Ciudadana',
  'Equipo Pesado',
  'Logistica y Despacho',
  'Redes Electricas',
  'Acueducto y Alcantarillado',
];

const FORM_VACIO = { nombre: '', cargo: '', especialidad: '', telefono: '' };

export default function WorkloadPage({ staff, assignments, agregarStaff, desactivarStaff, actualizarStaff }) {
  const [modalAbierto, setModalAbierto] = useState(false);
  const [editando, setEditando]         = useState(null); // null = nuevo, objeto = editar
  const [form, setForm]                 = useState(FORM_VACIO);
  const [errForm, setErrForm]           = useState('');
  const [confirmDelete, setConfirmDelete] = useState(null); // id del miembro a eliminar

  // Calcular carga por miembro usando el assignments del store
  const cargas = useMemo(() => {
    // assignments = { [incidentId]: [{ staffId, assignedAt }] }
    const totalPorStaff = {};
    Object.values(assignments || {}).forEach(asigs => {
      asigs.forEach(a => {
        totalPorStaff[a.staffId] = (totalPorStaff[a.staffId] || 0) + 1;
      });
    });

    return staff
      .filter(s => s.activo)
      .map(miembro => ({
        miembro,
        totalAsignados: totalPorStaff[miembro.id] || 0,
      }))
      .sort((a, b) => b.totalAsignados - a.totalAsignados);
  }, [staff, assignments]);

  const maxCarga          = cargas.reduce((m, c) => Math.max(m, c.totalAsignados), 0);
  const totalAsignaciones = cargas.reduce((s, c) => s + c.totalAsignados, 0);
  const staffActivo       = staff.filter(s => s.activo).length;

  // ── CRUD ──────────────────────────────────────────────────────
  function abrirNuevo() {
    setEditando(null);
    setForm(FORM_VACIO);
    setErrForm('');
    setModalAbierto(true);
  }

  function abrirEditar(miembro) {
    setEditando(miembro);
    setForm({
      nombre:       miembro.nombre       || '',
      cargo:        miembro.cargo        || '',
      especialidad: miembro.especialidad || '',
      telefono:     miembro.telefono     || '',
    });
    setErrForm('');
    setModalAbierto(true);
  }

  function cerrarModal() {
    setModalAbierto(false);
    setEditando(null);
    setErrForm('');
  }

  function handleGuardar() {
    if (!form.nombre.trim()) { setErrForm('El nombre es obligatorio.'); return; }
    if (!form.cargo.trim())  { setErrForm('El cargo es obligatorio.');  return; }

    if (editando) {
      actualizarStaff?.(editando.id, { ...form, nombre: form.nombre.trim() });
    } else {
      agregarStaff?.({ ...form, nombre: form.nombre.trim() });
    }
    cerrarModal();
  }

  function handleEliminar(id) {
    desactivarStaff?.(id);
    setConfirmDelete(null);
  }

  return (
    <>
      <div className="page-sub-header">
        <div className="page-heading">
          <h1>Control de Personal</h1>
          <div className="page-heading-sub">Carga de trabajo y gestion del equipo municipal</div>
        </div>
        <div className="page-actions">
          <button className="btn btn-primary" onClick={abrirNuevo}>
            <IconSquad size={13} />
            Agregar miembro
          </button>
        </div>
      </div>

      <div className="page-content">

        {/* KPIs */}
        <div className="kpi-grid" style={{ gridTemplateColumns: 'repeat(3, 1fr)', marginBottom: 20 }}>
          <div className="kpi-card">
            <div className="kpi-card-top">
              <span className="kpi-label">Personal activo</span>
              <IconSquad size={16} style={{ color: 'var(--color-navy)', opacity: 0.4 }} />
            </div>
            <span className="kpi-value">{staffActivo}</span>
            <div className="kpi-sub">{staff.length} en total ({staff.length - staffActivo} inactivos)</div>
          </div>

          <div className="kpi-card">
            <div className="kpi-card-top">
              <span className="kpi-label">Total asignaciones</span>
            </div>
            <span className="kpi-value">{totalAsignaciones}</span>
            <div className="kpi-sub">Reportes con responsable asignado</div>
          </div>

          <div className="kpi-card">
            <div className="kpi-card-top">
              <span className="kpi-label">Mayor carga</span>
              <IconAlert size={14} style={{ color: maxCarga > 5 ? '#BA1A1A' : 'var(--color-text-muted)' }} />
            </div>
            <span className="kpi-value">{cargas[0]?.miembro.nombre.split(' ')[0] || '—'}</span>
            <div className="kpi-sub">
              {cargas[0]?.totalAsignados > 0
                ? `${cargas[0].totalAsignados} reportes asignados`
                : 'Sin asignaciones aun'}
            </div>
          </div>
        </div>

        {/* Tabla de personal con carga */}
        <div className="card" style={{ overflow: 'hidden', marginBottom: 16 }}>
          <div className="card-header">
            <div>
              <div className="card-title">Carga de trabajo por miembro</div>
              <div className="card-subtitle">Las asignaciones se hacen desde el drawer de cada incidente</div>
            </div>
          </div>

          {cargas.length === 0 ? (
            <div className="empty-state" style={{ padding: 48 }}>
              <IconSquad size={32} className="empty-state-icon" />
              <div className="empty-state-title">Sin personal activo</div>
              <div className="empty-state-sub">Agrega miembros usando el boton superior</div>
            </div>
          ) : (
            <div>
              {cargas.map(({ miembro, totalAsignados }) => (
                <div
                  key={miembro.id}
                  style={{
                    display: 'grid',
                    gridTemplateColumns: '220px 1fr 60px 72px',
                    alignItems: 'center',
                    gap: 20,
                    padding: '14px 20px',
                    borderBottom: '1px solid var(--border-soft)',
                  }}
                >
                  {/* Info del miembro */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <div style={{
                      width: 36, height: 36, borderRadius: '50%',
                      background: 'var(--color-navy)',
                      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                    }}>
                      <span style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '0.75rem', color: 'white' }}>
                        {miembro.nombre.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                      </span>
                    </div>
                    <div>
                      <div style={{ fontWeight: 700, fontSize: '0.8125rem', color: 'var(--color-navy)' }}>
                        {miembro.nombre}
                      </div>
                      <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>
                        {miembro.cargo}
                      </div>
                      {miembro.especialidad && (
                        <div style={{ fontSize: '0.5625rem', color: 'var(--color-text-muted)', fontStyle: 'italic', marginTop: 1 }}>
                          {miembro.especialidad}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Barra de carga */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                    <BarraCarga valor={totalAsignados} maximo={Math.max(maxCarga, 1)} />
                    <div style={{ fontSize: '0.5625rem', color: 'var(--color-text-muted)' }}>
                      {totalAsignados === 0
                        ? 'Sin reportes asignados'
                        : `${totalAsignados} asignacion${totalAsignados > 1 ? 'es' : ''} activa${totalAsignados > 1 ? 's' : ''}`
                      }
                    </div>
                  </div>

                  {/* Contador */}
                  <div style={{ textAlign: 'center' }}>
                    <span style={{
                      fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1.25rem',
                      color: totalAsignados === 0 ? 'var(--color-text-muted)'
                        : totalAsignados >= maxCarga && maxCarga > 0 ? '#BA1A1A'
                        : 'var(--color-navy)',
                    }}>
                      {totalAsignados}
                    </span>
                    <div style={{ fontSize: '0.5625rem', color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                      reportes
                    </div>
                  </div>

                  {/* Acciones */}
                  <div style={{ display: 'flex', gap: 6, justifyContent: 'flex-end' }}>
                    <button
                      className="btn btn-ghost btn-icon"
                      title="Editar miembro"
                      onClick={() => abrirEditar(miembro)}
                    >
                      <IconUser size={13} />
                    </button>
                    <button
                      className="btn btn-ghost btn-icon"
                      title="Desactivar miembro"
                      onClick={() => setConfirmDelete(miembro.id)}
                      style={{ color: 'var(--color-danger)' }}
                    >
                      <IconX size={13} />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Personal inactivo */}
        {staff.filter(s => !s.activo).length > 0 && (
          <div className="card" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div>
                <div className="card-title">Personal inactivo</div>
                <div className="card-subtitle">Miembros desactivados — no aparecen en asignaciones</div>
              </div>
            </div>
            <div>
              {staff.filter(s => !s.activo).map(miembro => (
                <div key={miembro.id} style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  padding: '10px 20px', borderBottom: '1px solid var(--border-soft)',
                  opacity: 0.6,
                }}>
                  <div>
                    <span style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-text-dark)' }}>
                      {miembro.nombre}
                    </span>
                    <span style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', marginLeft: 8 }}>
                      {miembro.cargo}
                    </span>
                  </div>
                  <button
                    className="btn btn-outline"
                    style={{ fontSize: '0.75rem', padding: '4px 10px' }}
                    onClick={() => actualizarStaff?.(miembro.id, { activo: true })}
                  >
                    Reactivar
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* ── Modal CRUD ── */}
      {modalAbierto && (
        <>
          <div
            className="drawer-overlay"
            onClick={cerrarModal}
            style={{ zIndex: 900 }}
          />
          <div style={{
            position: 'fixed', top: '50%', left: '50%',
            transform: 'translate(-50%, -50%)',
            width: 460, background: 'var(--bg-card)',
            borderRadius: 'var(--radius-lg)',
            border: '1px solid var(--border-medium)',
            boxShadow: '0 16px 48px rgba(0,0,0,0.22)',
            zIndex: 1000, padding: 28,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
              <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1rem', color: 'var(--color-navy)' }}>
                {editando ? 'Editar miembro del personal' : 'Agregar nuevo miembro'}
              </div>
              <button className="btn btn-ghost btn-icon" onClick={cerrarModal}>
                <IconX size={14} />
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              {/* Nombre */}
              <div>
                <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 6 }}>
                  Nombre completo *
                </label>
                <input
                  type="text"
                  value={form.nombre}
                  onChange={e => setForm(f => ({ ...f, nombre: e.target.value }))}
                  placeholder="Ej. Carlos Restrepo"
                  style={{
                    width: '100%', boxSizing: 'border-box',
                    padding: '8px 12px', fontSize: '0.875rem',
                    border: '1px solid var(--border-medium)',
                    borderRadius: 'var(--radius-sm)',
                    background: 'var(--bg-input, var(--bg-header))',
                    color: 'var(--color-text-dark)',
                    outline: 'none',
                    fontFamily: 'Inter, sans-serif',
                  }}
                />
              </div>

              {/* Cargo */}
              <div>
                <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 6 }}>
                  Cargo *
                </label>
                <select
                  value={form.cargo}
                  onChange={e => setForm(f => ({ ...f, cargo: e.target.value }))}
                  className="select-filter"
                  style={{ width: '100%', fontSize: '0.875rem', padding: '8px 12px' }}
                >
                  <option value="">Seleccionar cargo...</option>
                  {CARGOS_DISPONIBLES.map(c => <option key={c} value={c}>{c}</option>)}
                </select>
              </div>

              {/* Especialidad */}
              <div>
                <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 6 }}>
                  Especialidad
                </label>
                <select
                  value={form.especialidad}
                  onChange={e => setForm(f => ({ ...f, especialidad: e.target.value }))}
                  className="select-filter"
                  style={{ width: '100%', fontSize: '0.875rem', padding: '8px 12px' }}
                >
                  <option value="">Seleccionar especialidad...</option>
                  {ESPECIALIDADES.map(e => <option key={e} value={e}>{e}</option>)}
                </select>
              </div>

              {/* Telefono */}
              <div>
                <label style={{ display: 'block', fontSize: '0.6875rem', fontWeight: 700, color: 'var(--color-text-muted)', textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: 6 }}>
                  Telefono / Celular
                </label>
                <input
                  type="tel"
                  value={form.telefono}
                  onChange={e => setForm(f => ({ ...f, telefono: e.target.value }))}
                  placeholder="Ej. 311 234 5678"
                  style={{
                    width: '100%', boxSizing: 'border-box',
                    padding: '8px 12px', fontSize: '0.875rem',
                    border: '1px solid var(--border-medium)',
                    borderRadius: 'var(--radius-sm)',
                    background: 'var(--bg-input, var(--bg-header))',
                    color: 'var(--color-text-dark)',
                    outline: 'none',
                    fontFamily: 'Inter, sans-serif',
                  }}
                />
              </div>

              {/* Error */}
              {errForm && (
                <div style={{ fontSize: '0.75rem', color: 'var(--color-danger)', fontWeight: 600 }}>
                  {errForm}
                </div>
              )}
            </div>

            {/* Botones */}
            <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 24 }}>
              <button className="btn btn-ghost" onClick={cerrarModal}>
                Cancelar
              </button>
              <button className="btn btn-primary" onClick={handleGuardar}>
                <IconCheck size={13} />
                {editando ? 'Guardar cambios' : 'Agregar miembro'}
              </button>
            </div>
          </div>
        </>
      )}

      {/* ── Confirmacion de desactivacion ── */}
      {confirmDelete && (
        <>
          <div className="drawer-overlay" onClick={() => setConfirmDelete(null)} style={{ zIndex: 900 }} />
          <div style={{
            position: 'fixed', top: '50%', left: '50%',
            transform: 'translate(-50%, -50%)',
            width: 360, background: 'var(--bg-card)',
            borderRadius: 'var(--radius-lg)',
            border: '1px solid var(--border-medium)',
            boxShadow: '0 16px 48px rgba(0,0,0,0.22)',
            zIndex: 1000, padding: 24,
            textAlign: 'center',
          }}>
            <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '0.9375rem', color: 'var(--color-navy)', marginBottom: 10 }}>
              Desactivar miembro
            </div>
            <div style={{ fontSize: '0.8125rem', color: 'var(--color-text-muted)', marginBottom: 20, lineHeight: 1.6 }}>
              El miembro no aparecera en nuevas asignaciones. Las asignaciones existentes se mantienen.
              Esta accion se puede revertir desde la seccion de personal inactivo.
            </div>
            <div style={{ display: 'flex', gap: 10, justifyContent: 'center' }}>
              <button className="btn btn-ghost" onClick={() => setConfirmDelete(null)}>Cancelar</button>
              <button className="btn btn-danger" onClick={() => handleEliminar(confirmDelete)}>
                Desactivar
              </button>
            </div>
          </div>
        </>
      )}
    </>
  );
}
