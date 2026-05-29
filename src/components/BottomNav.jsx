import './BottomNav.css';

const NAV_ITEMS = [
  { id: 'home',     icon: 'home',          label: 'Home' },
  { id: 'library',  icon: 'library_music', label: 'Library' },
  { id: 'upload',   icon: 'add_circle',    label: 'Upload' },
  { id: 'insights', icon: 'bar_chart',     label: 'Insights' },
  { id: 'settings', icon: 'settings',      label: 'Settings' },
];

export default function BottomNav({ active = 'home', onChange }) {
  return (
    <nav className="bottom-nav">
      {NAV_ITEMS.map(({ id, icon, label }) => {
        const isActive = active === id;
        return (
          <button
            key={id}
            className={`nav-item ${isActive ? 'active' : ''}`}
            onClick={() => onChange?.(id)}
            aria-label={label}
          >
            <span className="material-icons-round">{icon}</span>
            <span className="nav-label">{label}</span>
            {isActive && <span className="nav-dot" />}
          </button>
        );
      })}
    </nav>
  );
}
