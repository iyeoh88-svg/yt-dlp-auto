<img width="700" height="264" alt="image" src="https://github.com/user-attachments/assets/42287311-45fb-4415-9cc5-896e8171294c" />

# yt-dlp-auto Auto Audio/Video Download Script

A user-friendly bash script for macOS that simplifies downloading videos and audio from YouTube and other supported sites using yt-dlp. Features automatic updates, browser cookie extraction, and helpful error diagnostics.

## Features

-  **Auto-update**: Checks for and installs the latest version of yt-dlp
-  **Smart Cookie Handling**: Automatically extracts cookies from Brave, Chrome, or Firefox
-  **Flexible Output**: Choose Desktop or custom download location
-  **Audio or Video**: Extract audio as MP3 or download best quality video
-  **Dry-run Validation**: Tests parameters before downloading
-  **Detailed Logging**: Saves verbose logs for troubleshooting
-  **Error Diagnostics**: Provides helpful suggestions when things go wrong

## Prerequisites

- macOS (tested on recent versions)
- bash/sh (built-in)
- curl (built-in)
- sqlite3 (built-in)
- Optional but recommended:
  - jq (for better JSON parsing)
  - ffmpeg (for audio extraction and video merging)

### Installing Optional Dependencies

```bash
# Install via Homebrew
brew install jq ffmpeg
```

## Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/ytdl.sh
```

2. Make it executable:
```bash
chmod +x yt-dlp-auto.sh
```

3. (Optional) Move to your PATH:
```bash
mv yt-dlp-auto.sh /usr/local/bin/yt-dlp-auto
```

## Usage

Simply run the script and follow the interactive prompts:

```bash
./yt-dlp-auto.sh
```

or

yt-dlp-auto (if you did step 3)

### What the Script Will Ask:

1. **Update yt-dlp?** - Checks for latest version and offers to update
2. **Video URL** - Enter the YouTube or supported site URL
3. **Download Location** - Desktop (default) or custom path
4. **Folder Name** - Auto-generates from video title or you can specify
5. **Format** - Audio (MP3) or Video (MP4)
6. **Cookies** - Auto-extract from browser, provide file, or skip

### Example Session

```
Enter the YouTube URL: https://www.youtube.com/watch?v=dQw4w9WgxcQ
Choose destination: 1 (Desktop)
Folder name: [leave blank for auto]
Format: 1 (Audio MP3)
Cookies: 1 (Auto from Chrome)
```

## Cookie Handling

For age-restricted, private, or members-only content, you'll need cookies:

- **Option 1 (Recommended)**: Auto-extract from your browser (Brave/Chrome/Firefox)
- **Option 2**: Export cookies.txt using a browser extension like "Get cookies.txt"
- **Option 3**: Skip cookies (public videos only)

## Troubleshooting

The script includes built-in diagnostics. If download fails, check:

1. **Log file** - Located in your download folder as `yt-dlp-[timestamp].log`
2. **Common issues**:
   - Missing ffmpeg: `brew install ffmpeg`
   - Cookie errors: Try different browser or export cookies.txt
   - 403 errors: Content may be geo-blocked or require authentication
   - 404 errors: Video may be private, removed, or URL incorrect

## Output Format

Files are saved with this naming pattern:
```
[playlist_index] - [video_title].[ext]
```

Example: `01 - How to Download Videos.mp3`

## Advanced Features

- Automatic retries on network failures
- Fragment retry for interrupted downloads
- Metadata embedding
- Subtitle embedding (video mode)
- Thumbnail embedding (audio mode)
- No file overwrites (safe for re-runs)

## Supported Sites

yt-dlp supports 1000+ sites including:
- YouTube
- Vimeo
- Twitch
- Twitter/X
- TikTok
- And many more

See the [full list](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This script is released under the MIT License. See LICENSE file for details.

## Acknowledgments

- Built on top of [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- Inspired by the need for a more user-friendly download experience

## Disclaimer

This tool is for personal use only. Respect copyright laws and terms of service of the platforms you download from. Only download content you have permission to download.

---

**Note**: This is a community tool and is not affiliated with or endorsed by YouTube, Google, or any video platform.
