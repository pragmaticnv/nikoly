import { createContext, useContext, useReducer, useRef, useEffect, useCallback } from 'react';
import { supabase } from '../supabase';

// ── Sample Data ──────────────────────────────────────────────────────────────
export const SAMPLE_TRACKS = [
  { id: 1, title: 'Blinding Lights', artist: 'The Weeknd', album: 'After Hours', duration: 200, artClass: 'art-1', plays: 128, coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&q=80' },
  { id: 2, title: 'Levitating', artist: 'Dua Lipa', album: 'Future Nostalgia', duration: 203, artClass: 'art-4', plays: 94, coverUrl: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=300&q=80' },
  { id: 3, title: 'Peaches', artist: 'Justin Bieber', album: 'Justice', duration: 198, artClass: 'art-6', plays: 76, coverUrl: 'https://images.unsplash.com/photo-1511735111819-9a3f7709049c?w=300&q=80' },
  { id: 4, title: 'Midnight City', artist: 'M83', album: "Hurry Up, We're Dreaming", duration: 243, artClass: 'art-2', plays: 65, coverUrl: 'https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?w=300&q=80' },
  { id: 5, title: 'Starboy', artist: 'The Weeknd', album: 'Starboy', duration: 230, artClass: 'art-5', plays: 58, coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&q=80' },
  { id: 6, title: 'Electric Dreams', artist: 'Synthwave Collective', album: 'Neon Nights', duration: 215, artClass: 'art-7', plays: 52, coverUrl: 'https://images.unsplash.com/photo-1483412033650-1015ddeb83d1?w=300&q=80' },
  { id: 7, title: 'Stay', artist: 'The Kid LAROI, Justin Bieber', album: "F*CK LOVE", duration: 141, artClass: 'art-3', plays: 48, coverUrl: 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=300&q=80' },
  { id: 8, title: 'Save Your Tears', artist: 'The Weeknd', album: 'After Hours', duration: 215, artClass: 'art-1', plays: 45, coverUrl: 'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=300&q=80' },
  { id: 9, title: 'Neon Afterglow', artist: 'Stellar Velocity', album: "Neon Nights", duration: 228, artClass: 'art-8', plays: 40, coverUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&q=80' },
  { id: 10, title: 'Bad Guy', artist: 'Billie Eilish', album: 'WHEN WE ALL FALL ASLEEP', duration: 194, artClass: 'art-5', plays: 36, coverUrl: 'https://images.unsplash.com/photo-1571266028243-d220c6cb9dba?w=300&q=80' },
];

export const PLAYLISTS = [
  { id: 'daily-mix-1', name: 'Daily Mix 1', description: 'The Weeknd, Drake, Kendrick and more', trackIds: [1, 2, 5, 8], artClass: 'art-1', count: 50, coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&q=80' },
  { id: 'fresh-finds', name: 'Fresh Finds', description: 'New music discovered just for you', trackIds: [6, 9, 10, 7], artClass: 'art-4', count: 30, coverUrl: 'https://images.unsplash.com/photo-1494232410401-ad00d5433cfa?w=300&q=80' },
  { id: 'release-radar', name: 'Release Radar', description: "Catch all the latest music", trackIds: [3, 4, 6], artClass: 'art-7', count: 25, coverUrl: 'https://images.unsplash.com/photo-1483412033650-1015ddeb83d1?w=300&q=80' },
  { id: 'time-capsule', name: 'Time Capsule', description: 'A soundtrack to take you back', trackIds: [4, 8, 5], artClass: 'art-2', count: 20, coverUrl: 'https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?w=300&q=80' },
  { id: 'chill-hits', name: 'Chill Hits', description: 'Easy vibes', trackIds: [2, 4, 9, 10], artClass: 'art-3', count: 120, coverUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=300&q=80' },
];

// ── Reducer ───────────────────────────────────────────────────────────────────
const initialState = {
  currentTrack: null,
  queue: [],
  queueIndex: 0,
  isPlaying: false,
  progress: 0,          // 0–1
  volume: 0.8,
  isShuffle: false,
  repeatMode: 'none',   // 'none' | 'one' | 'all'
  isLiked: false,
  userTracks: [],       // local uploaded tracks
};

function playerReducer(state, action) {
  switch (action.type) {
    case 'PLAY_TRACK': {
      const queue = action.queue || state.queue;
      const idx = queue.findIndex(t => t.id === action.track.id);
      return { ...state, currentTrack: action.track, queue, queueIndex: idx >= 0 ? idx : 0, isPlaying: true, progress: 0 };
    }
    case 'PLAY_QUEUE':
      return { ...state, queue: action.queue, queueIndex: 0, currentTrack: action.queue[0], isPlaying: true, progress: 0 };
    case 'TOGGLE_PLAY':
      return { ...state, isPlaying: !state.isPlaying };
    case 'SET_PLAYING':
      return { ...state, isPlaying: action.value };
      case 'SET_PROGRESS': {
      const value = typeof action.value === 'function'
        ? action.value(state.progress)
        : action.value;
      const normalized = Math.max(0, Math.min(1, Number(value) || 0));
      return { ...state, progress: normalized };
    }
    case 'UPDATE_CURRENT_TRACK': {
      return { ...state, currentTrack: { ...state.currentTrack, ...action.updates } };
    }
    case 'NEXT': {
      if (!state.queue.length) return state;
      let nextIdx = state.isShuffle
        ? Math.floor(Math.random() * state.queue.length)
        : (state.queueIndex + 1) % state.queue.length;
      return { ...state, queueIndex: nextIdx, currentTrack: state.queue[nextIdx], isPlaying: true, progress: 0 };
    }
    case 'PREV': {
      if (!state.queue.length) return state;
      const prevIdx = state.queueIndex === 0 ? state.queue.length - 1 : state.queueIndex - 1;
      return { ...state, queueIndex: prevIdx, currentTrack: state.queue[prevIdx], isPlaying: true, progress: 0 };
    }
    case 'TOGGLE_SHUFFLE':
      return { ...state, isShuffle: !state.isShuffle };
    case 'TOGGLE_REPEAT': {
      const modes = ['none', 'all', 'one'];
      const next = modes[(modes.indexOf(state.repeatMode) + 1) % modes.length];
      return { ...state, repeatMode: next };
    }
    case 'TOGGLE_LIKE':
      return { ...state, isLiked: !state.isLiked };
    case 'SET_VOLUME':
      return { ...state, volume: action.value };
    case 'ADD_USER_TRACK':
      return { ...state, userTracks: [action.track, ...state.userTracks] };
    case 'SET_USER_TRACKS':
      return { ...state, userTracks: action.tracks };
    default:
      return state;
  }
}

// ── Context ───────────────────────────────────────────────────────────────────
const PlayerContext = createContext(null);

export function PlayerProvider({ children }) {
  const [state, dispatch] = useReducer(playerReducer, initialState);
  const audioRef = useRef(new Audio());

  // Sync volume with the audio element
  useEffect(() => {
    audioRef.current.volume = state.volume;
  }, [state.volume]);

  // Sync current track -> load source
  useEffect(() => {
    const audio = audioRef.current;
    if (state.currentTrack?.url) {
      audio.src = state.currentTrack.url;
      audio.currentTime = (state.progress || 0) * (audio.duration || state.currentTrack.duration || 0);
      if (state.isPlaying) {
        audio.play().catch(() => {});
      }
    } else {
      audio.pause();
      audio.src = '';
    }
  }, [state.currentTrack?.url]);

  // Play/pause when user toggles playback
  useEffect(() => {
    const audio = audioRef.current;
    if (!state.currentTrack?.url) return;
    if (state.isPlaying) {
      audio.play().catch(() => {});
    } else {
      audio.pause();
    }
  }, [state.isPlaying, state.currentTrack?.url]);

  // Sync progress from actual audio element and handle ended event
  useEffect(() => {
    const audio = audioRef.current;
    const onTimeUpdate = () => {
      if (!audio.duration || Number.isNaN(audio.duration)) return;
      dispatch({ type: 'SET_PROGRESS', value: audio.currentTime / audio.duration });
    };
    const onEnded = () => {
      if (state.repeatMode === 'one') {
        audio.currentTime = 0;
        audio.play().catch(() => {});
        return;
      }
      if (state.repeatMode === 'all' || state.queue.length > 1) {
        dispatch({ type: 'NEXT' });
        return;
      }
      dispatch({ type: 'SET_PLAYING', value: false });
    };
    const onLoadedMetadata = () => {
      if (!state.currentTrack) return;
      dispatch({ type: 'UPDATE_CURRENT_TRACK', updates: { duration: audio.duration } });
    };
    audio.addEventListener('timeupdate', onTimeUpdate);
    audio.addEventListener('ended', onEnded);
    audio.addEventListener('loadedmetadata', onLoadedMetadata);
    return () => {
      audio.removeEventListener('timeupdate', onTimeUpdate);
      audio.removeEventListener('ended', onEnded);
      audio.removeEventListener('loadedmetadata', onLoadedMetadata);
    };
  }, [dispatch, state.repeatMode, state.queue.length, state.currentTrack?.id]);

  // Simulate progress for tracks without a real audio source
  useEffect(() => {
    if (!state.isPlaying || !state.currentTrack || state.currentTrack.url) return;
    const duration = state.currentTrack.duration || 200;
    const interval = setInterval(() => {
      dispatch({ type: 'SET_PROGRESS', value: prev => {
        const prevNum = typeof prev === 'number' ? prev : 0;
        const next = prevNum + 1 / duration;
        if (next >= 1) {
          if (state.repeatMode === 'one') return 0;
          if (state.repeatMode === 'all' || state.queue.length > 1) {
            dispatch({ type: 'NEXT' });
            return 0;
          }
          dispatch({ type: 'SET_PLAYING', value: false });
          return 0;
        }
        return next;
      }});
    }, 1000);
    return () => clearInterval(interval);
  }, [state.isPlaying, state.currentTrack?.id, state.repeatMode, state.queue.length]);

  const playTrack = useCallback((track, queue) => dispatch({ type: 'PLAY_TRACK', track, queue: queue || SAMPLE_TRACKS }), []);
  const playQueue = useCallback((queue) => dispatch({ type: 'PLAY_QUEUE', queue }), []);
  const togglePlay = useCallback(() => dispatch({ type: 'TOGGLE_PLAY' }), []);
  const next = useCallback(() => dispatch({ type: 'NEXT' }), []);
  const prev = useCallback(() => dispatch({ type: 'PREV' }), []);
  const seek = useCallback((v) => {
    const audio = audioRef.current;
    if (audio.duration && state.currentTrack?.url) {
      audio.currentTime = v * audio.duration;
    }
    dispatch({ type: 'SET_PROGRESS', value: v });
  }, [state.currentTrack?.url]);
  const toggleShuffle = useCallback(() => dispatch({ type: 'TOGGLE_SHUFFLE' }), []);
  const toggleRepeat = useCallback(() => dispatch({ type: 'TOGGLE_REPEAT' }), []);
  const toggleLike = useCallback(() => dispatch({ type: 'TOGGLE_LIKE' }), []);
  const addUserTrack = useCallback((track) => dispatch({ type: 'ADD_USER_TRACK', track }), []);

  useEffect(() => {
    async function loadTracks() {
      try {
        const { data, error } = await supabase.from('songs').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (data) {
          dispatch({ type: 'SET_USER_TRACKS', tracks: data });
        }
      } catch (err) {
        console.error('Error loading tracks from Supabase:', err.message);
      }
    }
    loadTracks();
  }, []);

  return (
    <PlayerContext.Provider value={{ ...state, playTrack, playQueue, togglePlay, next, prev, seek, toggleShuffle, toggleRepeat, toggleLike, addUserTrack }}>
      {children}
    </PlayerContext.Provider>
  );
}

export const usePlayer = () => {
  const ctx = useContext(PlayerContext);
  if (!ctx) throw new Error('usePlayer must be used within PlayerProvider');
  return ctx;
};

export function formatTime(secs) {
  if (!isFinite(secs) || secs < 0) return '0:00';
  const s = Math.floor(secs);
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
}
