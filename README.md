# FlaskFarm Custom Docker Image

커스텀 설정 및 개선사항이 사전 포함된 FlaskFarm 올인원 Docker 이미지 빌드 저장소입니다.

## ✨ 주요 특징 및 수정 사항

1. **Python 호환성 듀얼 환경 구성**
   - **FlaskFarm 본체**: 기존 Python 3.10 환경 유지 (`libsc.so`, C-extension, 기존 플러그인 100% 호환)
   - **gd-poller 전용 가상환경**: Python 3.11 환경 (`/opt/gd-poller-venv`) 사전 빌드 완료
   - Google API Python 3.10 EOL 경고 없이 최신 Google API core 라이브러리 사용 가능
   - `/usr/local/bin/gd-poller` 심볼릭 링크 제공 및 `/data/gd-poller/.venv` 자동 호환 링크 지원

2. **사전 설치된 필수 라이브러리**
   - `plexapi`
   - `google-api-python-client`
   - `gd-poller` (v0.9.x+)

3. **Command 플러그인 실시간 로그 출력 패치 내장**
   - `run.sh` 내부에서 소스 동기화 후 `page_command.py`의 로그 레벨 자동 패치 (`debug` -> `info`)
   - 웹 UI "Command" 메뉴 실행 시 실시간 로그가 누락 없이 화면에 정상 출력됩니다.

4. **간소화된 배포 구조**
   - `run.sh`가 이미지 내부에 직접 포함되어 있어, 각 서버마다 `run.sh` 파일을 따로 마운트할 필요가 없습니다.

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
      # (선택 사항) 호스트의 정적 ffmpeg을 사용하는 경우 마운트
      - /DATA/AppData/flaskfarm/bin/ffmpeg:/usr/bin/ffmpeg:ro
```

> **참고**:
> `run.sh`가 컨테이너 내부에 이미 포함되어 있으므로, 기존에 필요했던 `- /DATA/AppData/flaskfarm/edit/run.sh:/root/run.sh` 볼륨 마운트는 완전히 제거하셔도 됩니다.

---

## ⚙️ gd-poller 실행 설정

FlaskFarm 웹 UI의 **Command** 설정 또는 스크립트 실행 시 아래 세 가지 경로 중 어떤 것을 사용해도 Python 3.11 환경에서 정상 작동합니다:

- **기본 명령어**: `gd-poller /data/gd-poller/gd_poller/settings.yaml`
- **가상환경 직접 지정**: `/opt/gd-poller-venv/bin/gd-poller /data/gd-poller/gd_poller/settings.yaml`
- **기존 볼륨 경로 호환**: `/data/gd-poller/.venv/bin/gd-poller /data/gd-poller/gd_poller/settings.yaml`

---

## 📦 패키지 공개 설정 (GitHub Packages)

GitHub Container Registry(`ghcr.io`)에 최초로 이미지가 푸시되면 기본적으로 **Private** 상태일 수 있습니다.
다른 서버에서 `docker login` 없이 바로 `docker pull` 할 수 있도록 하려면:

1. 본 저장소 우측 또는 프로필의 **Packages** 메뉴로 이동합니다.
2. `flaskfarm-custom` 패키지를 클릭합니다.
3. 우측 하단의 **Package settings**를 클릭합니다.
4. 맨 아래 **Danger Zone**의 **Change visibility**를 클릭하고 **Public**으로 변경합니다.
