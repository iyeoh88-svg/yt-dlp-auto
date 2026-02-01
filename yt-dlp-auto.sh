#!/usr/bin/env bash
#!/usr/bin/env bash
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                               ║
║   ██╗   ██╗████████╗      ██████╗ ██╗     ██████╗      █████╗ ██╗   ██╗████████╗ ██████╗      ║
║   ╚██╗ ██╔╝╚══██╔══╝      ██╔══██╗██║     ██╔══██╗    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗     ║
║    ╚████╔╝    ██║   █████╗██║  ██║██║     ██████╔╝    ███████║██║   ██║   ██║   ██║   ██║     ║
║     ╚██╔╝     ██║   ╚════╝██║  ██║██║     ██╔═══╝     ██╔══██║██║   ██║   ██║   ██║   ██║     ║
║      ██║      ██║         ██████╔╝███████╗██║         ██║  ██║╚██████╔╝   ██║   ╚██████╔╝     ║
║      ╚═╝      ╚═╝         ╚═════╝ ╚══════╝╚═╝         ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝      ║
║                                                                                               ║
║                       Smart YouTube Downloader for macOS                                      ║
║                                                                                               ║
║                    Auto-update • Cookie Magic • Error Helper                                  ║
║                            github.com/iyeoh88-svg                                             ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════╝
EOF
# yt-dlp-auto.sh
# macOS script to auto-download/update yt-dlp, prompt for link/location, choose audio/video,
# obtain browser cookies automatically (brave/chrome/firefox) or accept cookies file,
# validate parameters and give helpful error diagnostics.
#
# Tested on macOS (bash/sh). Requires: curl, jq (optional but recommended), sqlite3 (macOS builtin),
# yt-dlp (the script will install/update it).
#
# NOTE: Script tries to be defensive. It logs verbose output to a logfile in the destination folder.

set -euo pipefail
IFS=$'\n\t'

# --- Config / defaults ---
GITHUB_LATEST_API="https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
GITHUB_DL_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"  # works for direct binary
DEFAULT_INSTALL_PATH="/usr/local/bin/yt-dlp"
ALT_INSTALL_PATH="$HOME/.local/bin/yt-dlp"
BREW_PATH="$(command -v brew 2>/dev/null || true)"
JQ="$(command -v jq 2>/dev/null || true)"
TIMESTAMP_FMT="%Y%m%d-%H%M%S"

# --- Helpers ---
log() { echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] $*"; }
err() { echo -e "ERROR: $*" >&2; }

# detect architecture for informative messaging
ARCH="$(uname -m)"
OS="$(uname -s)"

# find installed yt-dlp (if any)
find_yt_dlp() {
  if command -v yt-dlp >/dev/null 2>&1; then
    command -v yt-dlp
  elif [[ -x "$DEFAULT_INSTALL_PATH" ]]; then
    echo "$DEFAULT_INSTALL_PATH"
  elif [[ -x "$ALT_INSTALL_PATH" ]]; then
    echo "$ALT_INSTALL_PATH"
  else
    echo ""
  fi
}

installed_bin="$(find_yt_dlp)"

# --- Step 1: compare with latest release on GitHub and update if desired ---
echo
log "Checking latest yt-dlp release from GitHub..."

