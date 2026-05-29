import { useState, useEffect } from 'react';
import { usePlayer } from '../context/PlayerContext';
import './Home.css';

function getGreeting() {
  const h = new Date().getHours();
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

export default function Home({ onOpenNowPlaying, onNavigateTo }) {
  const { playTrack, playQueue, currentTrack, isPlaying } = usePlayer();
  const [recentTracks, setRecentTracks] = useState([]);
  const [mixPlaylists, setMixPlaylists] = useState([]);
  const [topArtists, setTopArtists] = useState([]);
  const [quickPicks, setQuickPicks] = useState([]);
  const [loading, setLoading] = useState(true);

  function mapSongs(data) {
    if (data && data.success && data.data && data.data.results) {
      return data.data.results.map(item => {
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
    return [];
  }

  function mapPlaylists(data) {
    if (data && data.success && data.data && data.data.results) {
      return data.data.results.map(item => {
        const coverUrl = item.image && item.image.length > 0
          ? item.image[item.image.length - 1].url
          : 'https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?w=300&q=80';
        return {
          id: item.id,
          name: item.name || item.title || 'Playlist',
          description: item.description || 'Curated just for you',
          coverUrl: coverUrl,
          artClass: `art-${(item.id.charCodeAt(0) % 8) + 1}`,
        };
      });
    }
    return [];
  }

  function mapArtists(data) {
    if (data && data.success && data.data && data.data.results) {
      return data.data.results.map(item => {
        const imageUrl = item.image && item.image.length > 0
          ? item.image[item.image.length - 1].url
          : 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=200&q=80';
        return {
          name: item.name || item.title || 'Artist',
          imageUrl: imageUrl,
          followers: 'Verified Artist',
          artClass: `art-${(item.id.charCodeAt(0) % 8) + 1}`,
        };
      });
    }
    return [];
  }

  useEffect(() => {
    async function loadHomeData() {
      setLoading(true);
      try {
        // 1. Fetch Recently Played (Trending Hits)
        const trendingRes = await fetch('https://saavn.sumit.co/api/search/songs?query=trending&limit=6');
        const trendingData = await trendingRes.json();
        const mappedTrending = mapSongs(trendingData);

        // 2. Fetch Playlists (Personalized Mixes)
        const playlistsRes = await fetch('https://saavn.sumit.co/api/search/playlists?query=mix&limit=4');
        const playlistsData = await playlistsRes.json();
        const mappedPlaylists = mapPlaylists(playlistsData);

        // 3. Fetch Artists (Top Artists)
        const artistsRes = await fetch('https://saavn.sumit.co/api/search/artists?query=pop&limit=5');
        const artistsData = await artistsRes.json();
        const mappedArtists = mapArtists(artistsData);

        // 4. Fetch Quick Picks (New Releases)
        const newRes = await fetch('https://saavn.sumit.co/api/search/songs?query=new&limit=4');
        const newData = await newRes.json();
        const mappedNew = mapSongs(newData);

        setRecentTracks(mappedTrending);
        setMixPlaylists(mappedPlaylists);
        setTopArtists(mappedArtists);
        setQuickPicks(mappedNew);
      } catch (err) {
        console.error('Error loading Home data:', err);
      } finally {
        setLoading(false);
      }
    }
    loadHomeData();
  }, []);

  async function handlePlaylistClick(playlist) {
    try {
      setLoading(true);
      const res = await fetch(`https://saavn.sumit.co/api/playlists?id=${playlist.id}`);
      const data = await res.json();
      
      let tracks = [];
      if (data && data.success && data.data && data.data.songs && data.data.songs.length > 0) {
        tracks = mapSongs({ success: true, data: { results: data.data.songs } });
      }

      // Fallback: If playlist details returned no songs, search dynamically for tracks matching its name
      if (tracks.length === 0) {
        const fallbackRes = await fetch(`https://saavn.sumit.co/api/search/songs?query=${encodeURIComponent(playlist.name)}&limit=25`);
        const fallbackData = await fallbackRes.json();
        tracks = mapSongs(fallbackData);
      }

      if (tracks.length > 0) {
        playQueue(tracks);
        onOpenNowPlaying?.();
      }
    } catch (err) {
      console.error('Error playing playlist:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="screen" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '80vh' }}>
        <div className="empty-state">
          <div className="spinner" style={{ marginBottom: 16 }} />
          <p style={{ letterSpacing: '1px', fontWeight: 600, textTransform: 'uppercase', fontSize: '0.78rem', color: 'var(--text-secondary)' }}>
            Configuring Your Feed...
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="screen">
      <header className="top-bar home-header">
        <div>
          <p className="greeting">{getGreeting()}</p>
          <h1 className="user-name">Welcome back, Nikhil!</h1>
        </div>
        <div className="header-actions">
          <button className="icon-btn" onClick={() => onNavigateTo?.('upload')} aria-label="Add music">
            <span className="material-icons-round">add_circle_outline</span>
          </button>
          <div className="avatar">N</div>
        </div>
      </header>

      <div className="screen-inner">

        {/* Recently Played */}
        {recentTracks.length > 0 && (
          <section>
            <div className="section-header">
              <h2>Trending Hits</h2>
              <span className="see-all" onClick={() => onNavigateTo?.('library')}>See all</span>
            </div>
            <div className="h-scroll">
              {recentTracks.map(track => (
                <div key={track.id} className="recent-card" onClick={() => playTrack(track, recentTracks)}>
                  <div className={`recent-art ${track.artClass}`}>
                    {track.coverUrl
                      ? <img src={track.coverUrl} alt={track.title} style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'inherit'}} />
                      : null}
                    {currentTrack?.id === track.id && isPlaying && (
                      <div className="art-overlay-indicator">
                        <div className="playing-bars"><span/><span/><span/></div>
                      </div>
                    )}
                  </div>
                  <p className="recent-title">{track.title}</p>
                  <p className="recent-artist">{track.artist}</p>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Personalized Mixes */}
        {mixPlaylists.length > 0 && (
          <section>
            <div className="section-header">
              <h2>Personalized for You</h2>
            </div>
            <div className="mix-grid">
              {mixPlaylists.map(pl => (
                <div key={pl.id} className="mix-card" onClick={() => handlePlaylistClick(pl)}>
                  <div className={`mix-art ${pl.artClass}`}>
                    {pl.coverUrl
                      ? <img src={pl.coverUrl} alt={pl.name} style={{width:'100%',height:'100%',objectFit:'cover',position:'absolute',inset:0,borderRadius:'inherit'}} />
                      : <span className="material-icons-round xl" style={{color:'rgba(255,255,255,0.4)'}}>queue_music</span>}
                    <button className="mix-play-btn">
                      <span className="material-icons-round">play_arrow</span>
                    </button>
                  </div>
                  <p className="mix-name">{pl.name}</p>
                  <p className="mix-desc">{pl.description}</p>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Top Artists */}
        {topArtists.length > 0 && (
          <section>
            <div className="section-header">
              <h2>Your Top Artists</h2>
              <span className="see-all" onClick={() => onNavigateTo?.('insights')}>See all</span>
            </div>
            <div className="h-scroll">
              {topArtists.map(artist => (
                <div key={artist.name} className="artist-card" onClick={() => onNavigateTo?.('library')}>
                  <div className={`artist-img ${artist.artClass}`}>
                    {artist.imageUrl
                      ? <img src={artist.imageUrl} alt={artist.name} style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'50%'}} />
                      : <span className="material-icons-round xl" style={{color:'rgba(255,255,255,0.4)'}}>person</span>}
                  </div>
                  <p className="artist-name">{artist.name}</p>
                  <p className="artist-sub">{artist.followers}</p>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Quick picks row */}
        {quickPicks.length > 0 && (
          <section>
            <div className="section-header">
              <h2>Quick Picks</h2>
            </div>
            {quickPicks.map(track => (
              <div key={track.id} className="track-row" onClick={() => playTrack(track, quickPicks)}>
                <div className={`track-art ${track.artClass}`}>
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
                <span className="material-icons-round" style={{color:'var(--text-muted)',fontSize:18}}>more_vert</span>
              </div>
            ))}
          </section>
        )}

      </div>
    </div>
  );
}
