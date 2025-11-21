# RolledPromptMaker

<p align="center">
  <img src="app_image.jpeg" alt="RolledPromptMaker Icon" width="200"/>
</p>

<p align="center">
  <strong>macOS용 프롬프트 템플릿 관리 및 생성 앱</strong>
</p>

## 소개

RolledPromptMaker는 생성형 AI를 사용할 때 반복적으로 사용하는 프롬프트를 템플릿으로 저장하고, 필요한 부분만 입력하여 빠르게 프롬프트를 생성할 수 있는 macOS 앱입니다.

## 주요 기능

- **템플릿 관리**: 자주 사용하는 프롬프트를 템플릿으로 저장
- **다양한 필드 타입**:
  - 텍스트: 여러 줄 입력 가능
  - 링크: URL 입력
  - 라디오: 여러 옵션 중 선택
  - 고정값: 미리 정의된 값 자동 입력
- **변수 치환**: `{{변수명}}` 형식으로 동적 값 입력
- **클립보드 복사**: 생성된 프롬프트 자동 복사
- **히스토리 관리**: 생성한 프롬프트 기록 저장 및 조회
- **로컬 저장**: 서버 없이 앱 내부에 데이터 저장

## 시스템 요구사항

- macOS 14.0 이상
- Apple Silicon 또는 Intel Mac

## 설치 방법

1. [Releases](https://github.com/YOUR_USERNAME/RolledPromptMaker/releases) 페이지에서 최신 버전의 `RolledPromptMaker.dmg` 다운로드
2. DMG 파일을 더블클릭하여 마운트
3. 나타난 창에서 `RolledPromptMaker.app`을 `Applications` 폴더로 드래그 앤 드롭
4. 앱 실행 (처음 실행 시 macOS 보안 경고가 나타날 수 있음)
   - "시스템 설정" > "개인 정보 보호 및 보안" > "보안" > "확인 없이 열기" 클릭

## 사용 방법

### 1. 템플릿 생성

1. 좌측 패널에서 `+` 버튼 클릭
2. 템플릿 이름 입력
3. 프롬프트 본문 작성 (변수는 `{{변수명}}` 형식 사용)
4. "필드 추가" 버튼으로 입력 필드 정의
5. "생성" 버튼 클릭

**예시:**
```
템플릿 본문:
당신은 {{role}}입니다.
다음 내용을 {{task}}해주세요:
{{context}}

필드:
- role: 고정값 타입 → "전문 개발자"
- task: 라디오 타입 → ["분석", "요약", "번역"]
- context: 텍스트 타입
```

### 2. 프롬프트 생성

1. 좌측 패널에서 템플릿 선택
2. 중앙 패널에서 필드 입력
3. "생성 및 복사" 버튼 클릭
4. 클립보드에 복사된 프롬프트 사용

### 3. 기록 확인

1. 우측 패널의 "기록" 탭에서 이전 프롬프트 확인
2. "결과" 탭으로 전환하여 전체 내용 확인
3. 우클릭으로 복사 또는 삭제

## 기술 스택

- **언어**: Swift
- **프레임워크**: SwiftUI
- **데이터베이스**: SwiftData
- **플랫폼**: macOS 14.0+

## 라이선스

MIT License

## 기여

버그 리포트나 기능 제안은 [Issues](https://github.com/YOUR_USERNAME/RolledPromptMaker/issues)에 올려주세요.

## 개발자

Developed with Claude Code
