# Contributing to yt-dlp-auto

Thanks for your interest in contributing! 🎉

## How to Contribute

### Reporting Bugs
- Check if the issue already exists in [Issues](../../issues)
- Include your macOS version, bash version, and yt-dlp version
- Provide the log file output if possible
- Describe steps to reproduce

### Suggesting Features
- Open an issue with the `enhancement` label
- Explain the use case and why it would be helpful
- Be open to discussion

### Submitting Code

1. **Fork the repository**
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes:**
   - Follow existing code style
   - Test thoroughly on macOS
   - Add comments for complex logic
4. **Commit your changes:**
   ```bash
   git commit -m "Add: brief description of changes"
   ```
5. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Open a Pull Request:**
   - Describe what changed and why
   - Reference any related issues

## Code Guidelines

- Use bash best practices (shellcheck is your friend)
- Keep the interactive prompts user-friendly
- Add helpful error messages
- Test on different macOS versions if possible
- Maintain backwards compatibility when feasible

## Testing

Before submitting:
- [ ] Script runs without errors
- [ ] Dry-run validation works
- [ ] Error messages are helpful
- [ ] No breaking changes to existing functionality

## Questions?

Feel free to open an issue for discussion before starting work on major changes.

---

By contributing, you agree that your contributions will be licensed under the MIT License.
