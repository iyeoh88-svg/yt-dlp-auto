# Changelog

All notable changes to yt-dlp-auto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
