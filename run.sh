#!/bin/bash
source /root/export.sh
/usr/bin/ff first
redis-server --daemonize yes
COUNT=0
SOURCE_PATH=/data/src/flaskfarm
REPO="https://github.com/halfaider/flaskfarm.git"

# gd-poller 가상환경 호환성 링크 (/data/gd-poller/.venv 미존재 시 /opt/gd-poller-venv 연결)
if [ ! -d "/data/gd-poller/.venv" ]; then
    mkdir -p /data/gd-poller
    ln -s /opt/gd-poller-venv /data/gd-poller/.venv 2>/dev/null || true
fi

while true; do
    if [[ -d "${SOURCE_PATH}/.git" ]]; then
        git -C "${SOURCE_PATH}" checkout . 2>/dev/null
        git -C "${SOURCE_PATH}" pull
    else
        mkdir -p "$(dirname "${SOURCE_PATH}")"
        git clone "${REPO}" "${SOURCE_PATH}"
    fi

    # Command 플러그인 로그 출력 패치 (debug -> info)
    if [[ -f "${SOURCE_PATH}/lib/system/page_command.py" ]]; then
        sed -i 's/self\.logger\.debug(text)/self.logger.info(text)/g' "${SOURCE_PATH}/lib/system/page_command.py"
        sed -i 's/self\.logger\.debug(mode)/self.logger.info(mode)/g' "${SOURCE_PATH}/lib/system/page_command.py"
    fi

    cd "${SOURCE_PATH}" || exit 1
    python -m main --repeat ${COUNT} --config "/data/config.yaml"
    RESULT=$?
    echo "PYTHON EXIT CODE : ${RESULT}.............."
    if [ "$RESULT" = "1" ]; then
        echo 'REPEAT....'
        sleep 5
    else
        echo 'FINISH....'
        break
    fi
    ((COUNT++))
done

if [ "$DOCKER_NONSTOP" = "true" ]; then
    sleep 1000d
else
    echo 'FlaskFarm container has stopped!!'
fi
