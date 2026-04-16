#!/usr/bin/with-contenv bash
scriptVersion="1.4.5-patched3"
SMA_PATH="/usr/local/sma"

if [ -f /config/setup_version.txt ]; then
  # shellcheck disable=SC1091
  source /config/setup_version.txt
  if [ "${scriptVersion}" == "${setupversion:-}" ]; then
    if apk --no-cache list | grep installed | grep opus-tools | read; then
      echo "Setup was previously completed, skipping..."
      exit 0
    fi
  fi
fi
echo "setupversion=$scriptVersion" > /config/setup_version.txt

set -euo pipefail

echo "*** install packages ***" && \
apk add -U --upgrade --no-cache \
  tidyhtml \
  musl-locales \
  musl-locales-lang \
  flac \
  jq \
  xq \
  git \
  gcc \
  g++ \
  make \
  build-base \
  cmake \
  ninja \
  llvm20-dev \
  clang20 \
  py3-colorama \
  ffmpeg \
  imagemagick \
  opus-tools \
  opustags \
  python3-dev \
  libc-dev \
  uv \
  parallel \
  npm && \
echo "*** install freyr client ***" && \
apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing atomicparsley && \
npm install -g miraclx/freyr-js && \
echo "*** install python packages ***" && \
uv pip install --system --upgrade --no-cache-dir --break-system-packages \
  jellyfish \
  beautifulsoup4 \
  yt-dlp \
  beets==2.2.0 \
  yq \
  pyxDamerauLevenshtein \
  pyacoustid \
  requests \
  colorama \
  python-telegram-bot \
  pylast \
  mutagen \
  r128gain \
  tidal-dl \
  deemix \
  langdetect \
  apprise && \
echo "************ setup SMA ************"

if [ -d "${SMA_PATH}" ]; then
  rm -rf "${SMA_PATH}"
fi

echo "************ download repo ************" && \
git clone --depth 1 https://github.com/mdhiggins/sickbeard_mp4_automator.git "${SMA_PATH}" && \
echo "************ create logging file ************" && \
touch "${SMA_PATH}/config/sma.log" && \
chgrp users "${SMA_PATH}/config/sma.log" && \
chmod g+w "${SMA_PATH}/config/sma.log" && \
echo "************ install pip dependencies ************" && \
uv pip install --system --break-system-packages -r "${SMA_PATH}/setup/requirements.txt"

mkdir -p /custom-services.d/python /config/extended

parallel ::: \
  'echo "Download QueueCleaner service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/universal/services/QueueCleaner -o /custom-services.d/QueueCleaner && echo "Done"' \
  'echo "Download AutoConfig service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/AutoConfig.service.bash -o /custom-services.d/AutoConfig && echo "Done"' \
  'echo "Download Video service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/Video.service.bash -o /custom-services.d/Video && echo "Done"' \
  'echo "Download Tidal Video Downloader service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/TidalVideoDownloader.bash -o /custom-services.d/TidalVideoDownloader && echo "Done"' \
  'echo "Download Audio service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/Audio.service.bash -o /custom-services.d/Audio && echo "Done"' \
  'echo "Download AutoArtistAdder service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/AutoArtistAdder.bash -o /custom-services.d/AutoArtistAdder && echo "Done"' \
  'echo "Download UnmappedFilesCleaner service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/UnmappedFilesCleaner.bash -o /custom-services.d/UnmappedFilesCleaner && echo "Done"' \
  'echo "Download ARLChecker service..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/python/ARLChecker.py -o /custom-services.d/python/ARLChecker.py && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/ARLChecker -o /custom-services.d/ARLChecker && echo "Done"' \
  'echo "Download Script Functions..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/universal/functions.bash -o /config/extended/functions && echo "Done"' \
  'echo "Download PlexNotify script..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/PlexNotify.bash -o /config/extended/PlexNotify.bash && echo "Done"' \
  'echo "Download SMA config..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/sma.ini -o /config/extended/sma.ini && echo "Done"' \
  'echo "Download LyricExtractor script..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/LyricExtractor.bash -o /config/extended/LyricExtractor.bash && echo "Done"' \
  'echo "Download ArtworkExtractor script..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/ArtworkExtractor.bash -o /config/extended/ArtworkExtractor.bash && echo "Done"' \
  'echo "Download Beets Tagger script..." && curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/BeetsTagger.bash -o /config/extended/BeetsTagger.bash && echo "Done"'

