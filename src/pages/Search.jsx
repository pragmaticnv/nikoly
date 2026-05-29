import { useState, useEffect } from 'react';
import { usePlayer } from '../context/PlayerContext';
import './Search.css';

const BROWSE_CATEGORIES = [
  { name: 'Pop Hits', gradient: 'linear-gradient(135deg, #e02c5f, #f27e9b)', icon: 'music_note' },
  { name: 'Hip-Hop', gradient: 'linear-gradient(135deg, #4776e6, #8e54e9)', icon: 'album' },
  { name: 'Bollywood', gradient: 'linear-gradient(135deg, #f857a6, #ff5858)', icon: 'radio' },
  { name: 'Chill Vibes', gradient: 'linear-gradient(135deg, #11998e, #38ef7d)', icon: 'spa' },
  { name: 'Rock Classics', gradient: 'linear-gradient(135deg, #ff9966, #ff5e62)', icon: 'legend_toggle' },
  { name: 'New Releases', gradient: 'linear-gradient(135deg, #2193b0, #6dd5ed)', icon: 'new_releases' },
];

export default function Search({ onOpenNowPlaying }) {
  const { playTrack, playQueue, currentTrack, isPlaying } = usePlayer();
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [trending, setTrending] = useState([]);
  const [loading, setLoading] = useState(false);

  // Map JioSaavn payload
  function mapSongs(resultsArray) {
    return resultsArray.map(item => {
      const coverUrl = item.image && item.image.length > 0
        ? item.image[item.image.length - 1].url
        : 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&q=80';
      
      const downloadItem = item.downloadUrl && item.downloadUrl.length > 0
        ? item.downloadUrl[item.downloadUrl.length - 1]
        : null;
      const url = downloadItem ? downloadItem.url : '';

      const artist = item.artists && item.artists.primary && item.artists.primary.length > 0
        ? item.artists.primary.map(a => a.name).join(', ')
        : 'Unknown Artist';

      return {
        id: `saavn-${item.id}`,
        title: item.name || item.title || 'Unknown',
        artist: artist,
        album: (item.album && item.album.name) || 'Single',
        duration: parseInt(item.duration) || 180,
        coverUrl: coverUrl,
        url: url,
        artClass: `art-${(parseInt(item.id) % 8 || 0) + 1}`,
        isLocal: false,
      };
    });
  }

  // Load trending suggestions on start
  useEffect(() => {
    async function loadTrending() {
      try {
        const res = await fetch('https://saavn.sumit.co/api/search/songs?query=trending&limit=8');
        const data = await res.json();
        if (data && data.success && data.data && data.data.results) {
          setTrending(mapSongs(data.data.results));
        }
      } catch (err) {
        console.error('Error loading trending songs:', err);
      }
    }
    loadTrending();
  }, []);

  // Debounced search trigger
  useEffect(() => {
    if (!query.trim()) {
      setResults([]);
      return;
    }
    const delayDebounce = setTimeout(async () => {
      setLoading(true);
      try {
        const res = await fetch(`https://saavn.sumit.co/api/search/songs?query=${encodeURIComponent(query.trim())}&limit=30`);
        const data = await res.json();
        if (data && data.success && data.data && data.data.results) {
          setResults(mapSongs(data.data.results));
        }
      } catch (err) {
        console.error('Error searching JioSaavn:', err);
      } finally {
        setLoading(false);
      }
    }, 500);

    return () => clearTimeout(delayDebounce);
  }, [query]);

  return (
    <div className="screen">
      <header className="top-bar">
        <h1 style={{ fontSize: '1.3rem' }}>Search</h1>
      </header>

      <div className="screen-inner" style={{ paddingTop: 'calc(56px + 8px)' }}>
        {/* Spotify Recessed Tactile Search bar */}
        <div className="search-bar-container">
          <span className="material-icons-round sm search-icon">search</span>
          <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="What do you want to listen to?"
            className="search-input-box"
          />
          {query && (
            <button className="icon-btn search-clear-btn" onClick={() => setQuery('')}>
              <span className="material-icons-round sm">close</span>
            </button>
          )}
        </div>

        {/* Results List */}
        {query.trim() ? (
          <section className="search-results-section">
            <div className="section-header">
              <h2>Top Results</h2>
              {results.length > 0 && (
                <button
                  className="icon-btn"
                  onClick={() => { playQueue(results); onOpenNowPlaying?.(); }}
                  aria-label="Play all results"
                >
                  <span className="material-icons-round">play_arrow</span>
                </button>
              )}
            </div>

            {loading ? (
              <div className="empty-state">
                <div className="spinner" style={{ marginBottom: 16 }} />
                <p style={{ letterSpacing: '1px', fontWeight: 600, textTransform: 'uppercase', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  Searching JioSaavn...
                </p>
              </div>
            ) : results.length === 0 ? (
              <div className="empty-state">
                <span className="material-icons-round xl" style={{ color: 'var(--text-muted)' }}>search_off</span>
                <p>No results found online</p>
              </div>
            ) : (
              <div className="search-tracks-list">
                {results.map(track => {
                  const isActive = currentTrack?.id === track.id;
                  return (
                    <div key={track.id} className="track-row" onClick={() => playTrack(track, results)}>
                      <div className={`track-art ${track.artClass}`} style={{ overflow: 'hidden', position: 'relative', flexShrink: 0 }}>
                        {track.coverUrl ? (
                          <img src={track.coverUrl} alt={track.title} style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: 'inherit' }} />
                        ) : null}
                        {isActive && isPlaying && (
                          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'rgba(0,0,0,0.4)', borderRadius: 'inherit' }}>
                            <div className="playing-bars"><span /><span /><span /></div>
                          </div>
                        )}
                      </div>
                      <div className="track-info">
                        <p className={`name ${isActive ? 'playing' : ''}`}>{track.title}</p>
                        <p className="artist">{track.artist}</p>
                      </div>
                      <span className="track-dur">
                        {Math.floor((track.duration || 200) / 60)}:{String((track.duration || 200) % 60).padStart(2, '0')}
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </section>
        ) : (
          /* Empty state: Browse Cards & Trending List */
          <div className="search-landing-container">
            {/* Browse Categories Grid */}
            <section style={{ marginBottom: 28 }}>
              <div className="section-header">
                <h2>Browse All</h2>
              </div>
              <div className="browse-grid">
                {BROWSE_CATEGORIES.map(cat => (
                  <div
                    key={cat.name}
                    className="browse-card"
                    style={{ background: cat.gradient }}
                    onClick={() => setQuery(cat.name)}
                  >
                    <span className="browse-title">{cat.name}</span>
                    <span className="material-icons-round browse-icon">{cat.icon}</span>
                  </div>
                ))}
              </div>
            </section>

            {/* Trending Carousels */}
            {trending.length > 0 && (
              <section>
                <div className="section-header">
                  <h2>Trending Now</h2>
                </div>
                <div className="search-tracks-list">
                  {trending.map(track => {
                    const isActive = currentTrack?.id === track.id;
                    return (
                      <div key={track.id} className="track-row" onClick={() => playTrack(track, trending)}>
                        <div className={`track-art ${track.artClass}`} style={{ overflow: 'hidden', position: 'relative', flexShrink: 0 }}>
                          {track.coverUrl ? (
                            <img src={track.coverUrl} alt={track.title} style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: 'inherit' }} />
                          ) : null}
                          {isActive && isPlaying && (
                            <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'rgba(0,0,0,0.4)', borderRadius: 'inherit' }}>
                              <div className="playing-bars"><span /><span /><span /></div>
                            </div>
                          )}
                        </div>
                        <div className="track-info">
                          <p className={`name ${isActive ? 'playing' : ''}`}>{track.title}</p>
                          <p className="artist">{track.artist}</p>
                        </div>
                        <span className="track-dur">
                          {Math.floor((track.duration || 200) / 60)}:{String((track.duration || 200) % 60).padStart(2, '0')}
                        </span>
                      </div>
                    );
                  })}
                </div>
              </section>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
