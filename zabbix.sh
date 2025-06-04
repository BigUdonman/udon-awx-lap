#!/bin/bash

ZBX_CONF="/etc/zabbix/zabbix_agent2.conf"
ZBX_SERVER_DOMAIN="udon04"
ZBX_AGENT_SERVICE="zabbix-agent2"

# 1. Zabbix 서버 IP 얻기
ZBX_SERVER_IP=$(getent hosts "$ZBX_SERVER_DOMAIN" | awk '{ print $1 }')

if [[ -z "$ZBX_SERVER_IP" ]]; then
    echo "❌ Zabbix 서버 도메인($ZBX_SERVER_DOMAIN)의 IP를 찾을 수 없습니다."
    exit 1
fi

echo "✅ Zabbix 서버 IP: $ZBX_SERVER_IP"

# 2. 설정 파일에서 Server 항목 수정
if grep -q "^Server=" "$ZBX_CONF"; then
    sed -i "s/^Server=.*/Server=$ZBX_SERVER_IP/" "$ZBX_CONF"
else
    echo "Server=$ZBX_SERVER_IP" >> "$ZBX_CONF"
fi

# 필요시 Active Server도 변경
if grep -q "^ServerActive=" "$ZBX_CONF"; then
    sed -i "s/^ServerActive=.*/ServerActive=$ZBX_SERVER_IP/" "$ZBX_CONF"
else
    echo "ServerActive=$ZBX_SERVER_IP" >> "$ZBX_CONF"
fi

# 3. Zabbix Agent 재시작
sudo systemctl restart "$ZBX_AGENT_SERVICE"
echo "🔁 Zabbix Agent 재시작 완료"

exit 0
