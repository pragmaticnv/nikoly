import { useState } from 'react';
import './Settings.css';

const THEMES = [
  { id: 'dark', label: 'Dark', class: 'theme-dark' },
  { id: 'purple', label: 'Purple', class: 'theme-purple' },
  { id: 'ocean', label: 'Ocean', class: 'theme-ocean' },
  { id: 'forest', label: 'Forest', class: 'theme-forest' },
];

const QUALITY_OPTIONS = ['Auto', 'Low (96kbps)', 'Normal (160kbps)', 'High (320kbps)', 'Lossless'];

export default function Settings({ onNavigateTo }) {
  const [theme, setTheme] = useState('dark');
  const [quality, setQuality] = useState('High (320kbps)');
  const [crossfade, setCrossfade] = useState(3);
  const [notifications, setNotifications] = useState(true);
  const [autoplay, setAutoplay] = useState(true);
  const [normalization, setNormalization] = useState(true);
  const [private_, setPrivate] = useState(false);
  const [downloading, setDownloading] = useState(false);

  function ToggleRow({ label, sub, checked, onChange }) {
    return (
      <div className="setting-row">
        <div className="setting-info">
          <p className="setting-label">{label}</p>
          {sub && <p className="setting-sub">{sub}</p>}
        </div>
        <button
          className={`toggle ${checked ? 'on' : 'off'}`}
          onClick={() => onChange(!checked)}
          aria-label={label}
        >
          <span className="toggle-thumb" />
        </button>
      </div>
    );
  }

  return (
    <div className="screen">
      <header className="top-bar">
        <button className="icon-btn" onClick={() => onNavigateTo?.('library')} aria-label="Go back" style={{ marginRight: '12px' }}>
          <span className="material-icons-round">arrow_back</span>
        </button>
        <h1 style={{fontSize:'1.3rem'}}>Settings</h1>
      </header>

      <div className="screen-inner" style={{paddingTop:'calc(56px + 8px)'}}>

        {/* Profile */}
        <div className="profile-card">
          <div className="profile-avatar">N</div>
          <div>
            <p style={{fontWeight:700, fontSize:'1rem'}}>Nikhil</p>
            <p style={{fontSize:'0.8rem', color:'var(--text-secondary)'}}>nikhil@example.com</p>
            <span className="badge badge-purple" style={{marginTop:4}}>Free Plan</span>
          </div>
          <button className="btn-secondary" style={{marginLeft:'auto', fontSize:'0.8rem'}}>Upgrade</button>
        </div>

        {/* Appearance */}
        <section>
          <div className="section-header"><h2>Appearance</h2></div>
          <div className="setting-card">
            <p className="setting-label" style={{marginBottom:12}}>Theme</p>
            <div className="theme-grid">
              {THEMES.map(t => (
                <button
                  key={t.id}
                  className={`theme-btn ${theme === t.id ? 'active' : ''}`}
                  onClick={() => setTheme(t.id)}
                >
                  <div className={`theme-preview ${t.class}`} />
                  <span>{t.label}</span>
                </button>
              ))}
            </div>
          </div>
        </section>

        {/* Audio */}
        <section>
          <div className="section-header"><h2>Audio</h2></div>
          <div className="setting-card">

            <div className="setting-row">
              <div className="setting-info">
                <p className="setting-label">Streaming Quality</p>
                <p className="setting-sub">{quality}</p>
              </div>
              <select
                value={quality}
                onChange={e => setQuality(e.target.value)}
                className="setting-select"
              >
                {QUALITY_OPTIONS.map(q => <option key={q} value={q}>{q}</option>)}
              </select>
            </div>

            <div className="divider" />

            <ToggleRow
              label="Volume Normalization"
              sub="Keep all tracks at similar volume"
              checked={normalization}
              onChange={setNormalization}
            />

            <div className="divider" />

            <div className="setting-row">
              <div className="setting-info">
                <p className="setting-label">Crossfade</p>
                <p className="setting-sub">{crossfade}s transition</p>
              </div>
              <input
                type="range" min={0} max={12} step={1}
                value={crossfade}
                onChange={e => setCrossfade(Number(e.target.value))}
                className="range-input"
              />
            </div>

          </div>
        </section>

        {/* Playback */}
        <section>
          <div className="section-header"><h2>Playback</h2></div>
          <div className="setting-card">
            <ToggleRow
              label="Autoplay"
              sub="Continue playing similar tracks"
              checked={autoplay}
              onChange={setAutoplay}
            />
            <div className="divider" />
            <ToggleRow
              label="Notifications"
              sub="Show now-playing notifications"
              checked={notifications}
              onChange={setNotifications}
            />
          </div>
        </section>

        {/* Privacy */}
        <section>
          <div className="section-header"><h2>Privacy</h2></div>
          <div className="setting-card">
            <ToggleRow
              label="Private Session"
              sub="Listen without affecting history"
              checked={private_}
              onChange={setPrivate}
            />
          </div>
        </section>

        {/* About */}
        <section>
          <div className="section-header"><h2>About</h2></div>
          <div className="setting-card">
            {[
              ['App Version', 'v1.0.0-beta'],
              ['Made with', '❤️ by Antigravity'],
            ].map(([k,v]) => (
              <div key={k} className="about-row">
                <span className="setting-label">{k}</span>
                <span className="setting-sub">{v}</span>
              </div>
            ))}
          </div>
        </section>

        <button className="sign-out-btn">
          <span className="material-icons-round sm">logout</span> Sign Out
        </button>

      </div>
    </div>
  );
}
