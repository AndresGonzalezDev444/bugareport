import { useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { CATEGORY_COLOR, SEVERITY_COLOR, CATEGORY_LABELS, STATUS_LABELS, timeAgo } from '../../utils/statusHelpers.js';

// Coordenadas centro de Guadalajara de Buga, Valle del Cauca
const BUGA_CENTER = [3.9001, -76.3000];
const DEFAULT_ZOOM = 14;

function createPinIcon(category, severity) {
  const color = severity === 'critico' || severity === 'alta'
    ? SEVERITY_COLOR[severity]
    : CATEGORY_COLOR[category] || '#7A1E23';

  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="36" viewBox="0 0 28 36">
      <path d="M14 2C8.48 2 4 6.48 4 12c0 7.5 10 22 10 22s10-14.5 10-22C24 6.48 19.52 2 14 2z"
        fill="${color}" stroke="white" stroke-width="2"/>
      <circle cx="14" cy="12" r="4.5" fill="white" opacity="0.85"/>
    </svg>
  `;

  return L.divIcon({
    html: svg,
    className: '',
    iconSize: [28, 36],
    iconAnchor: [14, 36],
    popupAnchor: [0, -38],
  });
}

export default function MapConsole({ incidents = [], onSelectIncident }) {
  const mapRef     = useRef(null);
  const mapInstance = useRef(null);
  const markersRef = useRef([]);

  useEffect(() => {
    if (mapInstance.current) return;

    mapInstance.current = L.map(mapRef.current, {
      center: BUGA_CENTER,
      zoom: DEFAULT_ZOOM,
      zoomControl: true,
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(mapInstance.current);

    // Etiqueta de la ciudad
    L.marker(BUGA_CENTER, {
      icon: L.divIcon({
        html: '<div style="background:rgba(19,26,54,0.75);color:white;padding:2px 8px;border-radius:4px;font-family:Inter,sans-serif;font-size:10px;font-weight:700;white-space:nowrap;letter-spacing:0.04em;">GUADALAJARA DE BUGA</div>',
        className: '',
        iconAnchor: [68, 10],
      }),
      interactive: false,
    }).addTo(mapInstance.current);

    return () => {
      mapInstance.current?.remove();
      mapInstance.current = null;
    };
  }, []);

  // Actualizar markers cuando cambian incidentes
  useEffect(() => {
    if (!mapInstance.current) return;

    // Limpiar markers anteriores
    markersRef.current.forEach(m => m.remove());
    markersRef.current = [];

    incidents.forEach(inc => {
      if (!inc.latitude || !inc.longitude) return;

      const icon   = createPinIcon(inc.category, inc.severity);
      const marker = L.marker([inc.latitude, inc.longitude], { icon });

      const popupContent = `
        <div class="pin-popup">
          <div class="pin-popup-title">${inc.title}</div>
          <div class="pin-popup-meta" style="margin-bottom:4px;">
            ${CATEGORY_LABELS[inc.category] || inc.category} · ${STATUS_LABELS[inc.status] || inc.status}
          </div>
          <div class="pin-popup-meta">${inc.quadrant || '—'} · ${timeAgo(inc.created_at)}</div>
        </div>
      `;

      marker.bindPopup(popupContent, { maxWidth: 220 });
      marker.on('click', () => onSelectIncident?.(inc));
      marker.addTo(mapInstance.current);
      markersRef.current.push(marker);
    });
  }, [incidents, onSelectIncident]);

  return (
    <div
      ref={mapRef}
      className="map-wrapper"
      style={{ height: '520px', width: '100%', borderRadius: '0 0 12px 12px' }}
    />
  );
}
