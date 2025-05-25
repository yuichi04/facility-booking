#!/bin/bash

echo "🎭 Starting E2E Tests with Playwright..."

# 全サービスを起動
echo "🚀 Starting all services..."
# 既に起動している場合は停止してから起動
docker-compose down -v 2>/dev/null || true
docker-compose up -d

# サービスの起動を待機
echo "⏳ Waiting for services to start..."
# TODO: サービスの起動を確認するためスクリプトを実行する

# テストデータの準備
echo "📦 Preparing test data..."
# TODO: テストデータの準備スクリプトを実行する

# E2Eテスト実行
echo "🧪 Running E2E tests with Playwright..."
cd e2e-tests
npm install
npx playwright test

# テスト結果の確認
if [ $? -eq 0 ]; then
    echo "✅ All E2E tests passed!"
else
    echo "❌ Some E2E tests failed!"
    echo "📊 Opening test report..."
    npx playwright show-report
    exit 1
fi

# 環境のクリーンアップ
echo "🧹 Cleaning up environment..."
cd ..
docker-compose down