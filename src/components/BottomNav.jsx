import './BottomNav.css';

const NAV_ITEMS = [
  { id: 'home',     icon: 'home',          label: 'Home' },
  { id: 'search',   icon: 'search',        label: 'Search' },
  { id: 'library',  icon: 'library_music', label: 'Your Library' },
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
