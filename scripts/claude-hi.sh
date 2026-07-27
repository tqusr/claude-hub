#!/usr/bin/env bash
set -euo pipefail

response="$(claude -p "Say hi in one short sentence." --tools "")"
echo "[$(date -Iseconds)] $response"
