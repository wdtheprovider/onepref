# 1. Bump version in pubspec.yaml → 0.0.25
# 2. Commit
git add . && git commit -m "chore: release v0.0.25"

# 3. Push a tag — this triggers the workflow
git tag v0.0.25
git push origin v0.0.25
