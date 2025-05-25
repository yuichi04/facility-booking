#!/bin/bash

# エラー発生時にスクリプトを終了させる
set -e

echo "🚀 Starting development environment setup..."

# .env.localファイルをコピーして.envファイルを作成
cp .env.local .env || { echo "❌ Error: Could not create .env file"; exit 1; }

# 環境変数を読み込む
source .env

# 古い環境のクリーンアップ
echo "🧹 Cleaning up old environment..."
docker compose down -v 2>/dev/null || true

# サブモジュールの初期化と更新
echo "📦 Initializing and updating submodules..."
git submodule update --init --recursive

# 各サブモジュールをmainブランチに切り替え
echo "🔄 Switching submodules to main branch..."
git submodule foreach 'git checkout main && git pull origin main'

# フロントエンドの依存関係をインストール
echo "📚 Installing frontend dependencies..."
cd services/facility-booking-frontend && npm install && cd ..
cd facility-booking-admin-frontend && npm install && cd ../..

# Dockerコンテナのビルドと起動
echo "🏗️ Building and starting Docker containers..."
docker compose up -d

# データベースの準備ができるまで待機
# マイグレーションの実行

# セットアップ完了
echo "✨ Setup completed successfully!"
echo "
🌐 Available services:
    - Frontend: http://localhost:3000
    - AdminFrontend: http://localhost:3001
    - AuthApi: http://localhost:8080
    - BookingsApi: http://localhost:8081
    - FacilitiesApi: http://localhost:8082
    - PgAdmin: http://localhost:5050
"