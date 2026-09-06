# Changelog

All notable changes to yt-dlp-auto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2026-09-07

### Fixed
- The single-line progress bar could "spam" the terminal with junk lines instead of updating in place. Cause: the rendered line (bar + full title) could be longer than the terminal's actual width, so it wrapped onto multiple rows - and `\r`/clear-to-end-of-line only rewind the current row, leaving fragments of earlier renders behind on each redraw. It now measures the real terminal width and dynamically sizes the bar and truncates the title (or drops the title/shrinks the bar entirely on very narrow terminals) so the line can never wrap.
- The progress line parser used `|` as a field delimiter, which could corrupt the display for titles that themselves contain `|` (a common convention, e.g. "Song Name | Official Audio"). Switched to a control character that can't appear in real titles.

## [1.2.1] - 2026-09-06

### Fixed
- Self-update crashed with a raw `mv: Permission denied` and no fallback when the script was installed somewhere not writable by the current user (e.g. moved into `/usr/local/bin`, which is root-owned by default on macOS). It now correctly checks whether the *install directory* is writable (not just the file), and offers a `sudo` fallback with clear messaging instead of silently failing.
- Same fix applied to the yt-dlp binary self-updater's sudo path, which had the same unchecked-`mv` gap.

## [1.2.0] - 2026-08-30

### Changed
- Replaced the raw, scrolling yt-dlp output with a single clean in-place progress bar: `Downloading: |xxxxxxxxxxx| 88% , [SongName] , 20/100 songs`
- Verbose debug output no longer prints to the terminal (still fully saved to the log file) - only the progress bar and real errors/warnings show on screen
- Works for both single downloads and playlists; the song counter updates per item

## [1.1.0] - 2026-08-30

### Added
- Live progress bar display during download (percentage, speed, ETA shown in the terminal in real time)

### Changed
- Download step now streams output through `tee` so progress is visible on screen while still being saved to the log file (previously all output was silently redirected to the log only)

## [1.0.0] - 2025-02-02

### Added
- Initial release
- Interactive prompts for URL, destination, format selection
- Automatic yt-dlp installation and updates
- Browser cookie extraction (Brave, Chrome, Firefox)
- Dry-run validation before download
- Detailed error diagnostics
- Verbose logging to file
- Script auto-update feature
- Support for audio (MP3) and video (MP4) downloads
- Automatic title sanitization for folder names
- Retry logic for network failures
- Metadata and thumbnail embedding

### Features
- macOS compatibility
- Homebrew integration
- Multiple cookie handling options
- Custom destination paths
- Helpful error messages with troubleshooting tips

---

## Release Notes

### Version Numbering
- **Major (X.0.0)**: Breaking changes or major feature overhauls
- **Minor (0.X.0)**: New features, backwards compatible
- **Patch (0.0.X)**: Bug fixes, minor improvements

### How to Update
The script checks for updates automatically. You can also manually update:
```bash
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/yt-dlp-auto/main/ytdl.sh -o ytdl.sh
chmod +x ytdl.sh
```
