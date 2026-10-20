import { useState } from 'react';
import MapConsole from '../components/map/MapConsole.jsx';
import IncidentDrawer from '../components/incidents/IncidentDrawer.jsx';
import { IconRefresh } from '../components/ui/Icons.jsx';

export default function MapPage({ incidents, loading, updateStatus }) {
  const [selected, setSelected] = useState(null);
  const [filter,   setFilter]   = useState('Cuadrantes');

  const layers = ['Cuadrantes', 'Calor', 'Marcadores'];

  return (
    <>
      <div className="page-sub-header">
        <div className="page-heading">
          <h1>Mapa en vivo — Cuadrantes Urbanos</h1>
          <div className="page-heading-sub">Guadalajara de Buga · Q-01 a Q-14 · Vista operativa</div>
        </div>
        <div className="page-actions">
          <div className="filter-tabs">
            {layers.map(l => (
              <button key={l} className={`filter-tab${filter === l ? ' active' : ''}`} onClick={() => setFilter(l)}>
                {l}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="page-content" style={{ gap: 0, padding: 0, flex: 1 }}>
        <div style={{ flex: 1, position: 'relative' }}>
          {loading ? (
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 600 }}>
              <span className="loading-spinner" />
            </div>
          ) : (
            <MapConsole
              incidents={incidents}
              onSelectIncident={setSelected}
              style={{ height: 'calc(100vh - 130px)', borderRadius: 0 }}
            />
          )}
        </div>
      </div>

      {selected && (
        <IncidentDrawer
          incident={selected}
          onClose={() => setSelected(null)}
          onUpdateStatus={updateStatus}
        />
      )}
    </>
  );
}
