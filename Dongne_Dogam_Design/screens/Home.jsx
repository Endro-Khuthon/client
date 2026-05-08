// Home screen — 3 variants
// Variant A: 표준 (지도 + 하단 카드 스와이프)
// Variant B: 도감 우선 (상단 progress + 미니맵 + 카드 list)
// Variant C: 산책 모드 (full-bleed map + glass card)

const { useState: hUseState, useEffect: hUseEffect } = React;

function HomeShell({ children, palette, font, dark }) {
  return (
    <div style={{
      width: '100%', flex: 1, minHeight: 0,
      background: palette.bg, color: palette.ink,
      fontFamily: font, position: 'relative', overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>{children}</div>
  );
}

function HomeTopBar({ region, regions, onChangeRegion, palette, completion }) {
  return (
    <div style={{
      padding: '8px 20px 12px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      gap: 12,
    }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <div style={{
          fontSize: 10.5, letterSpacing: '.18em', fontWeight: 600,
          color: palette.inkMute, textTransform: 'uppercase',
        }}>NOW EXPLORING</div>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          fontSize: 19, fontWeight: 700, letterSpacing: '-.01em',
        }}>
          {region.name}
          <svg width="12" height="12" viewBox="0 0 12 12" style={{ opacity: .5 }}><path d="M3 4.5l3 3 3-3" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </div>
      </div>
      <button style={{
        width: 38, height: 38, borderRadius: 999,
        background: palette.surface, border: `1px solid ${palette.line}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer', color: palette.ink,
      }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
          <path d="M2 3h6l3 18 3-18h6"/>
        </svg>
      </button>
    </div>
  );
}

function SpotCard({ spot, palette, onTap, focused, font }) {
  const c = window.CAT_COLORS[spot.cat] || palette.accent;
  const inRange = spot.dist <= 1000;
  return (
    <div onClick={onTap} style={{
      width: '100%', minHeight: 178,
      background: palette.surface,
      borderRadius: 18,
      padding: 16,
      border: `1px solid ${palette.line}`,
      boxShadow: focused
        ? `0 12px 32px rgba(0,0,0,.10), 0 2px 0 ${c}`
        : `0 4px 16px rgba(0,0,0,.05)`,
      display: 'flex', flexDirection: 'column', gap: 10,
      cursor: 'pointer', transition: 'all .25s',
      fontFamily: font,
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 10 }}>
        <window.CategoryChip cat={spot.cat} palette={palette} />
        <div style={{
          fontSize: 11.5, fontWeight: 600, color: inRange ? palette.accent : palette.inkMute,
          display: 'flex', alignItems: 'center', gap: 4, fontVariantNumeric: 'tabular-nums',
        }}>
          {inRange ? '●' : '○'} {spot.dist}m
        </div>
      </div>
      <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-.01em' }}>{spot.name}</div>
      <div style={{ fontSize: 13, lineHeight: 1.5, color: palette.inkSub, textWrap: 'pretty' }}>
        {spot.summary}
      </div>
      <div style={{ marginTop: 'auto', display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: 4 }}>
        <div style={{ fontSize: 10.5, color: palette.inkMute, letterSpacing: '.1em', fontWeight: 600 }}>
          {inRange ? '읽을 수 있어요' : `${spot.dist - 1000}m 더 가까이`}
        </div>
        <div style={{
          width: 32, height: 32, borderRadius: 999,
          background: inRange ? palette.accent : palette.surfaceAlt,
          color: inRange ? '#fff' : palette.inkMute,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
            {inRange
              ? <path d="M5 12h14M13 6l6 6-6 6"/>
              : <><rect x="6" y="11" width="12" height="9" rx="1"/><path d="M9 11V8a3 3 0 016 0v3"/></>}
          </svg>
        </div>
      </div>
    </div>
  );
}

function CardSwipeRow({ spots, activeIdx, onChangeIdx, palette, font, onOpen }) {
  const ref = React.useRef(null);
  return (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 22 }}>
      <div ref={ref} style={{
        display: 'flex', gap: 12, padding: '0 20px',
        overflowX: 'auto', scrollSnapType: 'x mandatory',
        scrollbarWidth: 'none',
      }}>
        {spots.map((s, i) => (
          <div key={s.id} style={{
            flex: '0 0 86%', scrollSnapAlign: 'center',
            transform: i === activeIdx ? 'scale(1)' : 'scale(.97)',
            transition: 'transform .25s',
          }}
          onClick={() => { onChangeIdx?.(i); onOpen?.(s); }}>
            <SpotCard spot={s} palette={palette} focused={i === activeIdx} font={font} onTap={() => { onChangeIdx?.(i); onOpen?.(s); }} />
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', gap: 5, marginTop: 12 }}>
        {spots.map((_, i) => (
          <div key={i} style={{
            width: i === activeIdx ? 18 : 5, height: 5, borderRadius: 999,
            background: i === activeIdx ? palette.accent : palette.line,
            transition: 'all .25s',
          }} />
        ))}
      </div>
    </div>
  );
}

// ─── Variant A: standard ────────────────────────────────────────
function HomeA({ palette, font, region, regions, spots, onOpenStory, onChangeRegion, completion, dark }) {
  const [active, setActive] = hUseState(0);
  return (
    <HomeShell palette={palette} font={font} dark={dark}>
      <HomeTopBar region={region} regions={regions} onChangeRegion={onChangeRegion} palette={palette} completion={completion} />
      <div style={{ padding: '0 20px 10px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          fontSize: 11.5, color: palette.inkSub, marginBottom: 8,
        }}>
          <span><b style={{ color: palette.ink }}>{completion.collected}</b> / {completion.total} 수집</span>
          <span style={{ color: palette.inkMute, fontFamily: window.FONTS.mono, fontSize: 10 }}>1km 안에 {spots.filter(s => s.dist <= 1000).length}곳</span>
        </div>
        <window.CompletionBar ratio={completion.collected / completion.total} palette={palette} />
      </div>
      <div style={{ position: 'relative', flex: 1, minHeight: 0 }}>
        <window.MapCanvas region={region} spots={spots} activeId={spots[active]?.id}
          onMarker={(id) => setActive(spots.findIndex(s => s.id === id))}
          palette={palette} height="100%" />
        <CardSwipeRow spots={spots} activeIdx={active} onChangeIdx={setActive}
          palette={palette} font={font} onOpen={onOpenStory} />
      </div>
    </HomeShell>
  );
}

// ─── Variant B: 도감 우선 ───────────────────────────────────────
function HomeB({ palette, font, region, regions, spots, onOpenStory, onChangeRegion, completion, dark }) {
  const [active, setActive] = hUseState(0);
  return (
    <HomeShell palette={palette} font={font} dark={dark}>
      {/* hero band */}
      <div style={{ padding: '8px 20px 16px', background: palette.surface, borderBottom: `1px solid ${palette.line}` }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontSize: 10.5, letterSpacing: '.18em', fontWeight: 600, color: palette.inkMute, textTransform: 'uppercase' }}>지역 도감</div>
            <div style={{ fontSize: 22, fontWeight: 700, marginTop: 2, letterSpacing: '-.01em' }}>{region.name}</div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{
              fontFamily: window.FONTS.serif, fontSize: 28, fontWeight: 600,
              color: palette.accent, lineHeight: 1, fontVariantNumeric: 'tabular-nums',
            }}>{completion.collected}<span style={{ color: palette.inkMute, fontSize: 18 }}>/{completion.total}</span></div>
            <div style={{ fontSize: 10.5, color: palette.inkMute, marginTop: 4, letterSpacing: '.1em' }}>완성</div>
          </div>
        </div>
        <div style={{ marginTop: 14 }}>
          <window.CompletionBar ratio={completion.collected / completion.total} palette={palette} height={6} />
        </div>
      </div>

      {/* mini map */}
      <div style={{ padding: 16, paddingBottom: 8 }}>
        <div style={{ borderRadius: 14, overflow: 'hidden', border: `1px solid ${palette.line}` }}>
          <window.MapCanvas region={region} spots={spots} activeId={spots[active]?.id}
            onMarker={(id) => setActive(spots.findIndex(s => s.id === id))}
            palette={palette} height={170} />
        </div>
      </div>

      {/* list */}
      <div style={{ padding: '4px 16px 20px', display: 'flex', flexDirection: 'column', gap: 8, overflowY: 'auto', flex: 1 }}>
        {spots.map((s, i) => {
          const c = window.CAT_COLORS[s.cat] || palette.accent;
          const inRange = s.dist <= 1000;
          return (
            <div key={s.id} onClick={() => onOpenStory?.(s)} style={{
              padding: 12, borderRadius: 14,
              background: palette.surface, border: `1px solid ${palette.line}`,
              display: 'flex', gap: 12, alignItems: 'center', cursor: 'pointer',
            }}>
              <div style={{
                width: 38, height: 38, borderRadius: 999,
                background: inRange ? c : palette.surfaceAlt,
                color: inRange ? '#fff' : palette.inkMute,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: window.FONTS.serif, fontSize: 16, fontWeight: 700, flexShrink: 0,
              }}>{window.CAT_GLYPH[s.cat]}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14.5, fontWeight: 600, letterSpacing: '-.01em' }}>{s.name}</div>
                <div style={{ fontSize: 11.5, color: palette.inkSub, marginTop: 2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {s.cat} · {s.summary}
                </div>
              </div>
              <div style={{
                fontSize: 11, fontWeight: 600,
                color: inRange ? palette.accent : palette.inkMute,
                fontVariantNumeric: 'tabular-nums', flexShrink: 0,
              }}>{s.dist < 1000 ? `${s.dist}m` : `${(s.dist/1000).toFixed(1)}km`}</div>
            </div>
          );
        })}
      </div>
    </HomeShell>
  );
}

// ─── Variant C: 산책 모드 (full-bleed) ──────────────────────────
function HomeC({ palette, font, region, regions, spots, onOpenStory, onChangeRegion, completion, dark, collectedIds = [] }) {
  const [active, setActive] = hUseState(0);
  const cur = spots[active];
  const c = window.CAT_COLORS[cur.cat] || palette.accent;
  const inRange = cur.dist <= 1000;
  return (
    <HomeShell palette={palette} font={font} dark={dark}>
      <div style={{ position: 'absolute', inset: 0 }}>
        <window.MapCanvas region={region} spots={spots} activeId={cur.id}
          onMarker={(id) => setActive(spots.findIndex(s => s.id === id))}
          palette={palette} height="100%" collectedIds={collectedIds} />
      </div>

      {/* top floating: region + completion */}
      <div style={{
        position: 'absolute', top: 12, left: 16, right: 16,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      }}>
        <div style={{
          padding: '8px 14px', borderRadius: 999,
          background: palette.surface + 'EE',
          backdropFilter: 'blur(20px)',
          border: `1px solid ${palette.line}`,
          fontSize: 13, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 6,
        }}>
          <span style={{ width: 6, height: 6, borderRadius: 999, background: palette.accent }} />
          {region.name}
        </div>
        <div style={{
          padding: '8px 14px', borderRadius: 999,
          background: palette.surface + 'EE',
          backdropFilter: 'blur(20px)',
          border: `1px solid ${palette.line}`,
          fontSize: 13, fontWeight: 600,
          fontVariantNumeric: 'tabular-nums',
        }}>
          {completion.collected}<span style={{ color: palette.inkMute }}>/{completion.total}</span>
        </div>
      </div>

      {/* glass card bottom sheet */}
      <div style={{
        position: 'absolute', left: 16, right: 16, bottom: 22,
        padding: 18, borderRadius: 22,
        background: palette.surface + 'F2',
        backdropFilter: 'blur(28px)',
        border: `1px solid ${palette.line}`,
        boxShadow: `0 20px 50px rgba(0,0,0,.18)`,
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8, marginBottom: 8 }}>
          <window.CategoryChip cat={cur.cat} palette={palette} />
          <div style={{
            fontSize: 11.5, fontWeight: 600, color: inRange ? palette.accent : palette.inkMute,
            display: 'flex', alignItems: 'center', gap: 4, fontVariantNumeric: 'tabular-nums',
          }}>
            {inRange ? '● 1km 이내' : `○ ${cur.dist}m`}
          </div>
        </div>
        <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-.015em', marginBottom: 6 }}>{cur.name}</div>
        <div style={{ fontSize: 13.5, lineHeight: 1.55, color: palette.inkSub, textWrap: 'pretty' }}>
          {cur.summary}
        </div>
        <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
          <button onClick={() => onOpenStory?.(cur)} style={{
            flex: 1, height: 44, borderRadius: 14,
            background: inRange ? palette.accent : palette.surfaceAlt,
            color: inRange ? '#fff' : palette.inkMute,
            border: 'none', fontSize: 14, fontWeight: 600, cursor: 'pointer',
            fontFamily: font,
          }}>
            {inRange ? '이야기 읽기' : '더 가까이 가야 해요'}
          </button>
          <button style={{
            width: 44, height: 44, borderRadius: 14,
            background: palette.surface, border: `1px solid ${palette.line}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer', color: palette.ink,
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="15 18 9 12 15 6" transform="rotate(180 12 12)"/>
            </svg>
          </button>
        </div>
        {/* dots */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: 5, marginTop: 14 }}>
          {spots.map((_, i) => (
            <div key={i} onClick={() => setActive(i)} style={{
              width: i === active ? 18 : 5, height: 5, borderRadius: 999,
              background: i === active ? palette.accent : palette.line,
              transition: 'all .25s', cursor: 'pointer',
            }} />
          ))}
        </div>
      </div>
    </HomeShell>
  );
}

Object.assign(window, { HomeA, HomeB, HomeC });
