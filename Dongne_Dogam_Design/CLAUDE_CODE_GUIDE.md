# Claude Code 연동 가이드 — 동네도감 디자인 → Flutter

> 이 문서는 HTML로 만든 디자인(`Dongne Dogam.html`)을 Claude Code 환경에서 Flutter 코드로 옮길 때 참고할 핸드오프 노트입니다.
> 지금 단계는 **가이드 문서만**입니다. 실제 dart 토큰 export, 위젯 스펙 자동 생성 등은 디자인이 확정된 다음에 추가하면 됩니다.

---

## 1. 디자인 파일 구조

```
Dongne Dogam.html        ← 진입점 (모든 스크립트 로드)
tokens.js                ← 컬러 팔레트 / 폰트 / 카테고리 색
data.js                  ← 데모 스토리 스팟 데이터 (3개 지역 × 5개 = 15)
screens/
  atoms.jsx              ← 공용 컴포넌트 (CategoryChip, MapCanvas, PhotoSlot, CompletionBar)
  Home.jsx               ← 홈 3변형 (HomeA/HomeB/HomeC)
  Other.jsx              ← NotificationOverlay, Storybook, DogamScreen
App.jsx                  ← 디자인 캔버스 + Tweaks 패널 wiring
design-canvas.jsx        ← 캔버스 starter
ios-frame.jsx            ← iPhone 프레임 starter
tweaks-panel.jsx         ← Tweaks 패널 starter
```

각 화면이 1:1로 Flutter 위젯에 대응됩니다 — 화면 이름은 그대로 가져가도 됩니다.

| HTML 파일 | Flutter 위젯 (제안) |
|--|--|
| `HomeC` (산책 모드 — 확정) | `lib/features/home/home_screen.dart` |
| `NotificationOverlay` | `lib/features/home/widgets/proximity_notification.dart` |
| `Storybook` | `lib/features/story/story_screen.dart` |
| `DogamScreen` | `lib/features/dogam/dogam_screen.dart` |
| `MapCanvas` | `flutter_map` 또는 `google_maps_flutter` 사용 — 마커 디자인만 참고 |

---

## 2. Claude Code에 디자인을 넘기는 방법

Claude Code는 로컬 파일을 직접 읽을 수 있습니다. 두 가지 방식 중 하나를 쓰세요.

### 방식 A — 디자인 파일을 Flutter 프로젝트 안에 복사

```bash
# Flutter 프로젝트 루트에서
mkdir -p docs/design
# 이 omni 프로젝트에서 다음 파일들을 docs/design/ 으로 복사:
#   Dongne Dogam.html
#   tokens.js
#   data.js
#   screens/*.jsx
#   App.jsx
```

그 다음 Claude Code 세션에서:

```
docs/design/ 안의 디자인 파일들을 참고해서
lib/features/home/home_screen.dart 를 Variant A 기준으로 구현해줘.
컬러는 tokens.js 의 PALETTES.warm 을 그대로 dart 상수로 옮기고,
spot 데이터 모델은 data.js 의 SPOTS 구조를 따라줘.
```

### 방식 B — 디자인은 별도 폴더, 심볼릭 링크로 노출

```bash
ln -s /path/to/dongne-dogam-design docs/design
```

장점: 디자인을 omni에서 계속 수정하면 그게 곧 Flutter 프로젝트에서도 최신 상태로 보임.

---

## 3. CLAUDE.md 에 추가할 줄

이미 첨부하신 `CLAUDE.md` 끝에 다음을 붙이세요:

