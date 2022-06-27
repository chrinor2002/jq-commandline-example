#!/bin/bash

echo "Resetting system..."
docker compose down
docker compose build
docker compose up -d
