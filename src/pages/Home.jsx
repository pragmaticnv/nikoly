
import { usePlayer, SAMPLE_TRACKS, PLAYLISTS } from '../context/PlayerContext';
import './Home.css';

const TOP_ARTISTS = [
  { name: 'Kendrick Lamar', artClass: 'art-5', followers: '80M', imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200&q=80' },
  { name: 'Drake', artClass: 'art-3', followers: '75M', imageUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=200&q=80' },
  { name: 'SZA', artClass: 'art-6', followers: '28M', imageUrl: 'https://images.unsplash.com/photo-1511735111819-9a3f7709049c?w=200&q=80' },
  { name: 'The Weeknd', artClass: 'art-1', followers: '90M', imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200&q=80' },
  { name: 'Dua Lipa', artClass: 'art-4', followers: '55M', imageUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=200&q=80' },
];

function getGreeting() {
  const h = new Date().getHours();
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

export default function Home({ onOpenNowPlaying, onNavigateTo }) {
  const { playTrack, playQueue, currentTrack, isPlaying } = usePlayer();

  const recentTracks = SAMPLE_TRACKS.slice(0, 6);

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
        <section>
          <div className="section-header">
            <h2>Recently Played</h2>
            <span className="see-all" onClick={() => onNavigateTo?.('library')}>See all</span>
          </div>
          <div className="h-scroll">
            {recentTracks.map(track => (
              <div key={track.id} className="recent-card" onClick={() => playTrack(track, SAMPLE_TRACKS)}>
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

        {/* Personalized Mixes */}
        <section>
          <div className="section-header">
            <h2>Personalized for You</h2>
          </div>
          <div className="mix-grid">
            {PLAYLISTS.slice(0, 4).map(pl => (
              <div key={pl.id} className="mix-card" onClick={() => {
                const tracks = pl.trackIds.map(id => SAMPLE_TRACKS.find(t => t.id === id)).filter(Boolean);
                playQueue(tracks);
                onOpenNowPlaying?.();
              }}>
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

        {/* Top Artists */}
        <section>
          <div className="section-header">
            <h2>Your Top Artists</h2>
            <span className="see-all" onClick={() => onNavigateTo?.('insights')}>See all</span>
          </div>
          <div className="h-scroll">
            {TOP_ARTISTS.map(artist => (
              <div key={artist.name} className="artist-card">
                <div className={`artist-img ${artist.artClass}`}>
                  {artist.imageUrl
                    ? <img src={artist.imageUrl} alt={artist.name} style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'50%'}} />
                    : <span className="material-icons-round xl" style={{color:'rgba(255,255,255,0.4)'}}>person</span>}
                </div>
                <p className="artist-name">{artist.name}</p>
                <p className="artist-sub">{artist.followers} followers</p>
              </div>
            ))}
          </div>
        </section>

        {/* Quick picks row */}
        <section>
          <div className="section-header">
            <h2>Quick Picks</h2>
          </div>
          {SAMPLE_TRACKS.slice(0, 4).map(track => (
            <div key={track.id} className="track-row" onClick={() => playTrack(track, SAMPLE_TRACKS)}>
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

      </div>
    </div>
  );
}
