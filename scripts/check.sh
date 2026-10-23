#!/bin/bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
    echo "Lỗi: thiếu xcodegen. Cài bằng: brew install xcodegen" >&2
    exit 1
fi

mkdir -p build/tests

echo "==> Sinh project và build Debug (ký ad-hoc)"
xcodegen generate
xcodebuild -quiet -project VKey.xcodeproj -scheme VKey -configuration Debug \
    -derivedDataPath build/DerivedData build

echo "==> Kiểm tra chính sách cập nhật"
xcrun swiftc Sources/App/UpdateRuntimePolicy.swift tests/UpdateRuntimePolicyTests.swift \
    -o build/tests/update-runtime-policy-tests
build/tests/update-runtime-policy-tests | tee build/tests/policy-results.txt

echo "==> Kiểm tra engine ANSI / JIS"
xcrun clang++ -std=c++17 -Wall -Wno-missing-braces -ISources/Engine -ISources/Platform \
    tests/engine/EngineHarness.cpp tests/engine/EngineTests.cpp \
    Sources/Platform/VKKeyLayout.cpp Sources/Engine/*.cpp -o build/tests/engine-tests
build/tests/engine-tests | tee build/tests/engine-results.txt

echo "==> Kiểm tra tên phím tắt"
xcrun swiftc Sources/App/HotkeyKeyName.swift tests/HotkeyKeyNameTests.swift \
    -o build/tests/hotkey-key-name-tests
build/tests/hotkey-key-name-tests | tee build/tests/hotkey-key-name-results.txt

echo "==> Kiểm tra trùng phím tắt macOS"
xcrun swiftc Sources/App/SystemHotkeyConflict.swift tests/SystemHotkeyConflictTests.swift \
    -o build/tests/system-hotkey-conflict-tests
build/tests/system-hotkey-conflict-tests | tee build/tests/system-hotkey-conflict-results.txt

echo "==> Kiểm tra chế độ bàn phím và chỉ báo ngôn ngữ"
xcrun swiftc Sources/App/KeyboardModeStatus.swift Sources/App/LanguageIndicator.swift tests/KeyboardModeStatusTests.swift \
    -o build/tests/keyboard-mode-tests
build/tests/keyboard-mode-tests | tee build/tests/keyboard-mode-results.txt

echo "==> Kiểm tra chữ ký bản phát hành"
python3 tests/release-signature-tests.py | tee build/tests/release-signature-results.txt

echo "==> Hoàn tất: build Debug thành công"
cat build/tests/policy-results.txt build/tests/engine-results.txt build/tests/hotkey-key-name-results.txt \
    build/tests/system-hotkey-conflict-results.txt build/tests/release-signature-results.txt build/tests/keyboard-mode-results.txt
