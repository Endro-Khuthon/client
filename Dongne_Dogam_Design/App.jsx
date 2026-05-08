// App shell — design canvas with iOS frames + tweaks panel

const { useState: aUseState, useEffect: aUseEffect, useMemo: aUseMemo } = React;

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "paletteKey": "warm",
  "fontKey": "sans",
  "regionId": "seongsu",
  "alertSpotId": "ss01",
  "homeVariant": "A",
  "showAlert": false,
  "collectedSeed": ["ss02", "jj01", "yd02"]
}/*EDITMODE-END*/;

function PaletteSwatchBar({ palette }) {
  return (
    <div style={{ display: 'flex', gap: 4, height: 14, borderRadius: 4, overflow: 'hidden' }}>
      {[palette.bg, palette.surface, palette.ink, palette.accent, palette.gold].map((c, i) => (
        <div key={i} style={{ flex: 1, background: c }} />
      ))}
    </div>
  );
}

function ScreenFrame({ label, children, palette, dark = false }) {
  // device size: roughly iPhone 15 Pro (393×852)
  return (
    <window.IOSDevice dark={dark}>
      <div style={{ display: 'flex', flexDirection: 'column', height: '100%', width: '100%' }}>
        <window.IOSStatusBar dark={dark} />
        <div style={{ flex: 1, minHeight: 0, position: 'relative', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
          {children}
        </div>
      </div>
    </window.IOSDevice>
  );
}

function HomeFrame({ variant, ...rest }) {
  const C = variant === 'B' ? window.HomeB : variant === 'C' ? window.HomeC : window.HomeA;
  return <C {...rest} onOpenStory={rest.onOpen} />;
}

function App() {
  const [t, setTweak] = window.useTweaks(TWEAK_DEFAULTS);

  const palette = window.PALETTES[t.paletteKey] || window.PALETTES.warm;
  const font = window.FONTS[t.fontKey] || window.FONTS.sans;
  const region = window.REGIONS.find(r => r.id === t.regionId) || window.REGIONS[0];
  const spots = window.SPOTS[region.id] || [];
  const alertSpot = spots.find(s => s.id === t.alertSpotId) || spots[0];

  const [collected, setCollected] = aUseState(new Set(t.collectedSeed || []));
  const [openSpot, setOpenSpot] = aUseState(null);

  const completion = {
    collected: spots.filter(s => collected.has(s.id)).length,
    total: spots.length,
  };

  // Inject CSS for Pretendard
  aUseEffect(() => {
    if (document.getElementById('pretendard-link')) return;
    const link = document.createElement('link');
    link.id = 'pretendard-link';
    link.rel = 'stylesheet';
    link.href = 'https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css';
    document.head.appendChild(link);
    const link2 = document.createElement('link');
    link2.rel = 'stylesheet';
    link2.href = 'https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap';
    document.head.appendChild(link2);
  }, []);

  const variantSpotsCommon = {
    palette, font, region, regions: window.REGIONS,
    spots, completion, onOpen: (s) => setOpenSpot(s), dark: false,
    collectedIds: [...collected],
  };

  return (
    <>
      <window.DesignCanvas>
        <window.DCSection id="overview" title="동네도감" subtitle="위치 기반 문화 탐험 — iOS 모바일 (393×852)">

          <window.DCArtboard id="home-c" label="① 홈 · 산책 모드" width={393} height={852}>
            <ScreenFrame label="Home" palette={palette}>
              <HomeFrame variant="C" {...variantSpotsCommon} />
            </ScreenFrame>
          </window.DCArtboard>

          <window.DCArtboard id="alert" label="② 인앱 알림 — 1km 진입" width={393} height={852}>
            <ScreenFrame label="Alert" palette={palette}>
              <window.NotificationOverlay
                spot={alertSpot} palette={palette} font={font} region={region}
                onRead={() => setOpenSpot(alertSpot)}
                onDismiss={() => {}} />
            </ScreenFrame>
          </window.DCArtboard>

          <window.DCArtboard id="story" label="③ 스토리북" width={393} height={852}>
            <ScreenFrame label="Story" palette={palette}>
              <window.Storybook
                spot={alertSpot} palette={palette} font={font}
                collected={collected.has(alertSpot?.id)}
                onCollect={() => setCollected(prev => new Set([...prev, alertSpot.id]))}
                onClose={() => {}} />
            </ScreenFrame>
          </window.DCArtboard>

          <window.DCArtboard id="dogam" label="④ 도감 — 지역별 완성률" width={393} height={852}>
            <ScreenFrame label="Dogam" palette={palette}>
              <window.DogamScreen
                palette={palette} font={font}
                regions={window.REGIONS} spotsByRegion={window.SPOTS}
                collectedIds={[...collected]}
                onOpen={() => {}} />
            </ScreenFrame>
          </window.DCArtboard>

        </window.DCSection>

        <window.DCSection id="flow" title="흐름" subtitle="홈에서 알림이 뜨고, 이야기를 읽고, 도감이 채워진다">
          <window.DCPostIt top={20} left={20} width={260}>
            모던 미니멀 + 따뜻한 흙빛 톤 + Pretendard.{'\n'}
            카테고리는 한자 한 글자로 압축 (史·築·人·傳·活·業){'\n'}
            본문은 서체로 분위기 (Tweaks에서 세리프로 토글){'\n'}
            오른쪽 아래 Tweaks 패널에서 팔레트/폰트/지역 변경 가능
          </window.DCPostIt>
        </window.DCSection>
      </window.DesignCanvas>

      {/* Tweaks panel — host registers the toolbar toggle for this */}
      <window.TweaksPanel title="Tweaks">
        <window.TweakSection label="컬러 팔레트" />
        <window.TweakColor
          label="팔레트"
          value={window.PALETTES[t.paletteKey].bg}
          options={Object.values(window.PALETTES).map(p => [p.bg, p.surface, p.ink, p.accent, p.gold])}
          onChange={(v) => {
            const key = Object.keys(window.PALETTES).find(k => window.PALETTES[k].bg === v[0]);
            if (key) setTweak('paletteKey', key);
          }}
        />
        <div style={{
          fontSize: 10.5, color: 'rgba(41,38,27,.55)',
          padding: '2px 0',
        }}>{window.PALETTES[t.paletteKey].name}</div>

        <window.TweakSection label="타이포그래피" />
        <window.TweakRadio
          label="한글 본문"
          value={t.fontKey}
          options={[{ value: 'sans', label: 'Sans' }, { value: 'serif', label: 'Serif' }]}
          onChange={(v) => setTweak('fontKey', v)}
        />

        <window.TweakSection label="지역" />
        <window.TweakRadio
          label="현재 위치"
          value={t.regionId}
          options={window.REGIONS.map(r => ({ value: r.id, label: r.short }))}
          onChange={(v) => setTweak('regionId', v)}
        />

        <window.TweakSection label="알림 시뮬레이션" />
        <window.TweakSelect
          label="대상 스팟"
          value={t.alertSpotId}
          options={(window.SPOTS[t.regionId] || []).map(s => ({ value: s.id, label: `${s.dist}m · ${s.name}` }))}
          onChange={(v) => setTweak('alertSpotId', v)}
        />
        <window.TweakButton label="1km 진입 알림 트리거" onClick={() => {
          setTweak('alertSpotId', t.alertSpotId);
        }} />

        <window.TweakSection label="도감 상태" />
        <window.TweakButton label="수집 기록 초기화" onClick={() => setCollected(new Set())} />
        <div style={{ fontSize: 10.5, color: 'rgba(41,38,27,.55)' }}>
          현재 {collected.size}개 수집됨
        </div>
      </window.TweaksPanel>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
