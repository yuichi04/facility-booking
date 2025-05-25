#!/bin/bash

# echo "⏳ Waiting for all services to be ready..."

# # フロントエンド
# echo "Checking frontend..."
# while ! curl -s http://localhost:3000 > /dev/null; do
#     sleep 1
# done

# # 各APIサービス
# echo "Checking facility-service..."
# while ! curl -s http://localhost:8001/health > /dev/null; do
#     sleep 1
# done

# echo "Checking booking-service..."
# while ! curl -s http://localhost:8002/health > /dev/null; do
#     sleep 1
# done

# echo "Checking user-service..."
# while ! curl -s http://localhost:8003/health > /dev/null; do
#     sleep 1
# done

# echo "✅ All services are ready!"