# 📕 iOS Mini Project Pomodoro ⏲

> 1871164 위승현 : 학습에 도움을 주는 뽀모도로 앱

</br>

## 🔎 프로젝트 개요

이 프로젝트는 SwiftUI와 Firebase를 활용하여 학습에 도움을 주는 뽀모도로 타이머 앱을 개발하는 것을 목표로 합니다. 
사용자들은 앱을 통해 간편하게 계정을 생성하고 로그인할 수 있으며, 뽀모도로 기법을 사용하여 학습 세션을 효율적으로 관리할 수 있습니다. 
또한, 학습 데이터를 기반으로 일별, 주별, 월별 통계를 시각화하여 학습 패턴을 분석하고 목표 달성에 도움을 줍니다. 이 앱은 직관적인 UI와 Firebase 연동을 통해 사용자 경험을 극대화하며, 타이머 기능과 데이터 시각화를 통해 학습 효율성을 향상시키는 데 중점을 두고 있습니다.

</br>

## :movie_camera: 시연 영상

###### 클릭하면 유튜브로 이동합니다

[![시연 영상](http://img.youtube.com/vi/nAZegafWuyw/0.jpg)](https://www.youtube.com/watch?v=nAZegafWuyw)

</br>

## :scroll: 핵심 설명문

이 앱은 SwiftUI와 Firebase를 사용하여 사용자가 로그인하거나 계정을 생성하고, 뽀모도로 타이머를 통해 학습 세션을 관리하며, 통계 데이터를 시각화할 수 있는 기능을 제공합니다.

### `ContentView`

**ContentView**:

- 로그인 및 회원가입 UI를 제공하는 메인 뷰입니다.
- 사용자로부터 이메일과 비밀번호를 입력받고, 로그인 또는 회원가입 버튼을 제공합니다.
- `isLoginMode` 상태에 따라 UI와 동작이 변경됩니다.
- 인증 성공 시 `MainView`로 네비게이션합니다.

구체적인 구성 요소는 다음과 같습니다:

- **이미지 및 제목**: 상단에 표시되는 앱 로고와 제목입니다.
- **입력 필드**: 이메일과 비밀번호를 입력받는 필드입니다.
- **로그인/회원가입 버튼**: 현재 모드에 따라 로그인 또는 회원가입 동작을 실행합니다.
- **모드 전환 버튼**: 로그인과 회원가입 모드를 전환합니다.
- **하단 텍스트**: 유저에게 동기부여 문구를 제공합니다.
- **NavigationLink**: 인증 성공 시 `MainView`로 이동합니다.
- **Alert**: 인증 실패 시 에러 메시지를 표시합니다.

### `ContentViewModel`

**ContentViewModel**:

- 뷰 모델로서, 사용자 입력을 관리하고 Firebase 인증 로직을 처리합니다.
- `isLoginMode`, `email`, `password`, `showAlert`, `alertMessage`, `showMainView` 등의 상태를 관리합니다.

주요 메서드는 다음과 같습니다:

- **handleAuthenticationTapped**: 현재 모드에 따라 로그인 또는 회원가입 메서드를 호출합니다.
- **loginUser**: Firebase Auth를 사용하여 로그인합니다. 성공 시 `showMainView`를 `true`로 설정하여 `MainView`로 이동합니다. 실패 시 `showAlert`와 `alertMessage`를 설정하여 에러를 표시합니다.
- **createNewAccount**: Firebase Auth를 사용하여 새로운 계정을 생성합니다. 성공 시 Firestore에 사용자 이메일을 저장합니다. 실패 시 `showAlert`와 `alertMessage`를 설정하여 에러를 표시합니다.

이를 통해 사용자는 손쉽게 로그인하거나 새로운 계정을 생성할 수 있으며, 인증이 성공하면 `MainView`로 이동할 수 있습니다.

### `MainView`

**`MainView` 구조체**:

- 앱의 메인 화면을 정의합니다.
- `TabView`를 사용하여 세 개의 탭을 제공합니다: 메인 타이머 화면, 세션 화면, 통계 화면.
- `@StateObject`를 사용하여 두 개의 뷰 모델(`MainViewModel` 및 `SessionViewModel`)을 초기화합니다.

**메인 타이머 화면**:

- 타이머와 관련된 UI 요소들을 배치합니다.
- `Circle`과 `Circle().trim()`을 사용하여 타이머의 진행 상황을 시각적으로 나타냅니다.
- `Text`와 `Button`을 사용하여 타이머 제어 버튼(시작, 일시정지, 중지) 및 설정 버튼을 제공합니다.
- 현재 라운드 정보와 같은 추가 정보를 표시합니다.

**세션 화면 및 통계 화면**:

- `SessionView`와 `StatisticView`는 각각 세션 기록과 통계 정보를 표시하는 화면입니다.

### `MainViewModel`

**`MainViewModel` 클래스**:

- 타이머의 상태와 동작을 관리하는 뷰 모델입니다.
- `@Published` 속성으로 타이머 관련 상태를 정의하여 뷰가 이 상태에 반응하도록 합니다.
- Firebase를 사용하여 사용자 데이터를 저장하고 업데이트합니다.

**타이머 기능**:

- `startTimer()`: 타이머를 시작하거나 일시정지합니다. 타이머가 동작 중일 때는 1초 간격으로 업데이트됩니다.
- `resetTimer()`: 타이머를 초기 상태로 재설정합니다. 타이머가 중지될 때의 시간을 기록합니다.
- `showSessionTitleAlert()`: 타이머가 종료되면 세션의 제목을 입력받는 알림을 표시합니다.
- `showSettingAlert()`: 타이머 설정(공부 시간, 휴식 시간, 총 라운드 수)을 입력받는 알림을 표시합니다.

**Firebase 연동**:

- `recordCycleTime()`: 세션 종료 시, 해당 세션의 시작/종료 시간, 공부 시간, 휴식 시간 등을 Firestore에 기록합니다.
- `recordStudyTime()`, `recordRestTime()`: 각각 공부 시간과 휴식 시간을 Firestore에 업데이트합니다.

**알림 및 진동**:

- `playAlertSound()`: 타이머 종료 시 진동을 발생시킵니다.
- `showAlert()`: 타이머 종료 시 알림을 표시합니다.

이 코드는 SwiftUI와 Combine을 사용하여 상태 관리 및 UI 업데이트를 수행하며, Firebase Firestore를 사용하여 사용자 데이터를 저장하고 관리합니다. 타이머의 상태 변화에 따라 UI를 업데이트하고, 사용자에게 중요한 정보를 알림으로 제공하여 UX를 향상시키는 데 중점을 두고 있습니다.

### `SessionView`

**`SessionView` 구조체**:

- 세션 목록을 표시하는 화면을 정의합니다.
- `List`를 사용하여 세션 목록을 표시하고, 각 세션 항목을 `SessionItemView`로 나타냅니다.
- 화면이 나타날 때 `viewModel.fetchSessions()`를 호출하여 Firebase에서 세션 데이터를 가져옵니다.
- `sheet`를 사용하여 세션 세부 정보를 표시하는 모달을 제공합니다.

**`SessionItemView` 구조체**:

- 단일 세션 항목을 표시하는 뷰입니다.
- 세션 제목과 아이콘, 탭 제스처로 세션 세부 정보를 표시할 수 있습니다.
- 세션 항목을 배경 색상 및 그림자로 꾸밉니다.

### `SessionDetailsView`

**`SessionDetailsView` 구조체**:

- 특정 세션의 세부 정보를 표시하는 화면입니다.
- 세션의 제목, 시작/종료 시간, 공부/휴식 시간 등을 표시합니다.
- 집중도 평가를 이모티콘과 코멘트로 표시합니다.
- 총 경과 시간 및 집중도를 계산하여 표시합니다.

### `SessionViewModel`

**`Session` 구조체**:

- 세션 데이터를 모델링합니다. 각 세션은 `id`, `title`, `startTime`, `endTime`, `studyTime`, `restTime` 속성을 가집니다.

**`SessionViewModel` 클래스**:

- 세션 목록 및 세부 정보 관리를 위한 뷰 모델입니다.
- `@Published` 속성으로 세션 목록, 선택된 세션, 세션 세부 정보 표시 상태를 관리합니다.
- Firebase Firestore에서 세션 데이터를 가져오고(`fetchSessions`), 세션 제목을 수정하는(`editSession`) 기능을 제공합니다.

**주요 기능**:

- **세션 데이터 가져오기(`fetchSessions`)**: 현재 사용자의 세션 데이터를 Firestore에서 가져와 `sessions` 배열에 저장합니다.
- **세션 제목 수정하기(`editSession`)**: Firestore에서 세션 제목을 업데이트하고, 로컬 `sessions` 배열에서도 업데이트합니다.

이 코드들은 SwiftUI와 Firebase를 통합하여 사용자가 세션을 관리하고 세부 정보를 볼 수 있도록 도와줍니다. UI는 사용자에게 친숙한 디자인 요소(아이콘, 색상, 그림자 효과 등)를 사용하며, 데이터는 Firebase Firestore를 통해 안정적으로 관리됩니다.

### `StatisticView`

**StatisticView**:

- 최상위 뷰로, 사용자가 일별, 주별, 월별 통계를 선택할 수 있는 Picker와 해당 통계를 표시하는 `StatsView`를 포함합니다.

**StatsView**:

- 사용자가 선택한 통계 유형(일, 주, 월)에 따라 다른 통계를 표시합니다.
- 각 통계 유형에 대해 적절한 데이터를 가져와 `StatsCard`와 `BarChartView`를 사용하여 시각화합니다.

**StatsCard**:

- 학습 시간과 휴식 시간을 포맷하여 카드 형태로 보여줍니다.
- 학습 패턴

에 대한 간단한 분석 결과도 포함합니다.

**BarChartView**:

- `SwiftUI Charts`를 사용하여 막대 그래프로 학습 시간을 시각화합니다.
- X축과 Y축의 레이블을 포맷하여 사용자가 시간을 쉽게 이해할 수 있도록 합니다.

**StatsHelper**:

- 날짜와 시간을 포맷하는 유틸리티 메서드를 제공합니다.
- 주간 및 월간 포맷터를 포함하여 각 통계 유형에 맞는 날짜 형식을 반환합니다.

### `StatisticViewModel`

**DailyStats / WeeklyStats / MonthlyStats**:

- 각 통계 유형에 맞는 데이터 구조를 정의합니다. 각각 날짜, 학습 시간 배열, 총 휴식 시간을 포함합니다.

**StatisticViewModel**:

- Firebase Firestore에서 사용자의 학습 데이터를 가져오는 ViewModel입니다.
- `@Published` 속성으로 SwiftUI 뷰와 데이터를 연동합니다.
- 초기화 시 일별, 주별, 월별 데이터를 각각 가져옵니다.
- `fetchStats(period:)` 메서드를 통해 Firestore에서 데이터를 쿼리하고, 적절한 형태로 가공하여 `addStats(period:startDate:endDate:studyTimes:totalRestTime:)` 메서드를 호출해 통계 데이터를 설정합니다.

### 작동 방식 요약

1. **`StatisticView` 초기화**:
    - 사용자가 통계를 일별, 주별, 월별로 선택할 수 있는 Picker를 표시합니다.
2. **`StatisticViewModel` 초기화**:
    - Firebase Firestore에서 사용자의 학습 데이터를 가져옵니다.
    - 데이터를 일별, 주별, 월별로 가공하여 `DailyStats`, `WeeklyStats`, `MonthlyStats` 구조체에 저장합니다.
3. **`StatsView` 업데이트**:
    - 사용자가 Picker에서 선택한 통계 유형에 따라 적절한 통계를 표시합니다.
    - `StatsCard`를 사용하여 학습 시간과 휴식 시간을 카드 형태로 보여주고, `BarChartView`를 사용하여 막대 그래프로 시각화합니다.
4. **`StatsHelper`를 통한 포맷팅**:
    - 날짜와 시간을 사용자가 이해하기 쉬운 형식으로 포맷팅합니다.
