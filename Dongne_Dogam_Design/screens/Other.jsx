// Notification popup, Storybook, Dogam screens

const { useState: sUseState, useEffect: sUseEffect } = React;

// ─── In-app notification (overlay) ──────────────────────────────
function NotificationOverlay({ spot, palette, font, onRead, onDismiss, dark, region }) {
  if (!spot) return null;
  const c = window.CAT_COLORS[spot.cat] || palette.accent;
  return (
    <div style={{
      width: '100%', flex: 1, minHeight: 0, background: palette.bg, color: palette.ink,
      fontFamily: font, position: 'relative', overflow: 'hidden',
    }}>
      {/* dimmed map behind */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.35 }}>
        <window.MapCanvas region={region} spots={[spot]} activeId={spot.id}
          palette={palette} height="100%" showRing={false} />
      </div>
      <div style={{ position: 'absolute', inset: 0, background: `linear-gradient(180deg, ${palette.bg}00 0%, ${palette.bg}DD 60%, ${palette.bg} 100%)` }} />

      {/* drop-down toast */}
      <div style={{
        position: 'absolute', top: 12, left: 12, right: 12,
        padding: 14, borderRadius: 18,
        background: palette.surface + 'F5',
        backdropFilter: 'blur(24px)',
        border: `1px solid ${palette.line}`,
        boxShadow: `0 16px 40px rgba(0,0,0,.18)`,
        display: 'flex', gap: 12, alignItems: 'flex-start',
      }}>
        <div style={{
          width: 38, height: 38, borderRadius: 10,
          background: c, color: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: window.FONTS.serif, fontSize: 17, fontWeight: 700, flexShrink: 0,
        }}>{window.CAT_GLYPH[spot.cat]}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div style={{ fontSize: 11.5, fontWeight: 600, color: palette.inkSub, letterSpacing: '.04em' }}>동네도감</div>
            <div style={{ fontSize: 10.5, color: palette.inkMute, fontVariantNumeric: 'tabular-nums' }}>지금</div>
          </div>
          <div style={{ fontSize: 14, fontWeight: 600, marginTop: 1 }}>이 근처에 숨겨진 이야기가 있어요</div>
          <div style={{ fontSize: 12.5, color: palette.inkSub, lineHeight: 1.45, marginTop: 4 }}>
            {spot.summary}
          </div>
        </div>
      </div>

      {/* full sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: palette.surface,
        borderRadius: '24px 24px 0 0',
        padding: '14px 20px 28px',
        boxShadow: `0 -10px 32px rgba(0,0,0,.10)`,
      }}>
        <div style={{ width: 40, height: 4, borderRadius: 2, background: palette.line, margin: '0 auto 16px' }} />

        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 6,
          padding: '4px 10px', borderRadius: 999,
          background: c + '14', color: c,
          fontSize: 11, fontWeight: 600, letterSpacing: '.04em',
        }}>
          <span style={{ width: 5, height: 5, borderRadius: 999, background: c }} />
          1km 이내 · {spot.dist}m
        </div>

        <div style={{
          fontSize: 22, fontWeight: 700, letterSpacing: '-.015em',
          marginTop: 10,
        }}>{spot.name}</div>

        <div style={{
          fontFamily: window.FONTS.serif, fontSize: 14.5, lineHeight: 1.65,
          color: palette.inkSub, marginTop: 10, textWrap: 'pretty',
        }}>
          {spot.past.split('.')[0]}…
        </div>

        <div style={{ display: 'flex', gap: 8, marginTop: 18 }}>
          <button onClick={onDismiss} style={{
            flex: '0 0 auto', padding: '0 18px', height: 48, borderRadius: 14,
            background: 'transparent', border: `1px solid ${palette.line}`,
            color: palette.inkSub, fontSize: 14, fontWeight: 600, cursor: 'pointer', fontFamily: font,
          }}>다음에</button>
          <button onClick={onRead} style={{
            flex: 1, height: 48, borderRadius: 14,
            background: palette.accent, color: '#fff',
            border: 'none', fontSize: 14, fontWeight: 600, cursor: 'pointer', fontFamily: font,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          }}>
            이야기 읽기
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Storybook ──────────────────────────────────────────────────
function Storybook({ spot, palette, font, onCollect, onClose, dark, collected }) {
  if (!spot) return null;
  const c = window.CAT_COLORS[spot.cat] || palette.accent;
  return (
    <div style={{
      width: '100%', flex: 1, minHeight: 0, background: palette.surface, color: palette.ink,
      fontFamily: font, position: 'relative', overflowY: 'auto',
    }}>
      {/* hero photo slot */}
      <div style={{ position: 'relative' }}>
        <window.PhotoSlot width="100%" height={260} hint={window.STORY_HEROES[spot.id] || 'photo placeholder'} palette={palette} radius={0} />
        <div style={{ position: 'absolute', inset: 0, background: `linear-gradient(180deg, rgba(0,0,0,.15) 0%, transparent 30%, transparent 70%, ${palette.surface} 100%)` }} />
        <button onClick={onClose} style={{
          position: 'absolute', top: 14, left: 14, width: 36, height: 36, borderRadius: 999,
          background: palette.surface + 'EE', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          backdropFilter: 'blur(16px)',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>
      </div>

      <div style={{ padding: '18px 24px 120px' }}>
        <window.CategoryChip cat={spot.cat} palette={palette} />
        <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: '-.02em', marginTop: 12, lineHeight: 1.2 }}>{spot.name}</div>
        <div style={{
          display: 'flex', gap: 10, marginTop: 8,
          fontSize: 11.5, color: palette.inkMute, letterSpacing: '.04em',
        }}>
          <span>● 발견 {new Date().toLocaleDateString('ko-KR', { month: 'long', day: 'numeric' })}</span>
          <span>· {spot.dist}m</span>
        </div>

        {/* sections */}
        {[
          { key: 'past', label: '이곳의 과거', body: spot.past },
          { key: 'present', label: '현재의 모습', body: spot.present },
          { key: 'meaning', label: '문화적 의미', body: spot.meaning },
        ].map((sec, i) => (
          <section key={sec.key} style={{ marginTop: 28 }}>
            <div style={{
              fontSize: 10.5, letterSpacing: '.18em', fontWeight: 600,
              color: c, textTransform: 'uppercase', marginBottom: 10,
              display: 'flex', alignItems: 'center', gap: 8,
            }}>
              <span style={{ fontFamily: window.FONTS.mono, color: palette.inkMute }}>0{i+1}</span>
              {sec.label}
            </div>
            <p style={{
              fontFamily: window.FONTS.serif, fontSize: 16, lineHeight: 1.75,
              color: palette.ink, margin: 0, textWrap: 'pretty',
            }}>{sec.body}</p>
          </section>
        ))}

        {/* keywords */}
        <div style={{ marginTop: 32 }}>
          <div style={{
            fontSize: 10.5, letterSpacing: '.18em', fontWeight: 600,
            color: palette.inkMute, textTransform: 'uppercase', marginBottom: 12,
          }}>더 알아볼 키워드</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {spot.keywords.map(k => (
              <span key={k} style={{
                padding: '6px 12px', borderRadius: 999,
                background: palette.bg, border: `1px solid ${palette.line}`,
                fontSize: 12, color: palette.inkSub,
              }}>#{k}</span>
            ))}
          </div>
        </div>
      </div>

      {/* sticky collect bar */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        padding: '14px 20px 22px',
        background: `linear-gradient(180deg, ${palette.surface}00 0%, ${palette.surface} 30%)`,
      }}>
        <button onClick={onCollect} disabled={collected} style={{
          width: '100%', height: 52, borderRadius: 14,
          background: collected ? palette.surfaceAlt : palette.accent,
          color: collected ? palette.inkMute : '#fff',
          border: 'none', fontSize: 15, fontWeight: 600, cursor: collected ? 'default' : 'pointer',
          fontFamily: font, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          boxShadow: collected ? 'none' : `0 6px 20px ${palette.accent}40`,
        }}>
          {collected ? (
            <>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
              도감에 기록됨
            </>
          ) : (
            <>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/>
              </svg>
              스토리 조각 수집하기
            </>
          )}
        </button>
      </div>
    </div>
  );
}

