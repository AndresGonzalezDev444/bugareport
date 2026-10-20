// Helpers de estado, categoría y severidad para el panel admin

export const STATUS_LABELS = {
  pendiente:   'Pendiente',
  en_proceso:  'En proceso',
  resuelto:    'Resuelto',
};

export const STATUS_CLASS = {
  pendiente:   'badge-pendiente',
  en_proceso:  'badge-en_proceso',
  resuelto:    'badge-resuelto',
};

export const SEVERITY_LABELS = {
  critico: 'Crítico',
  alta:    'Alta',
  media:   'Media',
  baja:    'Baja',
};

export const SEVERITY_CLASS = {
  critico: 'badge-critico',
  alta:    'badge-alta',
  media:   'badge-media',
  baja:    'badge-baja',
};

export const CATEGORY_LABELS = {
  hueco_via:          'Hueco / Vía',
  servicios_publicos: 'Serv. Públicos',
  comunitario:        'Comunitario',
  aseo_parques:       'Aseo y Parques',
};

export const CATEGORY_CLASS = {
  hueco_via:          'badge-cat-hueco',
  servicios_publicos: 'badge-cat-servicios',
  comunitario:        'badge-cat-comunitario',
  aseo_parques:       'badge-cat-aseo',
};

export const CATEGORY_COLOR = {
  hueco_via:          '#7A1E23',
  servicios_publicos: '#2B5C8F',
  comunitario:        '#4B4ECC',
  aseo_parques:       '#2E5D4B',
};

export const SEVERITY_COLOR = {
  critico: '#7A1E23',
  alta:    '#86521B',
  media:   '#2B5C8F',
  baja:    '#2E5D4B',
};

export const STATUS_COLOR = {
  pendiente:  '#86521B',
  en_proceso: '#2B5C8F',
  resuelto:   '#003223',
};

export function timeAgo(dateStr) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins  = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days  = Math.floor(diff / 86400000);
  if (mins < 1)  return 'Ahora';
  if (mins < 60) return `Hace ${mins} min`;
  if (hours < 24) return `Hace ${hours}h`;
  if (days < 7)   return `Hace ${days}d`;
  const d = new Date(dateStr);
  return `${d.getDate()}/${d.getMonth()+1}/${d.getFullYear()}`;
}

export function formatDate(dateStr) {
  if (!dateStr) return '—';
  const d = new Date(dateStr);
  return d.toLocaleDateString('es-CO', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

export function formatDateTime(dateStr) {
  if (!dateStr) return '—';
  const d = new Date(dateStr);
  return d.toLocaleString('es-CO', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

export function incidentId(id) {
  if (!id) return 'REP-????';
  return 'REP-' + id.slice(0, 4).toUpperCase();
}
