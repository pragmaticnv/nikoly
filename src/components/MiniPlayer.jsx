import { usePlayer, formatTime } from '../context/PlayerContext';
import './MiniPlayer.css';

export default function MiniPlayer({ onOpenNowPlaying }) {
  const { currentTrack, isPlaying, progress, togglePlay, clearTrack } = usePlayer();

  if (!currentTrack) return null;

  const elapsed = formatTime((progress || 0) * (currentTrack.duration || 200));

  return (
    <div className="mini-player" onClick={onOpenNowPlaying}>
      <div className={`mini-art ${currentTrack.artClass}`} style={{ overflow: 'hidden', position: 'relative' }}>
        {currentTrack.coverUrl ? (
          <img src={currentTrack.coverUrl} alt={currentTrack.title} style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: 'inherit' }} />
        ) : (
          <span className="material-icons-round" style={{ color: 'rgba(255,255,255,0.6)', fontSize: 18 }}>music_note</span>
        )}
      </div>

      <div className="mini-info">
        <p className="mini-title">{currentTrack.title}</p>
        <p className="mini-artist">{currentTrack.artist}</p>
      </div>

      <div className="mini-time">{elapsed}</div>

      <div style={{ display: 'flex', alignItems: 'center' }}>
        <button
          className="icon-btn mini-btn"
          onClick={(e) => { e.stopPropagation(); togglePlay(); }}
          aria-label={isPlaying ? 'Pause' : 'Play'}
        >
          <span className="material-icons-round">{isPlaying ? 'pause' : 'play_arrow'}</span>
        </button>

        <button
          className="icon-btn mini-btn"
          onClick={(e) => { e.stopPropagation(); clearTrack(); }}
          aria-label="Close player"
          style={{ color: 'var(--text-muted)', marginLeft: '-4px' }}
        >
          <span className="material-icons-round" style={{ fontSize: '20px' }}>close</span>
        </button>
      </div>

      <div className="mini-progress-bar">
        <div className="mini-progress-fill" style={{ width: `${(progress || 0) * 100}%` }} />
      </div>
    </div>
  );
}
