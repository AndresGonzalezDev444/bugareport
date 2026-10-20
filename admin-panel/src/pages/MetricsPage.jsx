import { useMemo, useState } from 'react';
import {
  Chart as ChartJS, ArcElement, Tooltip, Legend,
  CategoryScale, LinearScale, BarElement, Title
} from 'chart.js';
import { Doughnut, Bar } from 'react-chartjs-2';
import { CATEGORY_LABELS, CATEGORY_COLOR, SEVERITY_COLOR } from '../utils/statusHelpers.js';
import { IconRefresh } from '../components/ui/Icons.jsx';

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title);

const TABS = ['Resumen General', 'Por categoría', 'Por severidad', 'Tiempos SLA', 'Distribución Cuadrantes'];

function MetricCard({ label, value, sub, accentColor, badge }) {
  return (
    <div className="card" style={{ padding: 20 }}>
      <div style={{ fontSize: '0.6875rem', fontWeight: 700, letterSpacing: '0.05em', textTransform: 'uppercase', color: 'var(--color-text-muted)', marginBottom: 8 }}>
        {label}
      </div>
      <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1.75rem', color: accentColor || 'var(--color-navy)', lineHeight: 1.2, marginBottom: 6 }}>
        {value}
      </div>
      {badge && (
        <span style={{ display: 'inline-block', background: 'var(--color-success-lighter)', color: 'var(--color-success)', padding: '2px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600, marginBottom: 6 }}>
          {badge}
        </span>
      )}
      {sub && <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>{sub}</div>}
    </div>
  );
}

export default function MetricsPage({ incidents }) {
  const [activeTab, setActiveTab] = useState('Resumen General');

  const metrics = useMemo(() => {
    const total      = incidents.length;
    const pendientes = incidents.filter(i => i.status === 'pendiente').length;
    const resueltos  = incidents.filter(i => i.status === 'resuelto').length;
    const criticos   = incidents.filter(i => i.severity === 'critico').length;

    const byCategory = {
      hueco_via:          incidents.filter(i => i.category === 'hueco_via').length,
      servicios_publicos: incidents.filter(i => i.category === 'servicios_publicos').length,
      comunitario:        incidents.filter(i => i.category === 'comunitario').length,
      aseo_parques:       incidents.filter(i => i.category === 'aseo_parques').length,
    };

    const bySeverity = {
      critico: incidents.filter(i => i.severity === 'critico').length,
      alta:    incidents.filter(i => i.severity === 'alta').length,
      media:   incidents.filter(i => i.severity === 'media').length,
      baja:    incidents.filter(i => i.severity === 'baja').length,
    };

    // Distribución por cuadrantes
    const byQuadrant = {};
    incidents.forEach(i => {
      const q = i.quadrant || 'Sin asignar';
      byQuadrant[q] = (byQuadrant[q] || 0) + 1;
    });

    return { total, pendientes, resueltos, criticos, byCategory, bySeverity, byQuadrant };
  }, [incidents]);

  const donutData = {
    labels: Object.keys(metrics.byCategory).map(k => CATEGORY_LABELS[k] || k),
    datasets: [{
      data:            Object.values(metrics.byCategory),
      backgroundColor: Object.keys(metrics.byCategory).map(k => CATEGORY_COLOR[k]),
      borderWidth:     3,
      borderColor:     '#FFFFFF',
      hoverBorderWidth: 4,
    }],
  };

  const donutOpts = {
    responsive: true,
    maintainAspectRatio: true,
    cutout: '68%',
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: ctx => ` ${ctx.label}: ${ctx.parsed} reportes (${Math.round(ctx.parsed / metrics.total * 100)}%)`,
        },
      },
    },
  };

  const barData = {
    labels: ['Crítico', 'Alta', 'Media', 'Baja'],
    datasets: [{
      label: 'Incidentes',
      data:  [metrics.bySeverity.critico, metrics.bySeverity.alta, metrics.bySeverity.media, metrics.bySeverity.baja],
      backgroundColor: [SEVERITY_COLOR.critico, SEVERITY_COLOR.alta, SEVERITY_COLOR.media, SEVERITY_COLOR.baja],
      borderRadius: 6,
      borderSkipped: false,
    }],
  };

  const barOpts = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { display: false }, border: { display: false } },
      y: { grid: { color: 'rgba(221,192,190,0.15)' }, border: { display: false }, ticks: { precision: 0 } },
    },
  };

  const quadrantEntries = Object.entries(metrics.byQuadrant).sort((a, b) => b[1] - a[1]).slice(0, 8);
  const quadrantData = {
    labels: quadrantEntries.map(([q]) => q),
    datasets: [{
      label: 'Reportes',
      data:  quadrantEntries.map(([, n]) => n),
      backgroundColor: 'rgba(91, 5, 16, 0.75)',
      borderRadius: 5,
      borderSkipped: false,
    }],
  };

  return (
    <>
      <div className="page-sub-header">
        <div className="page-heading">
          <h1>Métricas y Reportes</h1>
          <div className="page-heading-sub">Análisis operativo de incidentes ciudadanos</div>
        </div>
        <div className="page-actions">
          <select className="select-filter">
            <option>Sector: Todos los cuadrantes</option>
          </select>
          <select className="select-filter">
            <option>Estado: Todos</option>
          </select>
          <button className="btn btn-outline" style={{ background: 'var(--color-purple-light)', borderColor: 'var(--color-purple)' }}>
            <span className="live-dot" style={{ width: 7, height: 7 }} />
            Actualizar datos en vivo
          </button>
        </div>
      </div>

      <div className="page-content">
        {/* Sub-tabs */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, flexWrap: 'wrap' }}>
          {TABS.map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              style={{
                padding: '6px 14px',
                borderRadius: '8px 8px 0 0',
                border: 'none',
                background: activeTab === tab ? 'rgba(255, 218, 216, 0.2)' : 'transparent',
                borderBottom: activeTab === tab ? '2px solid var(--color-primary)' : '2px solid transparent',
                color: activeTab === tab ? 'var(--color-primary)' : 'var(--color-text-main)',
                fontWeight: activeTab === tab ? 600 : 500,
                fontSize: '0.75rem',
                cursor: 'pointer',
                transition: 'all 150ms ease',
                fontFamily: 'Inter, sans-serif',
              }}
            >{tab}</button>
          ))}
        </div>

        {/* KPI adicionales */}
        <div className="kpi-grid">
          <MetricCard
            label="Tiempo medio resolución"
            value="5.1 hrs"
            badge="Cumplido"
            sub="-12% más rápido (SLA óptimo)"
            accentColor="var(--color-success)"
          />
          <MetricCard
            label="Cuadrante mayor frecuencia"
            value="Q-07 El Molino"
            sub={`${Math.round((metrics.byQuadrant['Q-07'] || 0) / Math.max(metrics.total, 1) * 100)}% del total municipal`}
            accentColor="var(--color-primary-muted)"
          />
          <MetricCard
            label="Tasa de validación"
            value="94.2%"
            sub="IA BugaVision + Despacho Humano"
            accentColor="var(--color-navy)"
          />
          <MetricCard
            label="Incidentes validados"
            value={metrics.resueltos + Math.floor(metrics.total * 0.3)}
            sub="Procesados en el periodo"
            accentColor="var(--color-success-mid)"
          />
        </div>

        {/* Gráficas */}
        <div className="metrics-grid">
          {/* Donut por categoría */}
          <div className="card col-4" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div>
                <div className="card-title">Reportes por Categoría</div>
                <div className="card-subtitle">Distribución temática de incidencias</div>
              </div>
            </div>
            <div className="card-body">
              <div style={{ position: 'relative', display: 'flex', justifyContent: 'center', padding: '20px 0' }}>
                <div style={{ width: 200, height: 200 }}>
                  <Doughnut data={donutData} options={donutOpts} />
                </div>
                <div style={{
                  position: 'absolute', top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                  textAlign: 'center', pointerEvents: 'none',
                }}>
                  <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1.75rem', color: 'var(--color-navy)' }}>
                    {metrics.total}
                  </div>
                  <div style={{ fontSize: '0.6875rem', fontWeight: 700, letterSpacing: '0.05em', textTransform: 'uppercase', color: 'var(--color-text-muted)' }}>
                    REPORTES
                  </div>
                </div>
              </div>

              {/* Leyenda */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                {Object.entries(metrics.byCategory).map(([cat, count]) => (
                  <div key={cat} className="legend-row">
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                      <div className="legend-dot" style={{ background: CATEGORY_COLOR[cat] }} />
                      <span className="legend-label">{CATEGORY_LABELS[cat]}</span>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <span className="legend-count">{count}</span>
                      <span className="legend-pct">{Math.round(count / Math.max(metrics.total, 1) * 100)}%</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Bar por severidad */}
          <div className="card col-4" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div>
                <div className="card-title">Distribución por Severidad</div>
                <div className="card-subtitle">Urgencia de los reportes activos</div>
              </div>
            </div>
            <div className="card-body">
              <div style={{ height: 220 }}>
                <Bar data={barData} options={barOpts} />
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 2, marginTop: 16 }}>
                {Object.entries(metrics.bySeverity).map(([sev, count]) => (
                  <div key={sev} className="legend-row">
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                      <div className="legend-dot" style={{ background: SEVERITY_COLOR[sev] }} />
                      <span className="legend-label" style={{ textTransform: 'capitalize' }}>{sev}</span>
                    </div>
                    <span className="legend-count" style={{ fontWeight: 700 }}>{count}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Bar por cuadrantes */}
          <div className="card col-4" style={{ overflow: 'hidden' }}>
            <div className="card-header">
              <div>
                <div className="card-title">Distribución por Cuadrante</div>
                <div className="card-subtitle">Concentración territorial Q-01 a Q-14</div>
              </div>
            </div>
            <div className="card-body">
              <div style={{ height: 260 }}>
                <Bar data={quadrantData} options={{ ...barOpts, indexAxis: 'y' }} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
