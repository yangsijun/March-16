# March 16

A beautifully crafted iOS app that delivers daily Bible verses to inspire and encourage your spiritual journey.

## Features

### Daily Verse
- Fresh Bible verse every day of the year
- Support for multiple Bible versions:
  - **NKRV** (개역개정) - Korean
  - **KJV** (King James Version) - English
  - **WEBBE** (World English Bible) - English

### Calendar View
- Browse verses for any day of the month
- Swipe gestures for month navigation
- Visual bookmark indicators
- Quick verse preview

### Bookmarks
- Save your favorite verses
- Persistent storage with SwiftData
- Easy access from calendar view

### Home Screen Widgets
- Three widget sizes: Small (2×2), Medium (4×2), Large (4×4)
- Daily automatic updates at midnight
- Matches your selected Bible version

### Sharing
- Generate beautiful 9:16 share cards
- Optimized for social media
- Supports light/dark mode

### Daily Notifications
- Customizable notification time
- Localized verse content
- 7-day advance scheduling

## Technical Stack

| Category | Technology |
|----------|------------|
| UI Framework | SwiftUI |
| Data Persistence | SwiftData, GRDB (SQLite) |
| Widget | WidgetKit |
| Notifications | UserNotifications |
| Region Detection | StoreKit 2 (Storefront API) |
| Minimum iOS | iOS 17.0+ |

## Architecture

```
March16/
├── Sources/
│   ├── Application/        # App entry point, global state
│   ├── Models/             # Data models (DailyVerse, Bookmark)
│   ├── View/               # SwiftUI views
│   │   └── Components/     # Reusable UI components
│   ├── Service/            # Business logic & data access
│   └── Shared/             # Colors, fonts, extensions
├── Resources/              # Assets, fonts, databases
└── March16Widget/          # Widget extension
```

### Key Design Patterns
- **Repository Pattern** - Abstracted data access layer
- **Singleton Pattern** - Centralized managers (Database, Notification, ODR)
- **Protocol-Driven Design** - Swappable implementations for testing
- **Observable State** - Reactive UI updates with @Observable

### Database Architecture
- **Main Database**: Contains daily verses and NKRV/WEBBE translations
- **KJV Database**: Downloaded on-demand via ODR (On-Demand Resources)
- **App Group Container**: Shared database access for widget extension

### Region-Aware Bible Selection
```
Korean locale       → NKRV (default)
UK region          → WEBBE only (KJV unavailable)
Other regions      → KJV available with WEBBE fallback
```

## Build Requirements

- Xcode 16.0+
- iOS 17.0+ deployment target
- Swift 6.0

### Dependencies
- [GRDB.swift](https://github.com/groue/GRDB.swift) - SQLite database toolkit

## License

This project is proprietary software. All rights reserved.

---

# March 16 (한국어)

매일의 성경 말씀으로 영적 여정에 영감과 격려를 전하는 아름다운 iOS 앱입니다.

## 주요 기능

### 오늘의 말씀
- 매일 새로운 성경 구절 제공
- 다양한 성경 버전 지원:
  - **개역개정** (NKRV) - 한국어
  - **KJV** (King James Version) - 영어
  - **WEBBE** (World English Bible) - 영어

### 캘린더 뷰
- 월별 말씀 탐색
- 스와이프로 월 이동
- 북마크 표시
- 말씀 미리보기

### 북마크
- 좋아하는 말씀 저장
- SwiftData로 영구 저장
- 캘린더에서 빠른 접근

### 홈 화면 위젯
- 3가지 크기: 소형(2×2), 중형(4×2), 대형(4×4)
- 매일 자정 자동 업데이트
- 선택한 성경 버전 반영

### 공유하기
- 9:16 비율의 아름다운 공유 카드 생성
- SNS 최적화
- 라이트/다크 모드 지원

### 매일 알림
- 알림 시간 설정 가능
- 지역화된 말씀 내용
- 7일간 미리 예약

## 기술 스택

| 분류 | 기술 |
|------|------|
| UI 프레임워크 | SwiftUI |
| 데이터 저장 | SwiftData, GRDB (SQLite) |
| 위젯 | WidgetKit |
| 알림 | UserNotifications |
| 지역 감지 | StoreKit 2 (Storefront API) |
| 최소 iOS | iOS 17.0+ |

## 아키텍처

```
March16/
├── Sources/
│   ├── Application/        # 앱 진입점, 전역 상태
│   ├── Models/             # 데이터 모델 (DailyVerse, Bookmark)
│   ├── View/               # SwiftUI 뷰
│   │   └── Components/     # 재사용 UI 컴포넌트
│   ├── Service/            # 비즈니스 로직 & 데이터 접근
│   └── Shared/             # 색상, 폰트, 확장
├── Resources/              # 에셋, 폰트, 데이터베이스
└── March16Widget/          # 위젯 익스텐션
```

### 주요 디자인 패턴
- **Repository 패턴** - 추상화된 데이터 접근 계층
- **Singleton 패턴** - 중앙화된 매니저 (Database, Notification, ODR)
- **Protocol 기반 설계** - 테스트를 위한 교체 가능한 구현체
- **Observable 상태** - @Observable을 통한 반응형 UI 업데이트

### 데이터베이스 구조
- **메인 DB**: 오늘의 말씀 정보 및 개역개정/WEBBE 번역본
- **KJV DB**: ODR(On-Demand Resources)로 필요 시 다운로드
- **App Group 컨테이너**: 위젯과 데이터베이스 공유

### 지역 기반 성경 선택
```
한국어 로케일      → 개역개정 (기본값)
영국 지역         → WEBBE만 사용 (KJV 불가)
기타 지역         → KJV 사용 가능, WEBBE 대체
```

## 빌드 요구 사항

- Xcode 16.0+
- iOS 17.0+ 배포 타겟
- Swift 6.0

### 의존성
- [GRDB.swift](https://github.com/groue/GRDB.swift) - SQLite 데이터베이스 툴킷

## 라이선스

이 프로젝트는 독점 소프트웨어입니다. 모든 권리 보유.
