// Shared atoms for Dongne Dogam screens
// Loaded as window.* so all screen files can use them.

const { useState, useEffect, useRef, useMemo } = React;

function CategoryChip({ cat, palette, size = 'sm' }) {
  const c = window.CAT_COLORS[cat] || palette.accent;
  const padY = size === 'sm' ? 3 : 5;
  const padX = size === 'sm' ? 8 : 10;
  const fs = size === 'sm' ? 10.5 : 12;
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: `${padY}px ${padX}px`,
      borderRadius: 999,
      background: `${c}14`,
      color: c,
      fontSize: fs, fontWeight: 600, letterSpacing: '.02em',
      lineHeight: 1,
    }}>
      <span style={{
        width: 14, height: 14, borderRadius: 999,
        background: c, color: '#fff',
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 8.5, fontWeight: 700, fontFamily: window.FONTS.serif,
      }}>{window.CAT_GLYPH[cat] || ''}</span>
      {cat}
    </span>
  );
}

function CompletionBar({ ratio, palette, height = 4 }) {
  return (
    <div style={{
      width: '100%', height, background: palette.surfaceAlt,
      borderRadius: 999, overflow: 'hidden',
    }}>
      <div style={{
        width: `${ratio * 100}%`, height: '100%',
        background: palette.accent,
        transition: 'width .6s cubic-bezier(.2,.8,.2,1)',
      }} />
    </div>
  );
}

function PhotoSlot({ width, height, hint, palette, mono = true, radius = 12 }) {
  // Subtly-striped placeholder, monospace explainer for what to drop here
  const stripe = `repeating-linear-gradient(135deg, ${palette.surfaceAlt} 0 8px, ${palette.bg} 8px 16px)`;
  return (
    <div style={{
      width, height, borderRadius: radius,
      background: stripe,
      border: `1px solid ${palette.line}`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
      filter: mono ? 'saturate(0.2)' : 'none',
    }}>
      <span style={{
        fontFamily: window.FONTS.mono,
        fontSize: 10, color: palette.inkSub,
        background: palette.surface, padding: '4px 8px',
        borderRadius: 4, letterSpacing: 0,
        maxWidth: '85%', textAlign: 'center',
        boxShadow: `0 0 0 1px ${palette.line}`,
      }}>{hint}</span>
    </div>
  );
}

// Simplified topographic-ish map background with custom marker pins
function MapCanvas({ region, spots, activeId, onMarker, palette, height = 400, showRing = true, userPos = { x: 0.5, y: 0.5 }, collectedIds = [] }) {
  const collectedSet = new Set(collectedIds);
  return (
    <div style={{
      position: 'relative', width: '100%', height,
      background: palette.map, overflow: 'hidden',
    }}>
      {/* topographic lines */}
      <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }} viewBox="0 0 100 100" preserveAspectRatio="none">
        <defs>
          <pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse">
            <path d="M 10 0 L 0 0 0 10" fill="none" stroke={palette.mapInk} strokeWidth="0.15" opacity=".5"/>
          </pattern>
        </defs>
        <rect width="100" height="100" fill="url(#grid)"/>
        {/* contour lines */}
        <path d="M -5 30 Q 30 22 60 35 T 110 28" stroke={palette.mapInk} strokeWidth="0.4" fill="none" opacity=".7"/>
        <path d="M -5 50 Q 25 44 55 52 T 110 48" stroke={palette.mapInk} strokeWidth="0.4" fill="none" opacity=".7"/>
        <path d="M -5 72 Q 35 64 65 75 T 110 70" stroke={palette.mapInk} strokeWidth="0.4" fill="none" opacity=".7"/>
        {/* a curvy "river" */}
        <path d="M -5 88 Q 20 70 55 80 T 110 75" stroke={palette.mapInk} strokeWidth="2.5" fill="none" opacity=".55" strokeLinecap="round"/>
        {/* faint roads */}
        <path d="M 20 -5 Q 30 50 25 110" stroke={palette.mapInk} strokeWidth="0.6" fill="none" opacity=".4"/>
        <path d="M 70 -5 Q 60 45 75 110" stroke={palette.mapInk} strokeWidth="0.6" fill="none" opacity=".4"/>
      </svg>

      {/* 1km ring around user */}
      {showRing && (
        <div style={{
          position: 'absolute',
          left: `${userPos.x * 100}%`, top: `${userPos.y * 100}%`,
          width: 220, height: 220,
          marginLeft: -110, marginTop: -110,
          borderRadius: 999,
          border: `1px dashed ${palette.accent}55`,
          background: `radial-gradient(circle, ${palette.accent}10 0%, transparent 70%)`,
          pointerEvents: 'none',
        }} />
      )}

      {/* user pin */}
      {showRing && (
        <div style={{
          position: 'absolute',
          left: `${userPos.x * 100}%`, top: `${userPos.y * 100}%`,
          width: 16, height: 16, marginLeft: -8, marginTop: -8,
          borderRadius: 999, background: palette.accent,
          boxShadow: `0 0 0 4px ${palette.bg}, 0 0 0 5px ${palette.accent}`,
          zIndex: 3,
        }} />
      )}

      {/* spots */}
      {spots.map((s) => {
        const isActive = s.id === activeId;
        const inRange = s.dist <= 1000;
        const collected = collectedSet.has(s.id);
        const size = isActive ? 46 : 38;
        const ring = isActive ? `0 6px 18px ${palette.accent}55, 0 0 0 5px ${palette.surface}, 0 0 0 6px ${palette.accent}` : `0 2px 6px rgba(0,0,0,.16), 0 0 0 3px ${palette.surface}`;

        // Background — collected: striped photo placeholder; not collected: muted surface
        const photoBg = collected
          ? `repeating-linear-gradient(135deg, ${palette.surfaceAlt} 0 5px, ${palette.bg} 5px 10px)`
          : palette.surface;
        const borderColor = collected ? palette.accent : palette.inkMute;

        return (
          <button key={s.id}
            onClick={() => onMarker?.(s.id)}
            aria-label={s.name}
            style={{
              position: 'absolute',
              left: `${s.x * 100}%`, top: `${s.y * 100}%`,
              width: size, height: size,
              marginLeft: -size / 2, marginTop: -size / 2,
              borderRadius: 999,
              border: `1.5px solid ${borderColor}`,
              background: photoBg,
              color: collected ? palette.ink : palette.inkSub,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              padding: 0, cursor: 'pointer',
              boxShadow: ring,
              opacity: !collected && !inRange ? 0.7 : 1,
              transition: 'all .25s cubic-bezier(.2,.8,.2,1)',
              zIndex: isActive ? 4 : 2,
              overflow: 'hidden',
            }}>
            {collected ? (
              // tiny photo placeholder badge — accent dot indicates collected
              <span style={{
                position: 'absolute', right: -2, top: -2,
                width: 14, height: 14, borderRadius: 999,
                background: palette.accent,
                color: '#fff', fontSize: 9, fontWeight: 700,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                border: `2px solid ${palette.surface}`,
              }}>✓</span>
            ) : (
              <span style={{
                fontFamily: window.FONTS.serif,
                fontSize: isActive ? 22 : 18, fontWeight: 600,
                color: palette.inkSub,
                lineHeight: 1,
              }}>?</span>
            )}
          </button>
        );
      })}
    </div>
  );
}

Object.assign(window, { CategoryChip, CompletionBar, PhotoSlot, MapCanvas });
