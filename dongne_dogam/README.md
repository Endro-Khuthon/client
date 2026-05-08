# 동네도감 (Dongne Dogam)

동네의 숨겨진 이야기를 발견하고 수집하는 위치 기반 스토리 탐험 앱입니다.

GPS로 실제 장소에 가까이 다가가면 그 장소의 역사·문화·인물 이야기가 잠금 해제되며, 수집한 스토리를 도감으로 관리할 수 있습니다.

---

## 주요 기능

### 지도 (홈 화면)
- 네이버 지도 위에 스토리 포인트 마커 표시
- 카테고리별 색상 구분 (역사 / 건축 / 인물 / 전통문화 / 예술문화 / 자연문화)
- 수집 여부에 따라 마커 상태 변경 (미수집: `?`, 수집 완료: 썸네일 이미지)
- 마커 탭 시 하단 스토리 카드 슬라이드 업

### 위치 감지 및 알림
- GPS 실시간 추적으로 반경 500m 이내 스토리 포인트 감지
- 근접 진입 시 인앱 알림 팝업 표시 (중복 알림 방지)
- 데모용 위치 직접 설정 기능 (지도 탭으로 임의 위치 지정)

### 스토리북
- 장소의 **과거 / 현재 / 의미** 세 섹션으로 구성된 상세 스토리
- 키워드 태그, 대표 이미지 헤더
- "스토리 수집하기" 버튼으로 도감에 저장

### 도감
- 지역별 수집 완성률 프로그레스 바 표시
- 수집한 스토리 목록 확인 및 재열람

---

## 기술 스택

| 항목       | 내용                      |
| ---------- | ------------------------- |
| 프레임워크 | Flutter (Dart)            |
| 지도       | flutter_naver_map ^1.4.4  |
| HTTP       | dio ^5.9.2                |
| 위치       | geolocator ^14.0.2        |
| 로컬 저장  | shared_preferences ^2.5.5 |
| 라우팅     | go_router ^17.2.3         |
| SDK        | Dart ^3.11.5              |

---

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점, 하단 네비게이션 쉘
├── core/
│   └── app_colors.dart                # 컬러 팔레트, 카테고리별 색상
├── data/
│   ├── models/
│   │   └── story_spot.dart            # StorySpotSummary / StorySpot 모델
│   ├── repositories/
│   │   ├── spot_repository.dart       # 스팟 API 호출 (목 데이터 전환 가능)
│   │   ├── dogam_repository.dart      # 수집 ID 로컬 저장/조회
│   │   └── mock_spots.dart            # 개발용 목 데이터
│   └── services/
│       └── api_client.dart            # Dio 기본 설정 (baseUrl, timeout)
└── features/
    ├── home/
    │   ├── home_screen.dart            # 지도 화면
    │   └── widgets/
    │       ├── story_card.dart         # 하단 스토리 카드
    │       └── notification_popup.dart # 근접 알림 팝업
    ├── story/
    │   └── story_screen.dart           # 스토리 상세 화면
    ├── dogam/
    │   └── dogam_screen.dart           # 도감 목록 화면
    └── settings/
        └── settings_screen.dart        # 설정 화면 (준비 중)
```

---

## 시작하기

### 사전 요구사항

- Flutter SDK 3.x 이상
- Android Studio 또는 Xcode (iOS 빌드 시)
- 네이버 지도 API 클라이언트 ID

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 네이버 지도 설정

[lib/main.dart](lib/main.dart)의 `clientId`를 본인의 네이버 클라우드 플랫폼 앱 등록 ID로 교체하세요.

```dart
await FlutterNaverMap().init(
  clientId: 'YOUR_CLIENT_ID',
);
```

### 백엔드 API

기본 연결 주소:
- Android 에뮬레이터: `http://10.0.2.2:8000`
- iOS 시뮬레이터 / 실기기: `http://localhost:8000`

[lib/data/repositories/spot_repository.dart](lib/data/repositories/spot_repository.dart)에서 `useMock: true`로 설정하면 서버 없이 목 데이터로 실행할 수 있습니다.

---

## API 명세

| Method | Endpoint                             | 설명                   |
| ------ | ------------------------------------ | ---------------------- |
| GET    | `/regions/{regionId}/spots`          | 지역 내 스팟 목록 조회 |
| GET    | `/regions/{regionId}/spots/{spotId}` | 스팟 상세 조회         |

### 지원 지역

| regionId          | 지역명            |
| ----------------- | ----------------- |
| `kyunghee_global` | 경희대 국제캠퍼스 |
| `seongsu`         | 성수동            |

### 스팟 요약 응답 (StorySpotSummary)

```json
{
  "id": "string",
  "name": "string",
  "category": "역사 | 건축 | 인물 | 전통문화 | 예술문화 | 자연문화",
  "lat": 0.0,
  "lng": 0.0,
  "summary": "string",
  "image_url": "string"
}
```

### 스팟 상세 응답 (StorySpot)

```json
{
  "id": "string",
  "name": "string",
  "category": "string",
  "lat": 0.0,
  "lng": 0.0,
  "summary": "string",
  "story_past": "string",
  "story_present": "string",
  "story_meaning": "string",
  "keywords": ["string"],
  "image_url": "string"
}
```

---

## 컬러 테마

Cool Gray 팔레트 기반의 다크-라이트 중간 톤을 사용합니다.

| 역할          | 색상      |
| ------------- | --------- |
| 배경 (bg)     | `#F5F6F8` |
| 서피스        | `#FFFFFF` |
| 서피스 보조   | `#ECEFF2` |
| 주요 텍스트   | `#111318` |
| 보조 텍스트   | `#4A5060` |
| 음소거 텍스트 | `#9399A8` |
| 강조 (accent) | `#3D6FFF` |