latest_tag=""
latest_name=""
# try to get latest tag via GitHub API; fallback to static download url if API isn't available.
if command -v curl >/dev/null 2>&1; then
  api_resp="$(curl -sL "$GITHUB_LATEST_API" || true)"
  if [[ -n "$api_resp" && "$api_resp" != "null" ]]; then
    # use jq if available for robust parse
    if [[ -n "$JQ" ]]; then
      latest_tag="$(echo "$api_resp" | jq -r '.tag_name // .name // empty')"
      latest_name="$(echo "$api_resp" | jq -r '.name // empty')"
    else
      latest_tag="$(echo "$api_resp" | grep -m1 -oE '"tag_name":\s*"[^\"]+' | cut -d\" -f4 || true)"
      latest_name="$(echo "$api_resp" | grep -m1 -oE '"name":\s*"[^\"]+' | cut -d\" -f4 || true)"
    fi
  fi
fi

if [[ -z "$latest_tag" ]]; then
  log "Couldn't fetch latest tag via GitHub API; will attempt to download from canonical release url if needed."
else
  log "Latest release tag: $latest_tag ($latest_name)"
fi

ask_yes_no() {
  prompt="$1"; default="${2:-y}"
  while true; do
    read -rp "$prompt [y/n] (default: $default): " yn
    yn="${yn:-$default}"
    case "$yn" in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer y or n.";;
    esac
  done
}

perform_update() {
  target="${1:-$DEFAULT_INSTALL_PATH}"
  mkdir -p "$(dirname "$target")"
  log "Downloading latest yt-dlp binary to $target ..."
  if curl -L --fail "$GITHUB_DL_URL" -o "$target.tmp" ; then
    chmod +x "$target.tmp"
    mv "$target.tmp" "$target"
    log "Installed yt-dlp to $target"
  else
    err "Failed to download binary from $GITHUB_DL_URL"
    rm -f "$target.tmp" || true
    return 1
  fi
}

if [[ -n "$installed_bin" ]]; then
  current_ver="$("$installed_bin" --version 2>/dev/null || true)"
  log "Detected installed yt-dlp at: $installed_bin (version: ${current_ver:-unknown})"
  if [[ -n "$latest_tag" ]]; then
    # compare versions heuristically
    if [[ "$current_ver" == "$latest_tag" || "$current_ver" == "${latest_tag#v}" ]]; then
      log "yt-dlp appears up-to-date."
    else
      log "Newer release available: $latest_tag (local: $current_ver)"
      if ask_yes_no "Update yt-dlp to latest now?" "y"; then
        # prefer brew if user has brew and yt-dlp is installed via brew
        if [[ -n "$BREW_PATH" && "$(brew list --versions yt-dlp 2>/dev/null || true)" != "" ]]; then
          log "Updating via Homebrew..."
          brew upgrade yt-dlp || brew install yt-dlp
          installed_bin="$(command -v yt-dlp || echo "$installed_bin")"
          log "Updated via Homebrew; path: $installed_bin"
        else
          # try to write to same location; fallback to /usr/local/bin
          target="$installed_bin"
          if [[ -z "$target" || "$target" == "" ]]; then
            target="$DEFAULT_INSTALL_PATH"
          fi
          if [[ ! -w "$(dirname "$target")" ]]; then
            if ask_yes_no "Need sudo to write to $(dirname "$target"). Use sudo?" "y"; then
              tmpfile="$(mktemp -t yt-dlp-XXXX)"
              log "Downloading to temporary file..."
              curl -L --fail "$GITHUB_DL_URL" -o "$tmpfile" || { err "Download failed"; rm -f "$tmpfile"; exit 1; }
              chmod +x "$tmpfile"
              sudo mv "$tmpfile" "$target"
              log "Moved new binary to $target (sudo)"
            else
              log "Will install to $ALT_INSTALL_PATH instead."
              perform_update "$ALT_INSTALL_PATH"
              installed_bin="$ALT_INSTALL_PATH"
            fi
          else
            perform_update "$target" && installed_bin="$target"
          fi
        fi
      else
        log "Skipping update as requested."
      fi
    fi
  else
    # no latest info -> prompt user to optionally install/refresh
    if ! command -v yt-dlp >/dev/null 2>&1; then
      if ask_yes_no "yt-dlp not found locally. Download & install latest binary to $ALT_INSTALL_PATH?" "y"; then
        perform_update "$ALT_INSTALL_PATH" && installed_bin="$ALT_INSTALL_PATH"
      fi
    fi
  fi
else
  log "yt-dlp not found locally."
  if ask_yes_no "Download & install latest yt-dlp binary to $ALT_INSTALL_PATH?" "y"; then
    perform_update "$ALT_INSTALL_PATH"
    installed_bin="$ALT_INSTALL_PATH"
  elif [[ -n "$BREW_PATH" && "$(ask_yes_no 'Install via Homebrew instead?' 'y')" ]]; then
    brew install yt-dlp
    installed_bin="$(command -v yt-dlp || true)"
  else
    err "yt-dlp not installed. You can install via Homebrew (brew install yt-dlp) or re-run this script and choose install."
    exit 1
  fi
fi

if [[ -z "$installed_bin" || ! -x "$installed_bin" ]]; then
  err "yt-dlp binary not found or not executable after install. Aborting."
  exit 1
fi

log "Using yt-dlp binary: $installed_bin (version: $("$installed_bin" --version 2>/dev/null || echo unknown))"

# --- Step 2: Prompt for URL and download options ---
echo
read -rp "Enter the YouTube (or supported site) URL to download: " TARGET_URL
if [[ -z "$TARGET_URL" ]]; then
  err "No URL provided. Exiting."
  exit 1
fi

echo
echo "Choose destination location:"
echo "  1) Desktop (default)"
echo "  2) Custom path"
read -rp "Select option [1/2] (default 1): " sel
sel="${sel:-1}"

if [[ "$sel" == "2" ]]; then
  read -rp "Enter full path to destination directory (will be created if missing): " CUSTOM_PATH
  DEST_DIR="${CUSTOM_PATH}"
  mkdir -p "$DEST_DIR"
else
  DEST_DIR="$HOME/Desktop"
fi
mkdir -p "$DEST_DIR"

# ask for folder name or default
echo
read -rp "Provide folder name for the download, or leave blank to auto-generate (timestamp + title): " FOLDER_NAME

# try to get a title for the URL (best-effort)
safe_title=""
if command -v "$installed_bin" >/dev/null 2>&1; then
  # try to get a single title (first item). Use --get-title (works for single videos and playlist entries)
  set +e
  title_out="$("$installed_bin" --get-title "$TARGET_URL" 2>/dev/null | head -n1 || true)"
  set -e
  if [[ -n "$title_out" ]]; then
    # sanitize for filesystem
    safe_title="$(echo "$title_out" | tr '/\\?%*:|\"<>.' '_' | tr -cd '[:print:]' | cut -c1-120)"
  fi
fi

if [[ -z "$FOLDER_NAME" ]]; then
  ts="$(date +"$TIMESTAMP_FMT")"
  if [[ -n "$safe_title" ]]; then
    FOLDER_NAME="${ts}_${safe_title}"
  else
    FOLDER_NAME="${ts}"
  fi
fi

OUT_PATH="$DEST_DIR/$FOLDER_NAME"
mkdir -p "$OUT_PATH"
log "Will save downloads to: $OUT_PATH"

# Audio or Video
echo
echo "Choose format:"
echo "  1) Audio (extract audio to mp3, best quality)"
echo "  2) Video (download best video+audio and merge - ffmpeg required)"
read -rp "Select option [1/2] (default 1): " fmt
fmt="${fmt:-1}"

# Cookies: try automatic option or manual cookies file
echo
echo "Cookies handling (needed for private/watch-later/age-restricted content):"
echo "  1) Attempt to auto-load cookies from browser (brave/chrome/firefox)"
echo "  2) Provide a cookies file (cookies.txt)"
echo "  3) No cookies / anonymous"
read -rp "Choose [1/2/3] (default 1): " cookie_choice
cookie_choice="${cookie_choice:-1}"

COOKIE_ARG=""
if [[ "$cookie_choice" == "1" ]]; then
  echo
  # yt-dlp uses names like "chrome" or "firefox"; brave is chromium-based and may work with 'chrome' profile,
  echo "Cookies: 1) Brave | 2) Chrome | 3) Firefox | 4) None"
    read -rp "Choice [1-4] (default 4): " c_sel
    COOKIE_ARG=""
    case "$c_sel" in
        1) COOKIE_ARG="--cookies-from-browser brave";;
        2) COOKIE_ARG="--cookies-from-browser chrome";;
        3) COOKIE_ARG="--cookies-from-browser firefox";;
    esac
