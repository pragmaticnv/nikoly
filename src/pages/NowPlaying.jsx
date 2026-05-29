
import { usePlayer, SAMPLE_TRACKS, formatTime } from '../context/PlayerContext';
import './NowPlaying.css';

export default function NowPlaying({ onClose, navigate: onNavigateTo }) {
  const {
    currentTrack, isPlaying, progress, volume,
    isShuffle, repeatMode, isLiked,
    togglePlay, next, prev, seek,
    toggleShuffle, toggleRepeat, toggleLike,
  } = usePlayer();

  if (!currentTrack) {
    return (
      <div className="screen">
        <div className="screen-inner" style={{alignItems:'center', justifyContent:'center', height:'80vh'}}>
          <span className="material-icons-round" style={{fontSize:64, color:'var(--text-muted)'}}>library_music</span>
          <p style={{color:'var(--text-secondary)', textAlign:'center', marginTop:16}}>Nothing playing yet.<br/>Pick a track from the Library!</p>
          <button className="btn-primary" style={{marginTop:24}} onClick={() => onNavigateTo?.('/library')}>Browse Library</button>
        </div>
      </div>
    );
  }

  const elapsed = formatTime((progress || 0) * (currentTrack.duration || 200));
  const remaining = formatTime(currentTrack.duration || 200);

  const repeatIcon = repeatMode === 'one' ? 'repeat_one' : 'repeat';

  return (
    <div className="np-screen">
      {/* Background Art */}
      <div
        className={`np-bg ${currentTrack.artClass}`}
        style={currentTrack.coverUrl ? {
          backgroundImage: `url(${currentTrack.coverUrl})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        } : {}}
      />
      <div className="np-overlay" />

      {/* Header */}
      <header className="np-header">
        <button className="icon-btn" onClick={onClose} aria-label="Go back">
          <span className="material-icons-round">keyboard_arrow_down</span>
        </button>
        <div className="np-header-text">
          <p className="np-context">Now Playing</p>
        </div>
        <button className="icon-btn" aria-label="More options">
          <span className="material-icons-round">more_vert</span>
        </button>
      </header>

      {/* Album Art */}
      <div className="np-art-container">
        <div className={`np-art ${currentTrack.artClass} ${isPlaying ? 'playing' : ''}`}
          style={{overflow:'hidden', position:'relative'}}>
          {currentTrack.coverUrl
            ? <img src={currentTrack.coverUrl} alt={currentTrack.title}
                style={{width:'100%',height:'100%',objectFit:'cover',borderRadius:'inherit'}} />
            : <span className="material-icons-round" style={{fontSize:72, color:'rgba(255,255,255,0.3)'}}>music_note</span>
          }
        </div>
      </div>


      {/* Track Info + Like */}
      <div className="np-info">
        <div className="np-title-row">
          <div>
            <h1 className="np-title">{currentTrack.title}</h1>
            <p className="np-artist">{currentTrack.artist}</p>
          </div>
          <button className={`icon-btn liked-btn ${isLiked ? 'active' : ''}`} onClick={toggleLike} aria-label="Like">
            <span className="material-icons-round">{isLiked ? 'favorite' : 'favorite_border'}</span>
          </button>
        </div>
      </div>

      {/* Progress */}
      <div className="np-progress">
        <input
          type="range"
          min={0} max={1} step={0.001}
          value={progress || 0}
          onChange={e => seek(parseFloat(e.target.value))}
          className="np-slider"
        />
        <div className="np-times">
          <span>{elapsed}</span>
          <span>{remaining}</span>
        </div>
      </div>

      {/* Controls */}
      <div className="np-controls">
        <button
          className={`icon-btn ctrl-btn ${isShuffle ? 'active' : ''}`}
          onClick={toggleShuffle}
          aria-label="Shuffle"
        >
          <span className="material-icons-round">shuffle</span>
        </button>

        <button className="icon-btn ctrl-btn prev-btn" onClick={prev} aria-label="Previous">
          <span className="material-icons-round">skip_previous</span>
        </button>

        <button className="play-btn" onClick={togglePlay} aria-label={isPlaying ? 'Pause' : 'Play'}>
          <span className="material-icons-round" style={{fontSize:32}}>{isPlaying ? 'pause' : 'play_arrow'}</span>
        </button>

        <button className="icon-btn ctrl-btn next-btn" onClick={next} aria-label="Next">
          <span className="material-icons-round">skip_next</span>
        </button>

        <button
          className={`icon-btn ctrl-btn ${repeatMode !== 'none' ? 'active' : ''}`}
          onClick={toggleRepeat}
          aria-label="Repeat"
        >
          <span className="material-icons-round">{repeatIcon}</span>
        </button>
      </div>

      {/* Footer actions */}
      <div className="np-footer">
        <button className="icon-btn" aria-label="Add to playlist">
          <span className="material-icons-round sm">playlist_add</span>
        </button>
        <button className="icon-btn" aria-label="Share" onClick={() => onNavigateTo?.('/insights')}>
          <span className="material-icons-round sm">bar_chart</span>
        </button>
        <button className="icon-btn" aria-label="Devices">
          <span className="material-icons-round sm">devices</span>
        </button>
      </div>
    </div>
  );
}
