# Release Notes

This repository uses [`CHANGELOG.md`](../CHANGELOG.md) as the canonical release notes file.

## Current Public Snapshot

The current public documentation pass includes:

- a rewritten README
- screenshot guidance and production screenshot indexing
- architecture and folder documentation
- API documentation
- release process guidance
- GitHub workflow and contribution templates
- repository metadata cleanup

## What to Update for a Release

Before tagging a release:

1. Update `CHANGELOG.md`
2. Verify `flutter analyze`
3. Verify `flutter test`
4. Confirm the backend contract still matches the documented endpoints
5. Add screenshots if the release is intended for public presentation
