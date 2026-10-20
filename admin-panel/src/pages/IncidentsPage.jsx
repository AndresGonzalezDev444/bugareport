import { useState } from 'react';
import IncidentTable from '../components/incidents/IncidentTable.jsx';
import IncidentDrawer from '../components/incidents/IncidentDrawer.jsx';
import { IconList, IconRefresh } from '../components/ui/Icons.jsx';

export default function IncidentsPage({ incidents, loading, updateStatus, refetch }) {
  const [selected, setSelected] = useState(null);

  return (
    <>
      {/* Sub-header */}
      <div className="page-sub-header">
        <div className="page-heading">
          <h1>Gestión de Incidentes</h1>
          <div className="page-heading-sub">
            Administra, valida y asigna los reportes ciudadanos recibidos
          </div>
        </div>
        <div className="page-actions">
          <button className="btn btn-outline" onClick={refetch} disabled={loading}>
            <IconRefresh size={13} />
            Actualizar
          </button>
        </div>
      </div>

      <div className="page-content">
        {loading ? (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 60 }}>
            <span className="loading-spinner" />
          </div>
        ) : (
          <IncidentTable incidents={incidents} onSelectIncident={setSelected} />
        )}
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
