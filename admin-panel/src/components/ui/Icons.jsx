// Librería de iconos SVG inline — sin emojis en todo el panel
// Todos los iconos son vectores escalables con currentColor

export function IconDashboard({ size = 16, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="1" y="1" width="6" height="6" rx="1.5" fill="currentColor" opacity="0.9"/>
      <rect x="9" y="1" width="6" height="6" rx="1.5" fill="currentColor" opacity="0.5"/>
      <rect x="1" y="9" width="6" height="6" rx="1.5" fill="currentColor" opacity="0.5"/>
      <rect x="9" y="9" width="6" height="6" rx="1.5" fill="currentColor" opacity="0.7"/>
    </svg>
  );
}

export function IconMap({ size = 16, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M1 3.5L5.5 2L10.5 4L15 2.5V13L10.5 14.5L5.5 12.5L1 14V3.5Z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round" fill="none"/>
      <path d="M5.5 2V12.5M10.5 4V14.5" stroke="currentColor" strokeWidth="1.3"/>
    </svg>
  );
}

export function IconList({ size = 16, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="5" y="3" width="9" height="1.5" rx="0.75" fill="currentColor"/>
      <rect x="5" y="7.25" width="9" height="1.5" rx="0.75" fill="currentColor"/>
      <rect x="5" y="11.5" width="9" height="1.5" rx="0.75" fill="currentColor"/>
      <circle cx="2.5" cy="3.75" r="1" fill="currentColor"/>
      <circle cx="2.5" cy="8" r="1" fill="currentColor"/>
      <circle cx="2.5" cy="12.25" r="1" fill="currentColor"/>
    </svg>
  );
}

export function IconChart({ size = 16, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="1.5" y="8" width="3" height="6.5" rx="1" fill="currentColor" opacity="0.6"/>
      <rect x="6.5" y="5" width="3" height="9.5" rx="1" fill="currentColor" opacity="0.8"/>
      <rect x="11.5" y="2" width="3" height="12.5" rx="1" fill="currentColor"/>
    </svg>
  );
}

export function IconReport({ size = 16, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="2" y="1.5" width="9" height="13" rx="1.5" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <path d="M11 3.5H13a0.5 0.5 0 0 1 .5.5v10a0.5 0.5 0 0 1-.5.5H5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" fill="none"/>
      <path d="M4.5 5.5H9M4.5 8H9M4.5 10.5H7" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round"/>
    </svg>
  );
}

export function IconLogout({ size = 16, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M6 2H3a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h3" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" fill="none"/>
      <path d="M10.5 5.5L14 8l-3.5 2.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
      <path d="M14 8H6" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  );
}

export function IconSearch({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="6" cy="6" r="4.5" stroke="currentColor" strokeWidth="1.3"/>
      <path d="M9.5 9.5L13 13" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  );
}

