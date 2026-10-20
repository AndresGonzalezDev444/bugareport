import { STATUS_LABELS, STATUS_CLASS, SEVERITY_LABELS, SEVERITY_CLASS, CATEGORY_LABELS, CATEGORY_CLASS } from '../../utils/statusHelpers.js';

export function StatusBadge({ status }) {
  return (
    <span className={`badge ${STATUS_CLASS[status] || 'badge-pendiente'}`}>
      {STATUS_LABELS[status] || status}
    </span>
  );
}

export function SeverityBadge({ severity }) {
  return (
    <span className={`badge ${SEVERITY_CLASS[severity] || 'badge-media'}`}>
      {SEVERITY_LABELS[severity] || severity}
    </span>
  );
}

export function CategoryBadge({ category }) {
  return (
    <span className={`badge ${CATEGORY_CLASS[category] || 'badge-cat-hueco'}`}>
      {CATEGORY_LABELS[category] || category}
    </span>
  );
}
