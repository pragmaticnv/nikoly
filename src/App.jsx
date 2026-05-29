import { useState } from 'react';
import { PlayerProvider } from './context/PlayerContext';
import BottomNav from './components/BottomNav';
import MiniPlayer from './components/MiniPlayer';
import Home from './pages/Home';
import Library from './pages/Library';
import NowPlaying from './pages/NowPlaying';
import Upload from './pages/Upload';
import Insights from './pages/Insights';
import Settings from './pages/Settings';

export default function App() {
  const [tab, setTab] = useState('home');
  const [showNowPlaying, setShowNowPlaying] = useState(false);

  const tabs = { home: Home, library: Library, upload: Upload, insights: Insights, settings: Settings };
  const PageComponent = tabs[tab] || Home;

  return (
    <PlayerProvider>
      <div className="app-shell">
        {/* Main screen */}
        <main className="app-main">
          <PageComponent
            onOpenNowPlaying={() => setShowNowPlaying(true)}
            onNavigateTo={(t) => setTab(t)}
          />
        </main>

        {/* Mini player */}
        <MiniPlayer onOpenNowPlaying={() => setShowNowPlaying(true)} />

        {/* Bottom nav */}
        <BottomNav active={tab} onChange={setTab} />

        {/* Now Playing full-screen overlay */}
        {showNowPlaying && (
          <div style={{ position: 'fixed', inset: 0, zIndex: 300 }}>
            <NowPlaying onClose={() => setShowNowPlaying(false)} navigate={(to) => {
              if (to === -1) setShowNowPlaying(false);
              else if (to === '/insights') { setShowNowPlaying(false); setTab('insights'); }
              else if (to === '/library') { setShowNowPlaying(false); setTab('library'); }
            }} />
          </div>
        )}
      </div>
    </PlayerProvider>
  );
}
