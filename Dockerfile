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

# 3. gd-poller 전용 Python 3.11 가상환경 사전 빌드
RUN python3.11 -m venv /opt/gd-poller-venv && \
    /opt/gd-poller-venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/gd-poller-venv/bin/pip install "git+https://github.com/halfaider/gd-poller.git" google-api-python-client && \
    ln -s /opt/gd-poller-venv/bin/gd-poller /usr/local/bin/gd-poller

# 4. 수정된 run.sh를 컨테이너 내부에 직접 포함
COPY run.sh /root/run.sh
RUN chmod +x /root/run.sh
