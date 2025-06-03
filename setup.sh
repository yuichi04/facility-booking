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

# SSHエージェントを起動し、鍵を追加（パスフレーズ入力の入力は1回で済むように）
if [ -f ~/.ssh/id_ed25519 ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null || echo "SSH key already added or no passphrase required"
fi

# 各サブモジュールをmainブランチに切り替え
echo "🔄 Switching submodules to main branch..."
git submodule foreach '
    echo "Processing submodule: $name"

    # リモートブランチ情報を取得
    git fetch origin --quiet || { echo "Failed to fetch $name"; exit 1; }

    # mainブランチが存在するかチェック
    if git show-ref --verify --quiet refs/remotes/origin/main; then
        echo "Switching to main branch in $name"
        git checkout main || { echo "Failed to checkout main in $name"; exit 1; }
        git pull origin main || { echo "Failed to pull main in $name"; exit 1; }
    elif git show-ref --verify --quiet refs/remotes/origin/master; then
        echo "main branch not found, switching to master branch in $name"
        git checkout master || { echo "Failed to checkout master in $name"; exit 1; }
        git pull origin master || { echo "Failed to pull master in $name"; exit 1; }
    else
        echo "Warning: Neither main nor master branch found in $name"
        exit 1
    fi
'

# フロントエンドの依存関係をインストール
echo "📚 Installing frontend dependencies..."
cd services/facility-booking-frontend && npm install && cd ..
cd facility-booking-admin-frontend && npm install && cd ../..

# Dockerコンテナのビルドと起動
echo "🏗️ Building and starting Docker containers..."
docker compose up -d

# データベースの準備ができるまで待機
echo "⏳ Waiting for database to be ready..."
timeout=60
elapsed=0
until docker compose exec db pg_isready -U postgres; do
    if [ "$elapsed" -ge "$timeout"]; then
        echo "❌ Timeout waiting for database"
        exit 1
    fi
    echo "Database is unavailable - sleeping"
    sleep 1
    elapsed=$((elapsed+1))
done
echo "✅ Database is ready!"

# マイグレーションの実行
echo "🔄 Running database migrations..."
docker compose exec auth-api go run migrate/migrate.go

# セットアップ完了
echo "
====================================
✨ Setup completed successfully! ✨
====================================
🌐 Available services:
    - Frontend: http://localhost:3000
    - AdminFrontend: http://localhost:3001
    - AuthApi: http://localhost:8080
    - BookingsApi: http://localhost:8081
    - FacilitiesApi: http://localhost:8082
    - PgAdmin: http://localhost:5050
"