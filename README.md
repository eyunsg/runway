# Runway

> 2026 PBL

## 1. Project Vision

> Runway Project는 사용자의 은퇴 목표에 맞춘 장기 자산 시뮬레이션 및 계획 지원 도구입니다. <br> 사용자는 투자 종목 정보를 입력하고 다양한 변동 시나리오를 통해 자산 흐름을 직관적으로 확인할 수 있습니다.

- 목표: 사용자가 은퇴 목표까지 남은 기간과 필요한 추가 투자 규모를 명확히 파악하고 장기적인 투자 전략을 점검하도록 지원
- 대상 사용자: 은퇴를 목표로 포트폴리오를 구성·관리하는 개인 투자자
- 차별점: 단순 수익률 계산을 넘어 장기 자산 흐름 예측 및 계획 가이드를 제공하고 실제 재무 의사결정에 활용 가능

## 2. Problem Definition

- 현재 문제: 기존 투자 도구는 단기 수익 예측 중심
- 기존 대안의 한계
  - 단순 수익률 계산에 머무름
  - 자산 흐름과 은퇴 목표 간 거리를 직관적으로 제공하지 못함
  - Excel 등 일반 도구로는 Monte Carlo 기반 장기 시뮬레이션 구현이 어려움
- Runway Project가 해결할 포인트
  - <ins>Monte Carlo를 활용한 다양한 변동 시나리오</ins>로 장기 자산 흐름 시뮬레이션
  - 목표 은퇴 시점까지의 자산 성장 및 추가 투자 가이드 제공
  - 투자자가 현실적 목표를 설정하고 전략을 점검할 수 있는 직관적 정보 제공

## 3. Scope Definition

### In Scope

- 사용자가 입력한 주식, ETF 등 금융 자산 데이터 기반 시뮬레이션
- 다양한 변동 시나리오에 따른 장기 자산 흐름 예측
- 은퇴 목표 시점까지 남은 기간 및 추가 투자 가이드 제공

### Out of Scope

- ISIN이 없는 자산 (부동산, 개인 거래 자산, 비상장 상품 등)
- 인플레이션 반영
- 자산 간 상관관계 계산
- 세금, 연금 등 제도적 고려
- 지출 변화 시나리오 반영
- 목표 달성 이후 투자 매도/지속 여부 계산
- 개별 종목 추천, 매매 타이밍 등 투자 자문 기능

## 4. Planned Architecture

- Frontend <br> <img src="https://img.shields.io/badge/Flutter-0553B1?style=flat&logo=Flutter&logoColor=white"/>
- Backend <br> <img src="https://img.shields.io/badge/Supabase-11181C?style=flat&logo=Supabase&logoColor=34B27B"/>
- Database <br> <img src="https://img.shields.io/badge/PostgreSQL-336791?style=flat&logo=PostgreSQL&logoColor=white"/>
- Hosting <br> <img src="https://img.shields.io/badge/Supabase-11181C?style=flat&logo=Supabase&logoColor=34B27B"/>

## 5. Data Model

- [DB ERD](https://iyunsung423.atlassian.net/wiki/x/A4CM)

## 6. API Design

- [API Specification](https://iyunsung423.atlassian.net/wiki/x/DAA_/)

## 7. Development Environment Setup

### Prerequisites

로컬 개발 환경 구성을 위해 아래 실행 환경이 사전에 설치되어 있어야 합니다.

- Node.js >= 20.18.0 (LTS)
- npm >= 10.x
- Flutter >= 3.41.2
- Dart >= 3.11.0
- Git >= 2.50

---

본 저장소는 Monorepo 구조이며 Git Commit 규칙을 강제하기 위해  
**Husky + Commitlint**가 Repository Root 기준으로 설정되어 있습니다.

따라서 프로젝트 최초 실행 시 **루트 경로에서 dependency 설치가 반드시 필요합니다.**

### 1. Repository Clone

```bash
git clone https://github.com/eyunsg/runway.git

cd runway
```

### 2. Install Root Dependency

```bash
npm install
```

### 3. Setup Backend Environment

- backend 디렉토리로 이동

```bash
cd backend
```

- 환경 변수 파일 생성

```bash
cp .env.example .env
```

- 의존성 설치

```bash
npm install
```

- 테스트 실행

```bash
npm test
```

- Supabase 연결 테스트

```bash
npm run test:supabase
```

### 4. Install Frontend Dependency

```bash
cd apps/mobile

flutter pub get
```

---

> **⚠️ VSCode Prettier Extension 설치**
> <br>
> 작업 시 팀에서 지정한 Prettier 룰을 적용하려면
> <br>
> VSCode에서 Prettier - Code Formatter 확장 프로그램 설치를 권장합니다.
