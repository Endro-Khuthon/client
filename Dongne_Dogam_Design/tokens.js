// Dongne Dogam — Design Tokens
// Warm earth palette · Pretendard · 모던 미니멀 아카이브

window.PALETTES = {
  warm: {
    name: '아이보리·먹·단청',
    bg:        '#FBF7ED',  // 밝은 아이보리 배경
    surface:   '#FFFFFF',  // 순백 카드/시트
    surfaceAlt:'#F4EEDD',  // 살짝 톤 다운된 면
    ink:       '#1F1B16',  // 본문 (먹)
    inkSub:    '#65594A',  // 보조 텍스트
    inkMute:   '#A89C88',  // 약한 텍스트/구분선
    line:      '#EBE3CE',
    accent:    '#C9402F',  // 좀 더 채도 있는 단청 빨강
    accentSub: '#8E2A21',
    gold:      '#D6B266',  // 좀 더 밝은 단청 황
    map:       '#F1E9D2',  // 밝은 지도 베이스
    mapInk:    '#D8CAA6',
  },
  ink: {
    name: '수묵 (mono)',
    bg:        '#FAF8F4',
    surface:   '#FFFFFF',
    surfaceAlt:'#EFECE5',
    ink:       '#141414',
    inkSub:    '#555050',
    inkMute:   '#9A968E',
    line:      '#E5E1D8',
    accent:    '#1F1F1F',
    accentSub: '#000000',
    gold:      '#A89971',
    map:       '#F1EEE6',
    mapInk:    '#D8D2C4',
  },
  hanji: {
    name: '한지·송연',
    bg:        '#F7F2E2',
    surface:   '#FFFCEE',
    surfaceAlt:'#EFE6CC',
    ink:       '#1A2A1F',
    inkSub:    '#5A6657',
    inkMute:   '#9CA191',
    line:      '#E0D7BC',
    accent:    '#4A8255',  // 좀 더 밝은 송연 그린
    accentSub: '#2E5938',
    gold:      '#C9A455',
    map:       '#EEE6CD',
    mapInk:    '#D5C9A6',
  },
};

// 카테고리 색 (단청에서 영감) — 모든 팔레트에서 공유
window.CAT_COLORS = {
  '역사':   '#7E2A22',
  '건축':   '#365E78',
  '인물':   '#5A4A8E',
  '전통문화':'#B5392E',
  '생활문화':'#C4A05A',
  '산업문화':'#3F6B4A',
};

window.CAT_GLYPH = {
  '역사':   '史',
  '건축':   '築',
  '인물':   '人',
  '전통문화':'傳',
  '생활문화':'活',
  '산업문화':'業',
};

window.FONTS = {
  sans:  '"Pretendard", "Pretendard Variable", -apple-system, system-ui, "Apple SD Gothic Neo", sans-serif',
  serif: '"Noto Serif KR", "Nanum Myeongjo", "Apple SD Gothic Neo", serif',
  mono:  '"JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace',
};

// type scale (mobile)
window.TYPE = {
  display: { size: 28, weight: 600, lh: 1.2, ls: -0.02 },
  title:   { size: 20, weight: 600, lh: 1.3, ls: -0.01 },
  body:    { size: 15, weight: 400, lh: 1.55, ls: 0 },
  caption: { size: 12, weight: 500, lh: 1.4, ls: 0.02 },
  label:   { size: 11, weight: 600, lh: 1.2, ls: 0.08 }, // uppercase-ish
};

window.RADII = { sm: 8, md: 12, lg: 18, xl: 24, pill: 999 };
window.SPACING = { xs: 4, sm: 8, md: 12, lg: 16, xl: 24, '2xl': 32 };
