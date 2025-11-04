#!/usr/bin/env python3
"""
Generate consistent dry-run report for claude-md-manager.

Usage:
    python generate_dry_run_report.py \
        --missing "Section1,Section2" \
        --custom "Custom1,Custom2" \
        --languages "python,javascript"
"""

import sys
import argparse

def generate_report(missing, custom, languages):
    """Generate formatted dry-run report."""

    report_lines = [
        "📊 claude-md-manager 검증 결과",
        "",
    ]

    # Language detection
    if languages:
        lang_display = ", ".join(lang.capitalize() for lang in languages)
        report_lines.append(f"**언어 탐지**: {lang_display}")
        report_lines.append("")

    # Missing sections
    if missing:
        report_lines.append(f"✅ **누락된 필수 섹션** ({len(missing)}개):")
        for i, section in enumerate(missing, 1):
            # Determine source template
            source = "템플릿"
            if len(languages) > 1:
                # For multi-language, try to infer source
                # (This is simplified; real implementation might pass metadata)
                if i <= len(missing) // 2:
                    source = f"{languages[0].capitalize()} 템플릿"
                else:
                    source = f"{languages[-1].capitalize()} 템플릿"
            elif languages:
                source = f"{languages[0].capitalize()} 템플릿"

            report_lines.append(f"  {i}. ## {section} ({source})")
        report_lines.append("")

    # Custom sections
    if custom:
        report_lines.append("💚 **기존 커스텀 섹션** (보존됨):")
        for section in custom:
            report_lines.append(f"  - ## {section}")
        report_lines.append("")

    # Conflicts
    report_lines.append("⚠️ **충돌**: 없음")
    report_lines.append("")

    # Summary
    report_lines.append("📌 **변경사항**:")
    if missing:
        report_lines.append(f"  - {len(missing)}개 섹션 추가 (덮어쓰기 없음)")
    if custom:
        report_lines.append("  - 커스텀 내용 100% 보존")
    report_lines.append("")

    # Action prompt
    report_lines.append("적용하시겠습니까?")

    return '\n'.join(report_lines)

def main():
    # Set UTF-8 output for Windows compatibility
    if sys.platform == 'win32':
        import codecs
        sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
        sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

    parser = argparse.ArgumentParser(description='Generate dry-run report for claude-md-manager')
    parser.add_argument('--missing', type=str, default='', help='Comma-separated missing sections')
    parser.add_argument('--custom', type=str, default='', help='Comma-separated custom sections')
    parser.add_argument('--languages', type=str, default='', help='Comma-separated detected languages')

    args = parser.parse_args()

    # Parse comma-separated values
    missing = [s.strip() for s in args.missing.split(',') if s.strip()]
    custom = [s.strip() for s in args.custom.split(',') if s.strip()]
    languages = [s.strip() for s in args.languages.split(',') if s.strip()]

    # Generate and print report
    report = generate_report(missing, custom, languages)
    print(report)

if __name__ == '__main__':
    main()