elif [[ "$cookie_choice" == "2" ]]; then
  read -rp "Enter full path to cookies file (cookies.txt): " cookies_file
  if [[ -f "$cookies_file" ]]; then
    COOKIE_ARG="--cookies \"$cookies_file\""
  else
    err "Provided cookies file does not exist. Proceeding without cookies."
    COOKIE_ARG=""
  fi
else
  COOKIE_ARG=""
fi

# build yt-dlp options based on user choices
COMMON_OPTS="--no-mtime --geo-bypass"   # helpful defaults
# include retries and network friendly defaults
COMMON_OPTS+=" --retries 3 --fragment-retries 3 --no-overwrites"

# create log file
LOGFILE="$OUT_PATH/yt-dlp-$(date +%s).log"

if [[ "$fmt" == "1" ]]; then
  # Audio
  # use best audio extraction, prefer mp3 (if ffmpeg installed)
  AUDIO_OPTS="--extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata"
  FINAL_OPTS="$COMMON_OPTS $AUDIO_OPTS"
else
  # Video
  VIDEO_OPTS="-f bestvideo+bestaudio/best --merge-output-format mp4 --embed-subs --add-metadata"
  FINAL_OPTS="$COMMON_OPTS $VIDEO_OPTS"
fi

# assemble final command (note: cookie arg may contain spaces/quotes - handle carefully)
COMMAND="$installed_bin $FINAL_OPTS $COOKIE_ARG -o \"${OUT_PATH}/%(playlist_index)s - %(title)s.%(ext)s\" \"$TARGET_URL\""

