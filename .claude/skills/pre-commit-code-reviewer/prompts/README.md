# Codex 코드 리뷰 프롬프트 사용 가이드

이 디렉토리에는 Codex CLI를 사용한 코드 리뷰를 위한 템플릿 파일들이 있습니다.

## 파일 구조

```
prompts/
├── system-prompt-ko.md      # Codex에게 전달할 리뷰 지침 (한글)
├── report-template-ko.md    # Codex가 따라야 할 출력 형식 (한글)
└── README.md                # 이 파일
```

---

## 사용 방법

### 기본 사용법

```bash
# 1. staged changes를 Codex로 리뷰
codex "$(cat .claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md)

$(cat .claude/skills/pre-commit-code-reviewer/prompts/report-template-ko.md)

위 지침과 형식을 따라서 현재 staged changes를 리뷰하세요."
```

### 간편 사용법 (추천)

더 간결하게:

```bash
codex "다음 두 파일을 읽고 지침을 따라서 리뷰해줘:
- .claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md (리뷰 지침)
- .claude/skills/pre-commit-code-reviewer/prompts/report-template-ko.md (출력 형식)

staged changes를 엄격하게 리뷰하고 한글로 보고해줘."
```

Codex가 autonomous agent이므로 파일 경로만 알려주면 자동으로 읽고 따릅니다!

---

## 실전 예시

### 예시 1: 전체 리뷰

```bash
codex ".claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md와
.claude/skills/pre-commit-code-reviewer/prompts/report-template-ko.md를 읽어줘.

그 지침에 따라 staged changes를 리뷰하고 한글 보고서를 작성해줘."
```

### 예시 2: Python 파일만 집중

```bash
codex "system-prompt-ko.md의 지침을 따라서
staged changes 중 Python 파일만 집중적으로 리뷰해줘.
report-template-ko.md 형식으로 한글 보고."
```

### 예시 3: 보안 집중 리뷰

```bash
codex "system-prompt-ko.md 기반으로 staged changes를 리뷰하되,
특히 보안 취약점에 집중해줘.
SQL injection, XSS, 하드코딩된 비밀 등을 찾아줘.
한글로 보고."
```

---

## 출력 저장

리뷰 결과를 파일로 저장:

```bash
# 리뷰 실행 후 결과를 파일로 리다이렉트
codex ".claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md의
지침으로 staged changes 리뷰. 한글 보고." > .code-reviews/$(date +%Y-%m-%d-%H-%M)-review.md
```

---

## 프롬프트 커스터마이징

### 엄격도 조절

더 엄격하게:
```bash
codex "system-prompt-ko.md의 지침을 따르되, **더욱 엄격하게** 평가해줘.
점수를 10점 낮게 책정하고, 모든 타입 힌트 누락을 치명적 이슈로 분류해줘."
```

더 관대하게:
```bash
codex "system-prompt-ko.md의 지침을 따르되,
치명적 보안 이슈와 명백한 버그만 집중해줘."
```

### 특정 파일만

```bash
codex "system-prompt-ko.md 지침으로
mcp-servers/openai-judge/server.py 파일만 리뷰해줘.
한글 보고."
```

---

## Bash 함수로 만들기 (편의성)

`.bashrc` 또는 `.zshrc`에 추가:

```bash
# Codex 한글 코드 리뷰
codex-review() {
    local prompt_dir=".claude/skills/pre-commit-code-reviewer/prompts"

    codex "다음 파일들을 읽고 지침을 따라줘:
    - ${prompt_dir}/system-prompt-ko.md
    - ${prompt_dir}/report-template-ko.md

    staged changes를 엄격하게 리뷰하고 한글로 보고."
}

# 사용법
git add .
codex-review
```

더 간단하게:

```bash
# 짧은 별칭
alias cr='codex ".claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md와 report-template-ko.md를 따라서 staged changes 리뷰. 한글 보고."'

# 사용법
git add .
cr
```

---

## Windows (PowerShell) 함수

`$PROFILE` 파일에 추가:

```powershell
function Codex-Review {
    $promptDir = ".claude/skills/pre-commit-code-reviewer/prompts"

    codex "다음 파일들을 읽고 지침을 따라줘:
    - $promptDir/system-prompt-ko.md
    - $promptDir/report-template-ko.md

    staged changes를 엄격하게 리뷰하고 한글로 보고."
}

# 별칭
Set-Alias cr Codex-Review

# 사용법
git add .
cr
```

---

## Claude Code Skill과 통합

skill.md에서 이 프롬프트들을 사용하도록 설정:

```bash
# Step 3: Call Codex CLI for Review
codex "$(cat .claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md)

$(cat .claude/skills/pre-commit-code-reviewer/prompts/report-template-ko.md)

위 지침과 형식을 따라서 staged changes를 리뷰하세요."
```

---

## 팁

### 1. 출력 길이 제어

간결한 리뷰:
```bash
codex "system-prompt-ko.md로 리뷰하되,
상위 3개 이슈만 간결하게 보고. 한글."
```

상세한 리뷰:
```bash
codex "system-prompt-ko.md로 리뷰하되,
모든 이슈에 대해 코드 예시와 수정 방법을 상세히 포함. 한글."
```

### 2. 여러 리뷰어 사용

Claude + Codex 병행:
```bash
# Claude 리뷰
claude "커밋 전 리뷰 해줘"

# Codex 리뷰 (한글)
codex "system-prompt-ko.md로 staged changes 리뷰. 한글."

# 결과 비교
```

### 3. CI/CD 통합

`.git/hooks/pre-commit`:
```bash
#!/bin/bash

echo "🔍 Codex 코드 리뷰 실행 중..."

REVIEW=$(codex ".claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md로 리뷰. 점수만 출력.")

SCORE=$(echo "$REVIEW" | grep -oP '전체 점수: \K\d+')

if [ "$SCORE" -lt 70 ]; then
    echo "❌ 리뷰 실패 (점수: $SCORE/100)"
    echo "이슈를 수정한 후 다시 커밋하세요."
    exit 1
fi

echo "✅ 리뷰 통과 (점수: $SCORE/100)"
exit 0
```

---

## 프롬프트 업데이트

더 나은 리뷰를 위해 프롬프트를 수정하려면:

1. `system-prompt-ko.md` 편집 - 리뷰 지침 변경
2. `report-template-ko.md` 편집 - 출력 형식 변경
3. 변경사항 커밋하여 팀과 공유

---

## 문제 해결

### Codex가 한글로 응답하지 않음

```bash
# 더 명시적으로
codex "**중요: 모든 응답은 반드시 한글로 작성하세요.**

system-prompt-ko.md를 읽고 따라서 staged changes 리뷰."
```

### 프롬프트가 너무 길어서 에러

```bash
# 파일 경로만 전달 (Codex가 자동으로 읽음)
codex ".claude/skills/pre-commit-code-reviewer/prompts/system-prompt-ko.md를 읽고
그대로 따라서 staged changes 리뷰해줘. 한글로."
```

### 출력 형식이 일치하지 않음

```bash
# 템플릿 강조
codex "report-template-ko.md의 형식을 **정확히** 따라서 출력해줘.
system-prompt-ko.md 지침으로 staged changes 리뷰. 한글."
```

---

## 관련 파일

- `../skill.md` - 전체 skill 문서
- `../assets/review-report-template.md` - 영문 템플릿
- `../../codex-integration/skill.md` - Codex 통합 가이드
- `../../../docs/openai-codex-guide.md` - Codex 전체 가이드

---

**마지막 업데이트:** 2025-10-27
**언어:** 한국어 (Korean)
**버전:** 1.0
