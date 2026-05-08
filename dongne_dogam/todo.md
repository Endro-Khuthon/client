# 동네도감 Flutter 작업 순서

## 폴더 구조

```
lib/
├── main.dart
├── core/
│   ├── constants.dart          # 1km 기준 등 상수
│   └── router.dart             # go_router 라우팅 정의
├── data/
│   ├── models/
│   │   ├── region.dart
│   │   ├── story_spot.dart
│   │   └── related_content.dart
│   ├── repositories/
│   │   ├── spot_repository.dart    # API 호출 (dio)
│   │   └── dogam_repository.dart   # 로컬 저장 (shared_preferences)
│   └── services/
│       └── api_client.dart         # dio 기본 설정
├── features/
│   ├── home/
│   │   ├── home_screen.dart        # 지도 + 하단 카드
│   │   └── widgets/
│   │       ├── story_card.dart         # 하단 스와이프 카드
│   │       └── notification_popup.dart # 인앱 알림 팝업
│   ├── story/
│   │   └── story_screen.dart       # 스토리북 화면
│   └── dogam/
│       └── dogam_screen.dart       # 도감 화면
```

## 파일별 설명

| 파일 | 역할 |
|------|------|
| `main.dart` | 앱 시작점. "여기서부터 앱이 실행된다"고 Flutter에 알려주는 파일 |
| `core/constants.dart` | 앱 전체에서 쓰는 숫자/문자 상수 모음. 예: 1km = 1000(m), API 주소 |
| `core/router.dart` | 화면 이동 규칙 정의. `/home` 누르면 홈 화면, `/story` 누르면 스토리 화면으로 |
| `data/models/region.dart` | 지역(성수동, 전주 등) 데이터 구조 정의. API 응답을 Dart 객체로 변환 |
| `data/models/story_spot.dart` | 스토리 포인트 하나의 데이터 구조 (이름, 좌표, 스토리 본문 등) |
| `data/models/related_content.dart` | 관련 콘텐츠(책, 영상) 데이터 구조 |
| `data/services/api_client.dart` | 백엔드 서버에 HTTP 요청 보내는 기본 설정. 주소, 타임아웃 등 |
| `data/repositories/spot_repository.dart` | 스팟 데이터를 가져오는 함수 모음. 화면은 여기서 데이터를 요청함 |
| `data/repositories/dogam_repository.dart` | 수집한 스토리 조각 목록을 기기에 저장하고 불러오는 함수 모음 |
| `features/home/home_screen.dart` | 홈 화면 UI. 지도 + 스토리 포인트 마커 + 하단 카드 |
| `features/home/widgets/story_card.dart` | 홈 하단 좌우 스와이프 카드 하나. 장소명, 카테고리, 거리 표시 |
| `features/home/widgets/notification_popup.dart` | 1km 이내 진입 시 뜨는 인앱 알림 팝업 UI |
| `features/story/story_screen.dart` | 스토리북 화면. 과거/현재/의미 본문 + 수집 버튼 |
| `features/dogam/dogam_screen.dart` | 도감 화면. 지역별 완성률 + 수집한 스팟 목록 |

> **Flutter 개념 한 줄 요약**
> - `Screen` = 화면 전체 (페이지)
> - `Widget` = 화면 안의 부품 (버튼, 카드 등)
> - `Model` = 데이터 구조 정의 (JSON → Dart 객체)
> - `Repository` = 데이터를 가져오거나 저장하는 로직

---

## 이슈 목록 (워크플로우 순서 기준)

> 각 항목 = GitHub 이슈 1개. 완료 시 PR 올리고 체크.

---

### T+0:30 ~ T+2:00

- [x] **[SETUP] 폴더 구조 생성**
  - `label`: setup
  - `내용`: lib/ 하위 core, data, features 폴더 구조 생성

- [ ] **[DESIGN-01] 무드보드 및 컨셉 정의**
  - `label`: design
  - `내용`: 컬러 팔레트(Primary/Surface/Accent), 폰트(Noto Sans KR), 톤앤매너 확정

- [ ] **[DESIGN-02] 핵심 5개 화면 와이어프레임**
  - `label`: design
  - `내용`: 홈 / 알림 팝업 / 스토리북 / 도감 / (여유 시) 추천 화면

---

### T+2:00 ~ T+3:30

- [ ] **[DESIGN-03] UI 컴포넌트 정의**
  - `label`: design
  - `내용`: 카테고리별 마커 아이콘 6종, 스토리 카드, 수집 버튼 상태 2가지, 프로그레스 바

- [ ] **[FE-01] Flutter 프로젝트 세팅**
  - `label`: frontend
  - `내용`: pubspec.yaml 패키지 추가 확인 (geolocator, flutter_map, shared_preferences, go_router, dio)

- [ ] **[FE-11] 로컬 저장 레이어 (DogamRepository)**
  - `label`: frontend
  - `내용`: shared_preferences로 수집한 스팟 ID 저장/조회/완성률 계산

- [ ] **[FE-02] API 클라이언트**
  - `label`: frontend
  - `내용`: dio 기본 설정, ApiClient 클래스, SpotRepository fetchSpots/fetchSpot 구현

---

### T+3:30 ~ T+5:30

- [ ] **[FE-03] 홈 화면 — 지도 + 스토리 포인트 마커**
  - `label`: frontend
  - `내용`: flutter_map으로 지도 렌더링, 스팟 좌표로 마커 표시, 카테고리별 색상 구분

- [ ] **[FE-04] 홈 화면 — 하단 스토리 카드 스와이프**
  - `label`: frontend
  - `내용`: PageView로 카드 구현, 장소명/카테고리/거리/summary 표시, 마커 연동

- [ ] **[FE-06] 데모 지역 선택 모드**
  - `label`: frontend
  - `내용`: 상단 칩으로 성수동/전주/영도 선택, 지도 중심 이동, GPS 모드 전환 버튼

---

### T+5:30 ~ T+7:30

- [ ] **[FE-05] 위치 권한 + GPS + 1km 감지**
  - `label`: frontend
  - `내용`: geolocator 권한 요청, 실시간 위치 수신, 스팟과의 거리 계산, 1km 이내 진입 감지

- [ ] **[FE-07] 인앱 알림 팝업**
  - `label`: frontend
  - `내용`: 1km 이내 진입 시 팝업 표시, 장소명/summary/이야기 보기 버튼, 중복 방지

- [ ] **[FE-08] 스토리북 화면**
  - `label`: frontend
  - `내용`: 장소명/카테고리/과거·현재·의미 본문/키워드 태그/수집 버튼 UI

---

### T+7:30 ~ T+9:30

- [ ] **[FE-09] 스토리 조각 수집 기능**
  - `label`: frontend
  - `내용`: 수집 버튼 탭 → shared_preferences 저장, 수집 완료 상태 표시, 재수집 방지

- [ ] **[FE-10] 도감 화면**
  - `label`: frontend
  - `내용`: 지역별 완성률 프로그레스 바, 수집 스팟 목록, 미수집 잠금 표시, 공유 버튼

- [ ] **[DESIGN-04] 스토리북 상세 디자인 반영** *(여유 시)*
  - `label`: design
  - `내용`: 타이포그래피 계층, 섹션 구분 시각화, 키워드 태그 칩 스타일

---

### T+9:30 이후 (Should Have)

- [ ] **[FE-12] 추천 화면** *(여유 시)*
  - `label`: frontend, should-have
  - `내용`: 스토리북 하단 related_contents 렌더링 (책/영상/장소 유형 + 제목 + 설명)
