import { useState, useEffect } from 'react';

import { usePlayer, SAMPLE_TRACKS, PLAYLISTS } from '../context/PlayerContext';
import './Library.css';

export default function Library({ onOpenNowPlaying, onNavigateTo }) {
  const { playTrack, playQueue, currentTrack, isPlaying, userTracks } = usePlayer();
  const [search, setSearch] = useState('');
  const [tab, setTab] = useState('all'); // 'all' | 'local' | 'playlists' | 'discover'
  const [discoverTracks, setDiscoverTracks] = useState([]);
  const [loadingDiscover, setLoadingDiscover] = useState(false);

  const allTracks = [...userTracks, ...SAMPLE_TRACKS];
  const filtered = allTracks.filter(t =>
    t.title.toLowerCase().includes(search.toLowerCase()) ||
    t.artist.toLowerCase().includes(search.toLowerCase())
  );

  async function fetchJioSaavn(query = '') {
    setLoadingDiscover(true);
    try {
      const url = `https://saavn.sumit.co/api/search/songs?query=${encodeURIComponent(query.trim() || 'trending')}&limit=30`;
      const response = await fetch(url);
      const data = await response.json();
      if (data && data.success && data.data && data.data.results) {
        const mapped = data.data.results.map(item => {
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
        setDiscoverTracks(mapped);
      }
    } catch (err) {
      console.error('Error fetching from JioSaavn:', err);
    } finally {
      setLoadingDiscover(false);
    }
  }

  useEffect(() => {
    if (tab !== 'discover') return;
    const delayDebounce = setTimeout(() => {
      fetchJioSaavn(search);
    }, 500);
    return () => clearTimeout(delayDebounce);
  }, [search, tab]);

  return (
    <div className="screen">
      <header className="top-bar">
        <h1 style={{fontSize:'1.3rem'}}>Your Library</h1>
        <button className="icon-btn" onClick={() => onNavigateTo?.('upload')} aria-label="Add to library">
          <span className="material-icons-round">add</span>
        </button>
      </header>

      <div className="screen-inner" style={{paddingTop: 'calc(56px + 8px)'}}>

        {/* Search */}
        <div className="lib-search">
          <span className="material-icons-round sm" style={{color:'var(--text-muted)'}}>search</span>
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search songs, artists..."
            className="lib-search-input"
          />
          {search && <button className="icon-btn" onClick={() => setSearch('')} style={{padding:4}}>
            <span className="material-icons-round sm">close</span>
          </button>}
        </div>

        {/* Tab pills */}
        <div className="lib-tabs">
          {[['all','All Tracks'],['local','Local Files'],['playlists','Playlists'],['discover','Discover Online']].map(([v,l]) => (
            <button key={v} className={`lib-tab ${tab===v?'active':''}`} onClick={() => setTab(v)}>{l}</button>
          ))}
        </div>

        {/* Playlists tab */}
        {tab === 'playlists' && (
          <section>
            <div className="section-header">
              <h2>Playlists</h2>
              <span className="see-all" onClick={() => onNavigateTo?.('upload')}>+ Import</span>
            </div>
            {PLAYLISTS.map(pl => {
              const tracks = pl.trackIds.map(id => SAMPLE_TRACKS.find(t => t.id === id)).filter(Boolean);
              return (
                <div key={pl.id} className="track-row" onClick={() => { playQueue(tracks); onOpenNowPlaying?.(); }}>
                  <div className={`track-art ${pl.artClass}`} style={{overflow:'hidden',position:'relative',flexShrink:0}}>
                    {pl.coverUrl
                      ? <img src={pl.coverUrl} alt={pl.name} style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'inherit'}} />
                      : <span className="material-icons-round sm" style={{color:'rgba(255,255,255,0.5)'}}>queue_music</span>}
                  </div>
                  <div className="track-info">
                    <p className="name">{pl.name}</p>
                    <p className="artist">{pl.count} tracks · Playlist</p>
                  </div>
                  <span className="material-icons-round" style={{color:'var(--text-muted)',fontSize:18}}>more_vert</span>
                </div>
              );
            })}
          </section>
        )}

        {/* Local files tab */}
        {tab === 'local' && (
          <section>
            <div className="section-header">
              <h2>Local Files</h2>
              <span className="see-all" onClick={() => onNavigateTo?.('upload')}>Upload</span>
            </div>
            {userTracks.length === 0 && (
              <div className="empty-state">
                <span className="material-icons-round xl" style={{color:'var(--text-muted)'}}>audio_file</span>
                <p>No local files yet</p>
                <button className="btn-primary" style={{marginTop:12}} onClick={() => onNavigateTo?.('upload')}>
                  <span className="material-icons-round sm">upload</span> Upload Music
                </button>
              </div>
            )}
            {[...SAMPLE_TRACKS.slice(0,2), ...userTracks].map(track => (
              <div key={track.id} className="track-row" onClick={() => playTrack(track, allTracks)}>
                <div className={`track-art ${track.artClass}`} style={{overflow:'hidden',position:'relative',flexShrink:0}}>
                  {track.coverUrl
                    ? <img src={track.coverUrl} alt={track.title} style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'inherit'}} />
                    : null}
                  {currentTrack?.id === track.id && isPlaying && (
                    <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',background:'rgba(0,0,0,0.4)',borderRadius:'inherit'}}>
                      <div className="playing-bars"><span/><span/><span/></div>
                    </div>
                  )}
                </div>
                <div className="track-info">
                  <p className={`name ${currentTrack?.id === track.id ? 'playing' : ''}`}>{track.title}</p>
                  <p className="artist">{track.artist} · {Math.floor((track.duration||200)/60)}:{String((track.duration||200)%60).padStart(2,'0')}</p>
                </div>
                <span className="badge badge-blue" style={{fontSize:'0.65rem'}}>Local</span>
              </div>
            ))}
          </section>
        )}

        {/* All tracks tab */}
        {tab === 'all' && (
          <section>
            <div className="section-header">
              <h2>{search ? `Results (${filtered.length})` : `All Tracks (${allTracks.length})`}</h2>
              <button
                className="icon-btn"
                style={{padding:4}}
                onClick={() => { playQueue(filtered.length ? filtered : allTracks); onOpenNowPlaying?.(); }}
                aria-label="Shuffle play all"
              >
                <span className="material-icons-round">shuffle</span>
              </button>
            </div>
            {filtered.map(track => (
              <div key={track.id} className="track-row" onClick={() => playTrack(track, allTracks)}>
                <div className={`track-art ${track.artClass}`} style={{overflow:'hidden',position:'relative',flexShrink:0}}>
                  {track.coverUrl
                    ? <img src={track.coverUrl} alt={track.title} style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'inherit'}} />
                    : null}
                  {currentTrack?.id === track.id && isPlaying && (
                    <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',background:'rgba(0,0,0,0.4)',borderRadius:'inherit'}}>
                      <div className="playing-bars"><span/><span/><span/></div>
                    </div>
                  )}
                </div>
                <div className="track-info">
                  <p className={`name ${currentTrack?.id === track.id ? 'playing' : ''}`}>{track.title}</p>
                  <p className="artist">{track.artist}</p>
                </div>
                <span className="track-dur">{Math.floor((track.duration||200)/60)}:{String((track.duration||200)%60).padStart(2,'0')}</span>
              </div>
            ))}
            {filtered.length === 0 && (
              <div className="empty-state">
                <span className="material-icons-round xl" style={{color:'var(--text-muted)'}}>search_off</span>
                <p>No results for "{search}"</p>
              </div>
            )}
          </section>
        )}

        {/* Discover Online tab */}
        {tab === 'discover' && (
          <section>
            <div className="section-header">
              <h2>{search ? `Online Results (${discoverTracks.length})` : 'Popular Tracks'}</h2>
              {discoverTracks.length > 0 && (
                <button
                  className="icon-btn"
                  style={{padding:4}}
                  onClick={() => { playQueue(discoverTracks); onOpenNowPlaying?.(); }}
                  aria-label="Play online tracks"
                >
                  <span className="material-icons-round">play_arrow</span>
                </button>
              )}
            </div>

            {loadingDiscover ? (
              <div className="empty-state">
                <div className="spinner" style={{marginBottom:16}} />
                <p>Searching JioSaavn...</p>
              </div>
            ) : discoverTracks.length === 0 ? (
              <div className="empty-state">
                <span className="material-icons-round xl" style={{color:'var(--text-muted)'}}>search_off</span>
                <p>No results found online</p>
              </div>
            ) : (
              discoverTracks.map(track => (
                <div key={track.id} className="track-row" onClick={() => playTrack(track, discoverTracks)}>
                  <div className={`track-art ${track.artClass}`} style={{overflow:'hidden',position:'relative',flexShrink:0}}>
                    {track.coverUrl
                      ? <img src={track.coverUrl} alt={track.title} style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'inherit'}} />
                      : null}
                    {currentTrack?.id === track.id && isPlaying && (
                      <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',background:'rgba(0,0,0,0.4)',borderRadius:'inherit'}}>
                        <div className="playing-bars"><span/><span/><span/></div>
                      </div>
                    )}
                  </div>
                  <div className="track-info">
                    <p className={`name ${currentTrack?.id === track.id ? 'playing' : ''}`}>{track.title}</p>
                    <p className="artist">{track.artist} · JioSaavn</p>
                  </div>
                  <span className="track-dur">{Math.floor((track.duration||200)/60)}:{String((track.duration||200)%60).padStart(2,'0')}</span>
                </div>
              ))
            )}
          </section>
        )}
      </div>
    </div>
  );
}