echo
log "Performing a dry-run to validate parameters..."
# Dry-run using --simulate and --no-warnings; also capture verbose debug to logfile
set +e
# Build command array for safe expansion
eval_cmd=$(cat <<EOF
"$installed_bin" --simulate --no-warnings $FINAL_OPTS $COOKIE_ARG "$TARGET_URL"
EOF
)
# run the dry-run with verbose to the log file
bash -c "$eval_cmd" >"$LOGFILE" 2>&1
dry_exit=$?
set -e

if [[ $dry_exit -ne 0 ]]; then
  err "Dry-run failed. See $LOGFILE for details."
  echo
  echo "Attempting to parse the log for common issues..."
  log "Last lines of log:"
  tail -n 40 "$LOGFILE" || true
  echo
  # quick diagnostic heuristics:
  if grep -q -i "ffmpeg" "$LOGFILE" 2>/dev/null; then
    echo "Possible cause: ffmpeg not installed or not in PATH. Some formats require ffmpeg to merge/extract. Install via Homebrew: 'brew install ffmpeg'."
  fi
  if grep -q -i "cookie" "$LOGFILE" 2>/dev/null || grep -q -i "Sign in to confirm" "$LOGFILE" 2>/dev/null; then
    echo "Possible cause: authentication required. Try using --cookies-from-browser with your browser (Chrome/Brave/Firefox) or export cookies to a cookies.txt and provide it."
    echo "Tip: yt-dlp supports '--cookies-from-browser chrome' and '--cookies-from-browser firefox'."
  fi
  if grep -q -i "404" "$LOGFILE" 2>/dev/null || grep -q -i "not found" "$LOGFILE" 2>/dev/null; then
    echo "Possible cause: URL not accessible or private/removed."
  fi
  if grep -q -i "HTTP Error 403" "$LOGFILE" 2>/dev/null; then
    echo "Possible cause: access blocked (403). Try cookies, different network/IP, or check that the video is available in your region."
  fi
  echo
  echo "You can open the log at: $LOGFILE"
  if ask_yes_no "Continue and attempt actual download anyway?" "n"; then
    log "Proceeding with actual download (may fail)..."
  else
    log "Aborting per user choice."
    exit 1
  fi
else
  log "Dry-run succeeded. Proceeding to download. Full verbose output will be saved to $LOGFILE"
fi

# run actual download with verbose logging (-v)
set +e
# create a wrapper to run the final command (safe eval)
final_eval=$(cat <<EOF
"$installed_bin" -v $FINAL_OPTS $COOKIE_ARG -o "${OUT_PATH}/%(playlist_index)s - %(title)s.%(ext)s" "$TARGET_URL"
EOF
)
bash -c "$final_eval" >>"$LOGFILE" 2>&1
final_exit=$?
set -e

if [[ $final_exit -eq 0 ]]; then
  log "Download completed successfully. Check folder: $OUT_PATH"
  log "Log saved to: $LOGFILE"
  exit 0
else
  err "Download failed (exit code $final_exit). See $LOGFILE for full details."
  echo
  echo "Common diagnostics / suggested steps:"
  echo "  - Check $LOGFILE (tail -n 80 $LOGFILE) for the yt-dlp error and stacktrace."
  echo "  - If 'ffmpeg' errors appear: install ffmpeg (brew install ffmpeg)."
  echo "  - If cookie/auth errors: try --cookies-from-browser chrome or export cookies via a browser extension to cookies.txt and pass it."
  echo "  - If HTTP 403/geo-block: try different network or proxy (yt-dlp supports --proxy)."
  echo "  - If --cookies-from-browser fails on Brave: try 'chrome' (Brave is Chromium-based) OR export cookie file manually."
  echo
  echo "You can paste the last 80 lines of $LOGFILE here and I can help analyse the error."
  exit $final_exit
fi


