# AGENTS.md — Guidelines for AI Agents Working on coulof/homebrew-tap

This repository contains the Homebrew tap formula for [rancher/k3k](https://github.com/rancher/k3k).

---

## ⚠️ CRITICAL RULE: Version Bumping & Checksums

When bumping the formula to a new version:

1. **DO NOT recompute or calculate checksums manually** by downloading binaries or source tarballs.
2. **ALWAYS fetch the official release checksums file directly from GitHub releases**:
   ```
   https://github.com/rancher/k3k/releases/download/v<VERSION>/k3k_<VERSION>_checksums.txt
   ```
   *Example command to view official checksums:*
   ```sh
   curl -sL https://github.com/rancher/k3k/releases/download/v1.2.0/k3k_1.2.0_checksums.txt
   ```

3. **Extract the exact SHA256 hashes** from that file for the following 4 release binary artifacts:
   - `k3kcli-darwin-arm64` (macOS Apple Silicon)
   - `k3kcli-darwin-amd64` (macOS Intel)
   - `k3kcli-linux-arm64`  (Linux ARM64)
   - `k3kcli-linux-amd64`  (Linux AMD64)

4. **Update `k3k.rb`** with the new `version` string and corresponding `sha256` hashes.

---

## Formula Architecture & Conventions

- **Binary Distribution**: This tap distributes upstream pre-compiled `k3kcli` binaries for speed and reliability across environments.
- **Binary Permissions**: Immediately after `bin.install binary_name => "k3kcli"`, add `chmod 0555, bin/"k3kcli"`. Raw binary downloads may not preserve executable bits when extracted into the sandbox, which will cause `generate_completions_from_executable` to fail with `EACCES`.
- **Binary vs Formula Name**: The formula is named `k3k`, while the installed binary is `k3kcli`.
- **Shell Completions**: `k3kcli` contains a Cobra `PersistentPreRunE` hook that requires a valid kubeconfig file, which causes completion generation to fail in clean/isolated installation sandboxes if no kubeconfig is present. To support completions safely, the formula creates a minimal dummy kubeconfig in `buildpath` and wraps `generate_completions_from_executable(bin/"k3kcli", shell_parameter_format: :cobra)` in `with_env(KUBECONFIG: ...)`.
- **Test Block**: The test block uses `assert_match "v#{version}", shell_output("#{bin}/k3kcli --version")` which bypasses the kubeconfig check.

---

## Versioned Formulae & Upstream Releases

1. **Naming Conventions for Versioned Formulae**:
   - File path: `Formula/k3k@<VERSION>.rb` (or `k3k@<VERSION>.rb`)
   - Class name: `class K3kAT<VERSION> < Formula` (Homebrew replaces `@` with `AT` and strips dots, e.g. `k3k@1.1` becomes `K3kAT11`).
   - Include `keg_only :versioned_formula` to prevent binary collisions with the default `k3k` formula.
2. **Checking Release Artifacts**:
   - Upstream occasionally publishes GitHub releases for Helm charts (e.g., `v1.1.1` was a chart release with no binaries uploaded).
   - Before attempting to bump or create a binary formula, verify that release artifacts and `k3k_<VERSION>_checksums.txt` actually exist on GitHub Releases. If only source tarballs exist, use a source-based formula (`depends_on "go" => :build`).

---

## Git Workflow

- Main branch: `main`.
- Remote: `https://github.com/coulof/homebrew-tap.git`.
- Commit convention: `chore: bump k3k formula to v<VERSION>` or standard conventional commit messages.
