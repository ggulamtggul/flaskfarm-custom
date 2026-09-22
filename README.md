# FlaskFarm Custom Docker Image

커스텀 설정 및 개선사항이 사전 포함된 FlaskFarm 올인원 Docker 이미지 빌드 저장소입니다.

## ✨ 주요 특징 및 수정 사항

1. **FFmpeg (v4.4.2) 및 VAAPI 하드웨어 가속 기본 내장**
   - Ubuntu 22.04 공식 `ffmpeg` (v4.4.2-0ubuntu0.22.04.1) 내장
   - `intel-media-va-driver`, `mesa-va-drivers`, `vainfo` 사전 탑재
   - 인텔 내장 그래픽 VAAPI 하드웨어 가속 트랜스코딩 완벽 지원
   - **더 이상 호스트에서 ffmpeg 바이너리를 구해서 마운트할 필요가 없습니다.**

2. **Python 호환성 듀얼 환경 구성**
   - **FlaskFarm 본체**: 기존 Python 3.10 환경 유지 (`libsc.so`, C-extension, 기존 플러그인 100% 호환)
   - **gd-poller 전용 가상환경**: Python 3.11 환경 (`/opt/gd-poller-venv`) 사전 빌드 완료
   - Google API Python 3.10 EOL 경고 없이 최신 Google API core 라이브러리 사용 가능
   - `/usr/local/bin/gd-poller` 심볼릭 링크 제공 및 `/data/gd-poller/.venv` 자동 호환 링크 지원

3. **사전 설치된 필수 라이브러리**
   - `plexapi`
   - `google-api-python-client` (`googleapiclient` 모듈)
   - `gd-poller` (v0.9.x+)

4. **Command 플러그인 실시간 로그 출력 패치 내장**
   - `run.sh` 내부에서 소스 동기화 후 `page_command.py`의 로그 레벨 자동 패치 (`debug` -> `info`)
   - 웹 UI "Command" 메뉴 실행 시 실시간 로그가 누락 없이 화면에 정상 출력됩니다.

5. **완전 독립 실행 (마운트 최소화)**
   - `run.sh` 및 `ffmpeg`이 모두 이미지 내부에 포함되어 있어, 데이터 디렉토리(`/data`) 외에 추가 볼륨 마운트가 필요 없습니다.

---

## 🚀 빠른 시작 (docker-compose.yml)

배포할 서버의 `docker-compose.yml` 파일에 다음과 같이 설정합니다:

```yaml
version: "3.8"

services:
  flaskfarm:
    image: ghcr.io/ggulamtggul/flaskfarm-custom:latest
    container_name: flaskfarm
    restart: unless-stopped
    ports:
      - "9999:9999"
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Seoul
    volumes:
      - /DATA/AppData/flaskfarm/data:/data
    # VAAPI 하드웨어 가속을 사용하는 경우 장치 패스스루 추가
    devices:
      - /dev/dri:/dev/dri
```

> **참고**:
> `run.sh`와 `ffmpeg`이 컨테이너 내부에 모두 포함되어 있으므로, 기존의 `run.sh` 및 `ffmpeg` 호스트 볼륨 마운트는 완전히 제거하시면 됩니다.

---

## ⚙️ gd-poller 실행 설정

FlaskFarm 웹 UI의 **Command** 설정 또는 스크립트 실행 시 아래 세 가지 경로 중 어떤 것을 사용해도 Python 3.11 환경에서 정상 작동합니다:

- **기본 명령어**: `gd-poller /data/gd-poller/gd_poller/settings.yaml`
- **가상환경 직접 지정**: `/opt/gd-poller-venv/bin/gd-poller /data/gd-poller/gd_poller/settings.yaml`
- **기존 볼륨 경로 호환**: `/data/gd-poller/.venv/bin/gd-poller /data/gd-poller/gd_poller/settings.yaml`
