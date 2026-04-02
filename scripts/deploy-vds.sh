#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Deploy to VDS (185.48.182.164) — pulls latest main + builds + restarts services
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

VDS_IP="185.48.182.164"
VDS_USER="ubuntu"
VDS_PASSWORD="#C6JGjP"
VDS_REPO="/home/ubuntu/redcoreECO"

echo "🚀 Deploying to VDS $VDS_IP..."
echo ""

# SSH into VDS and pull + deploy
sshpass -p "$VDS_PASSWORD" ssh "$VDS_USER@$VDS_IP" << 'EOF'
set -euo pipefail

echo "── Pull latest main from GitHub ──"
cd /home/ubuntu/redcoreECO
git pull origin main

echo ""
echo "── Building installers + APIs on VDS ──"
BUILD_OS_RELEASE=1 bash scripts/deploy.sh

echo ""
echo "✅ Deploy complete!"
pm2 ls
EOF

echo ""
echo "✅ VDS deploy finished!"
