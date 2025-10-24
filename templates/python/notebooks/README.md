# Notebooks

이 폴더는 Jupyter notebook 파일들을 저장하는 곳입니다.

## 사용법

```bash
# Jupyter notebook 실행
uv run jupyter notebook

# 특정 포트로 실행
uv run jupyter notebook --port=8889
```

## 주의사항

- **실행 결과는 자동으로 commit에서 제외됩니다**
- `nbstripout`이 pre-commit hook에 설정되어 있어, commit 시 자동으로 output과 실행 카운트가 제거됩니다
- 코드만 버전 관리되므로 깔끔한 git history를 유지할 수 있습니다

## 예시 파일

```python
# example.ipynb
import myproject

# 여기에 탐색적 분석, 시각화, 프로토타입 코드 작성
```