// ─── Dogam (collection) ─────────────────────────────────────────
function DogamScreen({ palette, font, regions, spotsByRegion, collectedIds, onOpen, dark }) {
  return (
    <div style={{
      width: '100%', flex: 1, minHeight: 0, background: palette.bg, color: palette.ink,
      fontFamily: font, overflowY: 'auto',
    }}>
      <div style={{ padding: '8px 24px 12px' }}>
        <div style={{ fontSize: 10.5, letterSpacing: '.18em', fontWeight: 600, color: palette.inkMute, textTransform: 'uppercase' }}>나의 도감</div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: 4 }}>
          <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: '-.02em' }}>스토리 조각</div>
          <div style={{ fontFamily: window.FONTS.serif, fontSize: 22, fontWeight: 600, color: palette.accent, fontVariantNumeric: 'tabular-nums' }}>
            {collectedIds.length}<span style={{ color: palette.inkMute, fontSize: 14 }}>/{regions.reduce((sum, r) => sum + (spotsByRegion[r.id]?.length || 0), 0)}</span>
          </div>
        </div>
      </div>

      <div style={{ padding: '8px 20px 40px', display: 'flex', flexDirection: 'column', gap: 24 }}>
        {regions.map(r => {
          const spots = spotsByRegion[r.id] || [];
          const got = spots.filter(s => collectedIds.includes(s.id));
          const ratio = spots.length ? got.length / spots.length : 0;
          return (
            <section key={r.id}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', padding: '0 4px', marginBottom: 10 }}>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
                  <span style={{ fontFamily: window.FONTS.serif, fontSize: 18, fontWeight: 600 }}>{r.name}</span>
                  <span style={{ fontSize: 11.5, color: palette.inkMute, fontVariantNumeric: 'tabular-nums' }}>{got.length}/{spots.length}</span>
                </div>
                <span style={{ fontSize: 11, color: palette.inkMute, fontFamily: window.FONTS.mono }}>
                  {Math.round(ratio*100)}%
                </span>
              </div>
              <div style={{ padding: '0 4px', marginBottom: 14 }}>
                <window.CompletionBar ratio={ratio} palette={palette} height={3} />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                {spots.map(s => {
                  const collected = collectedIds.includes(s.id);
                  const c = window.CAT_COLORS[s.cat] || palette.accent;
                  return (
                    <div key={s.id} onClick={() => collected && onOpen?.(s)} style={{
                      borderRadius: 14, padding: 12, minHeight: 130,
                      background: collected ? palette.surface : palette.surfaceAlt + '60',
                      border: `1px solid ${palette.line}`,
                      cursor: collected ? 'pointer' : 'default',
                      position: 'relative', overflow: 'hidden',
                      filter: collected ? 'none' : 'grayscale(.6)',
                      opacity: collected ? 1 : 0.55,
                      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
                    }}>
                      <div>
                        <div style={{
                          width: 32, height: 32, borderRadius: 8,
                          background: collected ? c : palette.line,
                          color: collected ? '#fff' : palette.inkMute,
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          fontFamily: window.FONTS.serif, fontSize: 15, fontWeight: 700,
                        }}>{collected ? window.CAT_GLYPH[s.cat] : '?'}</div>
                      </div>
                      <div>
                        <div style={{ fontSize: 13, fontWeight: 600, letterSpacing: '-.005em', lineHeight: 1.25 }}>
                          {collected ? s.name : '미수집'}
                        </div>
                        <div style={{ fontSize: 10.5, color: palette.inkMute, marginTop: 4, letterSpacing: '.04em' }}>
                          {collected ? s.cat : '· · ·'}
                        </div>
                      </div>
                      {!collected && (
                        <svg style={{ position: 'absolute', top: 12, right: 12 }} width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={palette.inkMute} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <rect x="3" y="11" width="18" height="11" rx="2"/>
                          <path d="M7 11V7a5 5 0 0110 0v4"/>
                        </svg>
                      )}
                    </div>
                  );
                })}
              </div>
            </section>
          );
        })}

        {/* share */}
        <button style={{
          marginTop: 8, height: 48, borderRadius: 14,
          background: 'transparent', border: `1px solid ${palette.line}`,
          color: palette.inkSub, fontSize: 13.5, fontWeight: 600, fontFamily: font,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, cursor: 'pointer',
        }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/>
          </svg>
          나의 도감 공유하기
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { NotificationOverlay, Storybook, DogamScreen });
