FROM flaskfarm/flaskfarm:4.1

# 1. FFmpeg (Ubuntu 22.04 공식 패키지 v4.4.2), VAAPI 하드웨어 가속 드라이버, Python 3.11 설치
RUN apt-get update && \
    apt-get install -y software-properties-common git \
                       ffmpeg vainfo intel-media-va-driver mesa-va-drivers && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Flaskfarm(Python 3.10) 공용 패키지 사전 설치
RUN pip install plexapi google-api-python-client

# 3. gd-poller 전용 Python 3.11 가상환경 및 패키지 설치
# (upstream pyproject.toml 내 gd_poller.helpers 패키징 누락 버그 패치 및 검증)
RUN git clone --depth 1 https://github.com/halfaider/gd-poller.git /opt/gd-poller && \
    sed -i 's/"gd_poller"/"gd_poller", "gd_poller.helpers"/g' /opt/gd-poller/pyproject.toml && \
    python3.11 -m venv /opt/gd-poller-venv && \
    /opt/gd-poller-venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/gd-poller-venv/bin/pip install -e /opt/gd-poller google-api-python-client && \
    ln -s /opt/gd-poller-venv/bin/gd-poller /usr/local/bin/gd-poller && \
    /opt/gd-poller-venv/bin/python -c "from gd_poller.cli import main; print('gd-poller verified successfully!')"

# 4. 수정된 run.sh를 컨테이너 내부에 직접 포함
COPY run.sh /root/run.sh
RUN chmod +x /root/run.sh