if [ ! -f /config/extended/beets-config.yaml ]; then
  echo "Download Beets config..."
  curl -sfL "https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/beets-config.yaml" -o /config/extended/beets-config.yaml
fi

if [ ! -f /config/extended/beets-config-lidarr.yaml ]; then
  echo "Download Beets lidarr config..."
  curl -sfL "https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/beets-config-lidarr.yaml" -o /config/extended/beets-config-lidarr.yaml
fi

if [ ! -f /config/extended/deemix_config.json ]; then
  echo "Download Deemix config..."
  curl -sfL "https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/deemix_config.json" -o /config/extended/deemix_config.json
fi

if [ ! -f /config/extended/tidal-dl.json ]; then
  echo "Download Tidal config..."
  curl -sfL "https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/tidal-dl.json" -o /config/extended/tidal-dl.json
fi

if [ ! -f /config/extended/beets-genre-whitelist.txt ]; then
  echo "Download beets-genre-whitelist.txt..."
  curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/beets-genre-whitelist.txt -o /config/extended/beets-genre-whitelist.txt
fi

if [ ! -f /config/extended.conf ]; then
  echo "Download Extended config..."
  curl -sfL https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/lidarr/extended.conf -o /config/extended.conf
fi

# Root fix: robust XML parser for Arr API autodetect.
cat <<'EOFFUNC' >> /config/extended/functions

getArrAppInfo () {
  if [ -z "${arrUrl:-}" ] || [ -z "${arrApiKey:-}" ]; then
    readarray -t _arrvals < <(python3 - <<'PYARR'
import xml.etree.ElementTree as ET
cfg='/config/config.xml'
try:
    root = ET.parse(cfg).getroot()
except Exception:
    print('')
    print('')
    print('')
    print('')
    raise SystemExit(0)

def t(name):
    v = root.findtext(name, '')
    return '' if v is None else v.strip()

print(t('UrlBase'))
print(t('InstanceName'))
print(t('ApiKey'))
print(t('Port'))
PYARR
)
    arrUrlBase="${_arrvals[0]}"
    arrName="${_arrvals[1]}"
    arrApiKey="${_arrvals[2]}"
    arrPort="${_arrvals[3]}"

    if [ -z "${arrUrlBase}" ]; then
      arrUrlBase=""
    else
      arrUrlBase="/$(echo "${arrUrlBase}" | sed 's#^/*##;s#/*$##')"
    fi

    arrUrl="http://127.0.0.1:${arrPort}${arrUrlBase}"
  fi
}
EOFFUNC

# Safe permissions (directory-aware; keep import/watch writable)
chown -R abc:users /config/extended /custom-services.d 2>/dev/null || true

chmod 2775 /config/extended /custom-services.d 2>/dev/null || true
mkdir -p /config/extended/import /config/extended/downloads /config/extended/cache /config/extended/logs
chmod 2775 /config/extended/import /config/extended/downloads /config/extended/cache /config/extended/logs 2>/dev/null || true

find /config/extended -maxdepth 1 -type f -exec chmod 664 {} \; 2>/dev/null || true
find /config/extended -maxdepth 1 -type f -name "*.bash" -exec chmod 775 {} \; 2>/dev/null || true
find /custom-services.d -maxdepth 1 -type f -exec chmod 775 {} \; 2>/dev/null || true
find /custom-services.d/python -maxdepth 1 -type f -name "*.py" -exec chmod 664 {} \; 2>/dev/null || true
chmod 664 /config/extended.conf 2>/dev/null || true

if [ -f /custom-services.d/scripts_init.bash ]; then
  sleep infinity
fi
exit 0
