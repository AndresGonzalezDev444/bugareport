import { useState } from 'react';
import IncidentTable from '../components/incidents/IncidentTable.jsx';
import IncidentDrawer from '../components/incidents/IncidentDrawer.jsx';
import { IconRefresh } from '../components/ui/Icons.jsx';

export default function IncidentsPage({ incidents, loading, updateStatus, updateQuadrant, refetch }) {
  const [selected, setSelected] = useState(null);

  // Sincronizar el incidente seleccionado con los datos actualizados en tiempo real
  const selectedFresh = selected
    ? incidents.find(i => i.id === selected.id) || selected
    : null;

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

      {selectedFresh && (
        <IncidentDrawer
          incident={selectedFresh}
          onClose={() => setSelected(null)}
          onUpdateStatus={updateStatus}
          onUpdateQuadrant={updateQuadrant}
        />
      )}
    </>
  );
}