export function IconFilter({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M1 2.5h12M3.5 7h7M5.5 11.5h3" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  );
}

export function IconLocation({ size = 12, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M6 1C4.07 1 2.5 2.57 2.5 4.5c0 2.625 3.5 6.5 3.5 6.5s3.5-3.875 3.5-6.5C9.5 2.57 7.93 1 6 1Z" stroke="currentColor" strokeWidth="1.2" fill="none"/>
      <circle cx="6" cy="4.5" r="1.2" fill="currentColor"/>
    </svg>
  );
}

export function IconClock({ size = 12, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="6" cy="6" r="4.5" stroke="currentColor" strokeWidth="1.2"/>
      <path d="M6 3.5V6l1.5 1.5" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round"/>
    </svg>
  );
}

export function IconClose({ size = 16, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M3 3l10 10M13 3L3 13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}

export function IconCheck({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M2 7l4 4 6-6" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

export function IconSend({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M1.5 7l11-5-5 11-1.5-4.5L1.5 7z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round" fill="none"/>
      <path d="M6 8.5L12.5 2" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  );
}

export function IconDownload({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M7 1v8M4 6.5l3 3 3-3" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M1.5 10v1.5a1 1 0 0 0 1 1h9a1 1 0 0 0 1-1V10" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  );
}

export function IconRefresh({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M12.5 2.5v3.5H9" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M12.5 6A5.5 5.5 0 1 1 9.3 2.2" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" fill="none"/>
    </svg>
  );
}

export function IconUser({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="7" cy="4.5" r="2.5" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <path d="M1.5 12.5c0-2.485 2.462-4.5 5.5-4.5s5.5 2.015 5.5 4.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" fill="none"/>
    </svg>
  );
}

export function IconLock({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="2.5" y="6" width="9" height="7" rx="1.5" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <path d="M4.5 6V4.5a2.5 2.5 0 0 1 5 0V6" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" fill="none"/>
      <circle cx="7" cy="9.5" r="1" fill="currentColor"/>
    </svg>
  );
}

export function IconEye({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M1 7s2-4.5 6-4.5S13 7 13 7s-2 4.5-6 4.5S1 7 1 7Z" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <circle cx="7" cy="7" r="1.7" stroke="currentColor" strokeWidth="1.2" fill="none"/>
    </svg>
  );
}

export function IconEyeOff({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M2 2l10 10M6 3a6 6 0 0 1 7 4 6.2 6.2 0 0 1-1.5 2.5M5.3 5.3A2 2 0 0 0 8.7 8.7" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
      <path d="M1 7s1.5-3 4.5-4M9.5 4.2A6 6 0 0 1 13 7c-.5 1.5-2 3.5-4.5 4" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  );
}

export function IconAlert({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M7 1.5L13 12.5H1L7 1.5Z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round" fill="none"/>
      <path d="M7 5.5V8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <circle cx="7" cy="10" r="0.7" fill="currentColor"/>
    </svg>
  );
}

export function IconCamera({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="1" y="3.5" width="12" height="9" rx="1.5" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <circle cx="7" cy="8" r="2" stroke="currentColor" strokeWidth="1.2" fill="none"/>
      <path d="M4.5 3.5l1-2h3l1 2" stroke="currentColor" strokeWidth="1.2" strokeLinejoin="round" fill="none"/>
    </svg>
  );
}

export function IconExif({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <rect x="1.5" y="1.5" width="11" height="11" rx="1.5" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <path d="M4 5h6M4 7.5h4M4 10h5" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round"/>
    </svg>
  );
}

export function IconLink({ size = 13, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 13 13" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M5 7.5a3 3 0 0 0 4.2.3l1.8-1.8A3 3 0 0 0 6.8 1.7L5.9 2.6" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" fill="none"/>
      <path d="M8 5.5a3 3 0 0 0-4.2-.3L2 7a3 3 0 0 0 4.2 4.2l.9-.9" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" fill="none"/>
    </svg>
  );
}

export function IconSquad({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="4" cy="3.5" r="1.8" stroke="currentColor" strokeWidth="1.2" fill="none"/>
      <circle cx="10" cy="3.5" r="1.8" stroke="currentColor" strokeWidth="1.2" fill="none"/>
      <path d="M1 12c0-1.65 1.35-3 3-3s3 1.35 3 3" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" fill="none"/>
      <path d="M7 12c0-1.65 1.35-3 3-3s3 1.35 3 3" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" fill="none"/>
    </svg>
  );
}

export function IconBell({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M7 1.5A3.5 3.5 0 0 0 3.5 5v2.5L2 9h10l-1.5-1.5V5A3.5 3.5 0 0 0 7 1.5Z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round" fill="none"/>
      <path d="M5.5 9v.5a1.5 1.5 0 0 0 3 0V9" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" fill="none"/>
    </svg>
  );
}

export function IconSettings({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="7" cy="7" r="2" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <path d="M7 1.5v1.2M7 11.3v1.2M1.5 7h1.2M11.3 7h1.2M3.3 3.3l.85.85M9.85 9.85l.85.85M3.3 10.7l.85-.85M9.85 4.15l.85-.85" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  );
}

export function IconChevronRight({ size = 8, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 8 8" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M2 1.5l3 2.5-3 2.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

export function IconTrend({ size = 12, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M1 9l3-3 2 2 4.5-5.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M8.5 4H11v2.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

export function IconDotsVertical({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="7" cy="3" r="1" fill="currentColor"/>
      <circle cx="7" cy="7" r="1" fill="currentColor"/>
      <circle cx="7" cy="11" r="1" fill="currentColor"/>
    </svg>
  );
}

export function IconValidate({ size = 14, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <circle cx="7" cy="7" r="5.5" stroke="currentColor" strokeWidth="1.3" fill="none"/>
      <path d="M4.5 7l2 2 3.5-3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

export function IconX({ size = 12, className = '' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none" className={className} xmlns="http://www.w3.org/2000/svg">
      <path d="M2 2l8 8M10 2l-8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}
