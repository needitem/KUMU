#!/bin/bash

# 스크립트가 있는 디렉토리로 이동
cd "$(dirname "$0")"

# AppleScript를 사용하여 GUI 다이얼로그 표시
show_message() {
    osascript -e "display dialog \"$1\" buttons {\"확인\"} default button \"확인\""
}

show_input_dialog() {
    osascript -e "display dialog \"$1\" default answer \"$2\" buttons {\"취소\", \"확인\"} default button \"확인\"" -e 'text returned of result' 2>/dev/null
}

# 변경사항 확인
echo "=== Git 변경사항 확인 ==="
git status

echo ""
echo "=== 변경된 파일들 ==="
git diff --name-status

# 변경사항이 있는지 확인
if [ -z "$(git status --porcelain)" ]; then
    show_message "변경사항이 없습니다."
    exit 0
fi

# 커밋 메시지 입력받기 (GUI)
commit_message=$(show_input_dialog "커밋 메시지를 입력하세요:" "파일 업데이트")

# 취소 버튼을 눌렀거나 메시지가 비어있으면 종료
if [ -z "$commit_message" ]; then
    show_message "푸시가 취소되었습니다."
    exit 0
fi

# Git 작업 수행
echo ""
echo "=== 모든 변경사항 추가 중... ==="
git add .

echo "=== 커밋 생성 중... ==="
git commit -m "$commit_message"

if [ $? -eq 0 ]; then
    echo "✓ 커밋 성공!"

    echo ""
    echo "=== GitHub에 푸시 중... ==="
    git push origin main

    if [ $? -eq 0 ]; then
        echo "✓ 푸시 성공!"
        show_message "✓ 성공!\n\n변경사항이 GitHub에 반영되었습니다."
    else
        echo "✗ 푸시 실패"
        show_message "✗ 푸시 실패\n\n터미널 창에서 에러 메시지를 확인하세요."
        read -p "아무 키나 눌러 종료..."
    fi
else
    if [ -z "$(git status --porcelain)" ]; then
        show_message "변경사항이 없습니다."
    else
        echo "✗ 커밋 실패"
        show_message "✗ 커밋 실패\n\n터미널 창에서 에러 메시지를 확인하세요."
        read -p "아무 키나 눌러 종료..."
    fi
fi

# 3초 후 자동 종료
sleep 3
