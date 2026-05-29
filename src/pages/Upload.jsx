import { useState, useRef } from 'react';
import { usePlayer } from '../context/PlayerContext';
import { supabase } from '../supabase';
import './Upload.css';

let nextId = 100;

export default function Upload() {
  const { addUserTrack, playTrack } = usePlayer();
  const [dragActive, setDragActive] = useState(false);
  const [uploaded, setUploaded] = useState([]);
  const [processing, setProcessing] = useState(false);
  const fileRef = useRef(null);

  async function handleFiles(files) {
    const audioFiles = Array.from(files).filter(f => f.type.startsWith('audio/'));
    if (!audioFiles.length) return;
    setProcessing(true);
    
    try {
      for (const file of audioFiles) {
        // 1. Upload to storage
        const fileName = `${Date.now()}-${file.name.replace(/\s+/g, '_')}`;
        const { data: uploadData, error: uploadError } = await supabase.storage
          .from('songs')
          .upload(fileName, file);
        
        if (uploadError) throw uploadError;

        // 2. Get public URL
        const { data: urlData } = supabase.storage
          .from('songs')
          .getPublicUrl(fileName);
        
        const publicUrl = urlData.publicUrl;

        // 3. Save to database
        const track = {
          title: file.name.replace(/\.[^.]+$/, ''),
          artist: 'My Upload',
          album: 'Cloud',
          duration: 180, // Default if not possible to calculate easily
          artClass: `art-${Math.ceil(Math.random() * 8)}`,
          url: publicUrl,
        };

        const { data: dbData, error: dbError } = await supabase
          .from('songs')
          .insert([track])
          .select()
          .single();

        if (dbError) throw dbError;

        addUserTrack(dbData);
        setUploaded(prev => [dbData, ...prev]);
      }
    } catch (err) {
      console.error('Upload error:', err.message);
      alert('Error uploading file. Make sure you have a "songs" bucket and a "songs" table in Supabase.');
    } finally {
      setProcessing(false);
    }
  }

  const ART_CLASSES = ['art-1','art-2','art-3','art-4','art-5','art-6','art-7','art-8'];

  const SAMPLE_FORMAT = [
    { name: 'MP3', icon: '🎵' },
    { name: 'FLAC', icon: '🎶' },
    { name: 'WAV', icon: '🎸' },
    { name: 'M4A / AAC', icon: '🎼' },
    { name: 'OGG', icon: '🎺' },
  ];

  return (
    <div className="screen">
      <header className="top-bar">
        <h1 style={{fontSize:'1.3rem'}}>Upload Music</h1>
      </header>

      <div className="screen-inner" style={{paddingTop:'calc(56px + 16px)'}}>

        {/* Drop zone */}
        <div
          className={`drop-zone ${dragActive ? 'active' : ''}`}
          onDragOver={e => { e.preventDefault(); setDragActive(true); }}
          onDragLeave={() => setDragActive(false)}
          onDrop={e => { e.preventDefault(); setDragActive(false); handleFiles(e.dataTransfer.files); }}
          onClick={() => fileRef.current?.click()}
        >
          <input
            ref={fileRef}
            type="file"
            accept="audio/*"
            multiple
            style={{display:'none'}}
            onChange={e => handleFiles(e.target.files)}
          />
          {processing ? (
            <div className="processing">
              <div className="spinner" />
              <p>Processing…</p>
            </div>
          ) : (
            <>
              <span className="material-icons-round" style={{fontSize:48, color: dragActive ? 'var(--accent-green)' : 'var(--text-muted)', transition:'var(--transition)'}}>cloud_upload</span>
              <p className="drop-title">{dragActive ? 'Drop to upload' : 'Upload your music'}</p>
              <p className="drop-sub">Drag & drop files, or tap to browse</p>
              <button className="btn-primary" style={{marginTop:16}} onClick={e => { e.stopPropagation(); fileRef.current?.click(); }}>
                <span className="material-icons-round sm">folder_open</span> Browse Files
              </button>
            </>
          )}
        </div>

        {/* Supported formats */}
        <div className="formats-grid">
          {SAMPLE_FORMAT.map(f => (
            <div key={f.name} className="format-chip">
              <span>{f.icon}</span>
              <span style={{fontSize:'0.75rem', fontWeight:600}}>{f.name}</span>
            </div>
          ))}
        </div>

        {/* Uploaded tracks */}
        {uploaded.length > 0 && (
          <section>
            <div className="section-header">
              <h2>Uploaded ({uploaded.length})</h2>
            </div>
            {uploaded.map(track => (
              <div key={track.id} className="upload-track-row">
                <div className={`track-art ${track.artClass}`}>
                  <span className="material-icons-round sm" style={{color:'rgba(255,255,255,0.5)'}}>audio_file</span>
                </div>
                <div className="track-info">
                  <p className="name">{track.title}</p>
                  <p className="artist" style={{color:'var(--accent-green)'}}>✓ Uploaded successfully</p>
                </div>
                <button className="icon-btn" onClick={() => playTrack(track)} aria-label="Play">
                  <span className="material-icons-round sm">play_circle</span>
                </button>
              </div>
            ))}
          </section>
        )}

        {/* Tips */}
        <div className="tips-card">
          <h3 style={{fontSize:'0.9rem', marginBottom:12}}>💡 Best Practices</h3>
          <ul className="tips-list">
            <li>Use lossless formats (FLAC/WAV) for best quality</li>
            <li>Make sure files have proper ID3 tags</li>
            <li>Files are private to your account only</li>
          </ul>
        </div>

      </div>
    </div>
  );
}
