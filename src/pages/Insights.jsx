import { usePlayer, SAMPLE_TRACKS } from '../context/PlayerContext';
import './Insights.css';

const GENRE_DATA = [
  { genre: 'Hip-Hop', pct: 45, color: '#9b59b6' },
  { genre: 'R&B/Soul', pct: 25, color: '#3498db' },
  { genre: 'Pop', pct: 15, color: '#e74c3c' },
  { genre: 'Electronic', pct: 10, color: '#1abc9c' },
  { genre: 'Other', pct: 5, color: '#f39c12' },
];

const TOP_TRACKS = SAMPLE_TRACKS.slice(0, 5).map((t, i) => ({
  ...t,
  plays: [142, 98, 87, 76, 65][i],
}));

const WEEKLY_HOURS = [1.2, 2.4, 0.8, 3.1, 2.7, 4.5, 1.8];
const DAYS = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
const maxHours = Math.max(...WEEKLY_HOURS);

const MOODS = [
  { mood: '😤 Hype', pct: 38 },
  { mood: '😌 Chill', pct: 28 },
  { mood: '😢 Sad', pct: 18 },
  { mood: '💪 Focus', pct: 16 },
];

export default function Insights({ onNavigateTo }) {
  const { currentTrack } = usePlayer();
  const totalHrs = WEEKLY_HOURS.reduce((s,v)=>s+v,0).toFixed(1);
  const avgDay = (totalHrs / 7).toFixed(1);

  return (
    <div className="screen">
      <header className="top-bar">
        <button className="icon-btn" onClick={() => onNavigateTo?.('home')} aria-label="Go back" style={{ marginRight: '12px' }}>
          <span className="material-icons-round">arrow_back</span>
        </button>
        <h1 style={{fontSize:'1.3rem', flex: 1}}>Your Insights</h1>
        <span className="badge badge-green">This Week</span>
      </header>

      <div className="screen-inner" style={{paddingTop:'calc(56px + 8px)'}}>

        {/* Summary stats */}
        <div className="stats-grid">
          {[
            {label:'Tracks Played', val:'127', icon:'headphones'},
            {label:'Total Hours', val:totalHrs, icon:'access_time'},
            {label:'Artists', val:'34', icon:'person'},
            {label:'Daily Avg', val:`${avgDay}h`, icon:'today'},
          ].map(s => (
            <div key={s.label} className="stat-card">
              <span className="material-icons-round stat-icon">{s.icon}</span>
              <p className="stat-val">{s.val}</p>
              <p className="stat-label">{s.label}</p>
            </div>
          ))}
        </div>

        {/* Weekly Listening Chart */}
        <section>
          <div className="section-header"><h2>Daily Listening</h2></div>
          <div className="bar-chart">
            {WEEKLY_HOURS.map((h, i) => (
              <div key={i} className="bar-col">
                <p className="bar-val">{h}h</p>
                <div className="bar-track">
                  <div
                    className="bar-fill"
                    style={{ height: `${(h / maxHours) * 100}%` }}
                  />
                </div>
                <p className="bar-label">{DAYS[i]}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Genre breakdown */}
        <section>
          <div className="section-header"><h2>Genre Mix</h2></div>
          <div className="genre-bar">
            {GENRE_DATA.map(g => (
              <div
                key={g.genre}
                className="genre-seg"
                style={{ width: `${g.pct}%`, background: g.color }}
                title={`${g.genre}: ${g.pct}%`}
              />
            ))}
          </div>
          <div className="genre-legend">
            {GENRE_DATA.map(g => (
              <div key={g.genre} className="legend-item">
                <span className="legend-dot" style={{background:g.color}} />
                <span>{g.genre}</span>
                <span className="legend-pct">{g.pct}%</span>
              </div>
            ))}
          </div>
        </section>

        {/* Top tracks */}
        <section>
          <div className="section-header"><h2>Most Played</h2></div>
          {TOP_TRACKS.map((t, i) => (
            <div key={t.id} className="insight-track-row">
              <span className="track-rank">{i + 1}</span>
              <div className={`track-art ${t.artClass}`}>
                <span className="material-icons-round sm" style={{color:'rgba(255,255,255,0.5)'}}>music_note</span>
              </div>
              <div className="track-info">
                <p className="name">{t.title}</p>
                <p className="artist">{t.artist}</p>
              </div>
              <div className="plays-bar-container">
                <div className="plays-bar" style={{ width: `${(t.plays / TOP_TRACKS[0].plays) * 100}%` }} />
                <span className="plays-count">{t.plays}x</span>
              </div>
            </div>
          ))}
        </section>

        {/* Mood */}
        <section>
          <div className="section-header"><h2>Mood Profile</h2></div>
          <div className="mood-list">
            {MOODS.map(m => (
              <div key={m.mood} className="mood-row">
                <span className="mood-label">{m.mood}</span>
                <div className="mood-track">
                  <div className="mood-fill" style={{ width: `${m.pct}%` }} />
                </div>
                <span className="mood-pct">{m.pct}%</span>
              </div>
            ))}
          </div>
        </section>

      </div>
    </div>
  );
}