```md
## 디자인 참조

UI 구현 시 `docs/design/Dongne Dogam.html` 을 진실의 출처로 삼는다.
- 컬러/타이포: `docs/design/tokens.js`
- 화면 구조: `docs/design/screens/*.jsx`
- 데이터 스키마(API 응답 모양): `docs/design/data.js`

규칙:
1. 색상값을 임의로 만들지 않는다. tokens.js 에 없는 색은 디자이너에게 물어본다.
2. 한글 본문은 Pretendard, 강조 본문은 Noto Serif KR. 다른 폰트는 추가하지 않는다.
3. 1km 이내 / 이외 상태는 반드시 시각적으로 구분한다 (활성 색상 vs 회색 + 자물쇠).
4. 카테고리 색상 (역사/건축/인물/전통문화/생활문화/산업문화) 6종은 tokens.js 의 CAT_COLORS 가 정답.
```

---

## 4. Claude Code 세션 권장 프롬프트

화면 단위로 잘게 쪼개세요. 한 번에 하나씩.

### 4-1. 디자인 토큰 dart 변환

```
docs/design/tokens.js 의 PALETTES.warm 만 보고
lib/core/design/tokens.dart 를 만들어줘.

요구사항:
- ColorScheme 으로 변환하지 말고 그대로 색상 상수 클래스로 둬 (예: AppColors.bg, AppColors.accent)
- ThemeExtension 으로 카테고리 색상도 노출 (CAT_COLORS 6개)
- 산세리프 텍스트테마는 Pretendard, 본문 강조는 Noto Serif KR
- 새 색상이나 텍스트 스타일 만들지 마. tokens.js 에 있는 것만.
```

### 4-2. 데이터 모델

```
docs/design/data.js 의 SPOTS 구조를 보고
lib/data/models/story_spot.dart 를 만들어줘.

요구사항:
- freezed 또는 plain dataclass 둘 다 좋음. 백로그 BE-02 의 Pydantic 모델과 키 이름이 일치해야 함
  (id, name, category, lat, lng, summary, story_past, story_present, story_meaning, keywords)
- 디자인의 'cat', 'past', 'present', 'meaning' 은 데모용 단축 키. 실제 API 키는 백로그 기준.
- fromJson/toJson 만들고 그 외 헬퍼는 만들지 마.
```

### 4-3. 홈 화면 (산책 모드 — HomeC)

```
docs/design/screens/Home.jsx 의 HomeC 컴포넌트를 보고
lib/features/home/home_screen.dart 를 만들어줘.

이 화면은 풀블리드 지도 위에 글래스 카드가 떠 있는 구조:
1. 전체 배경 = MapCanvas (full bleed)
2. 상단 좌우 floating pill — 지역 이름 / 도감 진행률 (n/m)
3. 하단 글래스 카드 — 현재 활성 스팟의 카테고리/거리/이름/요약/액션 버튼
4. 페이지 인디케이터 (점)

마커 모양 (atoms.jsx 의 MapCanvas 참고):
- 미수집 (도감에 없음): 흰 원 + 가운데 "?" (세리프)
- 수집됨 (도감에 있음): 장소 사진을 동그랗게 자른 아이콘 + 우상단에 단청 빨강 ✓ 배지
- 활성 마커: 크기 ↑, ring shadow
- 1km 이내인지는 마커 색이 아니라 글래스 카드의 거리 표시로만 알림

지도 라이브러리는 flutter_map(OpenStreetMap)으로. API 키 설정은 하지 마.
스팟 데이터는 일단 lib/data/services/mock_spot_service.dart 의 mock 으로 받아.
수집된 스팟 ID 집합은 Riverpod (또는 Provider) 로 노출해서 마커 위젯이 watch 하게 해.
```

### 4-4. 알림 팝업

```
docs/design/screens/Other.jsx 의 NotificationOverlay 를 보고
lib/features/home/widgets/proximity_notification.dart 만들어줘.

- showModalBottomSheet 으로 띄우고 isScrollControlled: true
- 상단 토스트는 별도. ScaffoldMessenger 의 SnackBar 가 아니라 OverlayEntry 로 14px 여백 두고 띄움
- 'past' 의 첫 문장만 미리보기로 사용 (split('.')[0])
```

### 4-5. 스토리북 / 도감

같은 패턴으로 한 화면씩.

---

## 5. 자동화하면 좋을 단계 (추후)

지금은 가이드만이지만, 디자인이 확정되면 다음을 추가하는 게 효율적입니다.

1. **`tokens.js → tokens.dart` 자동 변환 스크립트**
   - Node 스크립트 한 개로 충분. `tokens.js` 를 require 한 다음 dart 문자열로 stringify.
   - CI 에서 PR 마다 실행 → 디자인-코드 sync 보장.

2. **각 JSX 위젯 옆에 `*.spec.md` 작성**
   - 각 화면의 props, 상태, 인터랙션을 마크다운으로 1페이지.
   - Claude Code 가 spec 만 읽고도 dart 코드를 만들 수 있게.

3. **screen-by-screen 핸드오프 PR**
   - "HomeA → home_screen.dart" 1 PR
   - 한 PR 에 한 화면만. 작게 검증.

---

## 6. 디자인 작업 흐름 (재방문 시)

```
[omni: HTML 디자인]   ⟷   [omni: tweaks 토글로 비교]
        │
        │ 확정
        ▼
docs/design/ 동기화 (수동 복사 or 심볼릭 링크)
        │
        ▼
[Claude Code: dart 코드 생성/수정]
        │
        ▼
flutter run ios — 실제 시뮬레이터에서 검수
        │
        ▼
어긋남 발견 → 디자인 수정 vs 코드 수정 결정
```

핵심 원칙: **디자인이 정답일 때는 코드를 고치고, 코드 제약이 정답일 때는 디자인을 고친다.** 둘 다 임의로 흘러가게 두지 않는다.

---

## 부록 A — 지금 디자인의 의도적 단순화

데모 캔버스에서 일부러 단순화한 것들 (Flutter 옮길 때 참고):

| 영역 | 디자인에서는 | Flutter 에서는 |
|--|--|--|
| 지도 | SVG로 그린 가짜 지도 | `flutter_map` + OSM 타일 |
| 1km 링 | 고정 위치의 점선 원 | 사용자 좌표 기준 동적 Circle |
| 카테고리 색 | 단청에서 가져온 6색 | 그대로 사용 |
| 마커 아이콘 | 미수집 "?" / 수집 시 빗금 placeholder + ✓ 배지 | 미수집 "?" 그대로 / 수집 시 실제 장소 사진 (cached_network_image, BoxFit.cover, ClipOval) |
| 카테고리 표시 | 글래스 카드 안쪽 chip(史·築·人 등)에서만 사용 | 그대로 사용 (마커 위에는 띄우지 않음) |
| 데모 사진 자리 | 빗금 + monospace 라벨 | 사용자 사진으로 교체 (cached_network_image) |

---

## 부록 B — 디자인이 답하지 않은 것들 (코드 작업 시 정해야 할 것)

- 다크모드 — 디자인은 라이트만. 다크 필요하면 따로 요청.
- 빈 상태 (도감 0개) — 일러스트 또는 placeholder copy 필요.
- 에러 상태 (네트워크 / 권한 거부) — 디자인 없음.
- 로딩 인디케이터 — Skeleton vs Spinner 미정.
- 트랜지션 — 화면 간 이동 모션 미정 (기본 Material 사용해도 됨).

이 5가지는 디자이너에게 다시 묻거나, 기본값을 정하고 진행한 뒤 사후 검수.
