# AI Debate 속도 최종 분석

## 실행 시간 측정 (실제 토론 프롬프트)

### Codex 실행 방식 비교

| 방식 | 시간 | 출력 크기 | 비고 |
|------|------|----------|------|
| `codex exec` 직접 호출 | **171.9초 (2분 52초)** | 3.1K | 순수 Codex 시간 |
| `codex-session.sh` 스크립트 | 257.1초 (4분 17초) | 4.4K | +85.2초 (33% 느림) |

**스크립트 오버헤드: 85.2초 (33%)**

### 병렬 실행 분석

| 에이전트 | 실행 시간 | 상태 |
|----------|----------|------|
| Claude Code (스크립트) | 82.4초 | ❌ 실패 (JSON 파싱) |
| Codex (스크립트) | 257.1초 | ✅ 성공 |
| **병렬 실행 총 시간** | **257.1초** | Codex가 병목 |

**병렬 실행의 가치:**
- Codex 단독: 257.1초, 1개 의견
- 병렬 실행: 257.1초, 2개 의견 (Claude Code 성공 시)
- **추가 비용: 0초** ⭐

---

## 핵심 발견

### 1. 스크립트 오버헤드가 큼 ⚠️

**85.2초 (33%)의 추가 시간 발생**

가능한 원인:
- 세션 ID 생성 및 메타데이터 저장
- 파일 경로 처리 및 디렉토리 생성
- JSON/JSONL 파싱 및 세션 ID 추출
- 로그 파일 작성 및 출력 리다이렉션

**비교:**
- 간단한 질문 (5+5): 오버헤드 2.5초 (35%)
- 복잡한 토론: 오버헤드 85.2초 (33%)

### 2. 병렬 실행은 "공짜" ✅

Claude Code가 82초에 완료되므로, Codex 실행 중에 이미 끝남.
**추가 시간 없이 2배 의견 제공 가능**

### 3. 실제 문제: Claude Code 신뢰성 ❌

- 82초 실행 후 빈 응답 (1 byte)
- JSON 파싱 실패 (복잡한 출력)
- 간단한 질문: 성공
- 복잡한 토론: 실패

---

## 최적화 방안

### 옵션 1: 스크립트 오버헤드 제거 ⚡

**현재 시스템:**
- 병렬 실행: 257초 (Codex 스크립트 257초)
- Claude Code: 실패

**직접 호출로 개선:**
- Codex 직접 호출: 172초
- Claude Code 직접 호출: ~90초 예상
- 병렬 실행: **172초** (85초 절약, 33% 빠름)

**구현 방법:**
```bash
# 현재 (스크립트)
bash codex-session.sh new "$prompt" --stdout-only

# 개선 (직접 호출)
codex exec "$prompt" --full-auto --skip-git-repo-check
```

### 옵션 2: Claude Code JSON 파싱 개선 🔧

**문제:**
- Triple quotes 방식: `python3 -c "...'''$json_output'''..."`
- 복잡한 JSON에서 파싱 실패

**해결책:**
```bash
# 방법 1: jq 사용 (가장 안전)
result=$(echo "$json_output" | jq -r '.result')

# 방법 2: 파일 기반 파싱
echo "$json_output" > temp.json
result=$(python3 -c "import json; print(json.load(open('temp.json'))['result'])")
```

### 옵션 3: --stdout-only 모드 완전 재구현 🚀

**목표: 파일 I/O 완전 제거**

```bash
# collect-opinions.sh 개선
# 스크립트 호출 대신 CLI 직접 호출

codex exec "$prompt" --full-auto --skip-git-repo-check > codex-opinion.txt 2>&1 &
claude --print "$prompt" --output-format json 2>&1 | jq -r '.result' > claude-opinion.txt &

wait
```

**예상 효과:**
- Codex: 172초 (현재 257초에서 85초 절약)
- Claude Code: ~90초 (JSON 파싱 성공 시)
- 병렬 실행: **172초** (33% 빠름)

---

## 권장 사항

### 우선순위 1: 직접 CLI 호출로 전환 ⭐

**현재:**
```bash
bash codex-session.sh new "$prompt" --stdout-only --quiet
bash claude-code-session.sh new "$prompt" --stdout-only --quiet
```

**개선:**
```bash
codex exec "$prompt" --full-auto --skip-git-repo-check
claude --print "$prompt" --output-format json | jq -r '.result'
```

**효과:**
- 85초 절약 (33% 속도 향상)
- 코드 단순화
- 디버깅 용이

### 우선순위 2: Claude Code JSON 파싱 개선

jq 사용 또는 파일 기반 파싱으로 신뢰성 확보

### 우선순위 3: Graceful Degradation

Claude Code 실패 시 Codex만 사용 (1/2 성공이라도 유용)

---

## 최종 결론

### ✅ 현재 시스템은 속도 문제가 아님

**병렬 실행이 제대로 작동 중:**
- Codex 단독: 257초
- 병렬 실행: 257초 (동일)
- 추가 의견을 "공짜"로 제공

### ⚠️ 하지만 개선 여지 있음

**스크립트 오버헤드 제거로 33% 속도 향상 가능:**
- 현재: 257초 (4분 17초)
- 개선 후: 172초 (2분 52초)
- **절약: 85초**

### ❌ 실제 문제는 Claude Code 신뢰성

JSON 파싱 실패로 복잡한 토론에서 빈 응답 발생

---

## 구현 계획

1. **Phase 1: 직접 CLI 호출 구현** (최대 효과)
   - collect-opinions.sh에서 CLI 직접 호출
   - jq로 JSON 파싱
   - 85초 절약

2. **Phase 2: 테스트 및 검증**
   - 간단한 질문 + 복잡한 토론 모두 테스트
   - 성공률 확인 (2/2)

3. **Phase 3: 문서 업데이트**
   - skill.md 업데이트
   - 속도 개선 수치 반영

