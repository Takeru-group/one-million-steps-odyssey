#!/bin/bash
set -e

echo "🚀 [1/5] 実行中プロセス（Xcode/xcodebuild）の停止..."
killall Xcode xcodebuild swift-driver swift-frontend 2>/dev/null || true

echo "🧹 [2/5] キャッシュ・DerivedData・重複依存の完全削除..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf build/
rm -rf .dart_tool/
rm -rf ios/Pods ios/Podfile.lock ios/Runner.xcworkspace ios/Flutter/Flutter.podspec ios/Flutter/Generated.xcconfig
rm -rf ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm

echo "📦 [3/5] Flutter パッケージ再取得..."
flutter pub get

echo "🍎 [4/5] iOS Pods の再インストール..."
cd ios
pod install
cd ..

echo "✨ [5/5] Xcode ワークスペースの起動..."
open ios/Runner.xcworkspace

echo "✅ クリーンアップと再構築が完了しました！Xcodeで Clean Build Folder (Shift+Cmd+K) 後にビルドしてください。"
