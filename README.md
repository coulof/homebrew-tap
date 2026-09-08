# coulof/homebrew-tap

Homebrew tap for [k3k](https://github.com/rancher/k3k) (Rancher) — "Kubernetes in Kubernetes", running isolated k3s clusters inside a host Kubernetes cluster.

---

## Installation

```sh
brew tap coulof/tap
brew install k3k
```

Or install in a single command:

```sh
brew install coulof/tap/k3k
```

## Usage

This formula installs the **`k3kcli`** binary (formula is named `k3k`, binary is `k3kcli`).

```sh
k3kcli --version
k3kcli --help
```

`k3kcli` operates against your current Kubernetes context and respects `--kubeconfig`, `$KUBECONFIG`, and `~/.kube/config`.

## Updating

```sh
brew update
brew upgrade k3k
```

---

## Supported Architectures

Pre-built binaries are provided for:
- **macOS**: `darwin-arm64` (Apple Silicon), `darwin-amd64` (Intel)
- **Linux**: `linux-arm64`, `linux-amd64`

---

## Development & Maintenance

### Local Tap Testing

With modern Homebrew (>=4.6.4 / 6.0+), formulae cannot be installed directly from a loose file path and must reside within a tap:

```sh
# Copy formula into the tap repository
cp ./k3k.rb "$(brew --repository coulof/tap)/Formula/k3k.rb"

# Install and test
brew install --verbose coulof/tap/k3k
brew test coulof/tap/k3k
brew audit --strict coulof/tap/k3k
brew style coulof/tap/k3k
```

### Packaging Notes & Gotchas

- **Binary vs. Source**: This tap distributes upstream pre-compiled `k3kcli` release binaries.
- **Shell Completions**: Shell completions are omitted because `k3kcli`'s Cobra root command executes a `PersistentPreRunE` hook that attempts to load a kubeconfig file. In a clean sandbox/environment without a kubeconfig, running completion generation fails during build/installation. `--version` short-circuits before this hook, making `brew test` safe.

---

## Submitting to `homebrew-core`

When submitting `k3k` to official `homebrew-core`, source compilation is required (`depends_on "go" => :build`).

### 1. Source Formula Template

```ruby
class K3k < Formula
  desc "Run isolated k3s clusters within a host Kubernetes cluster"
  homepage "https://github.com/rancher/k3k"
  url "https://github.com/rancher/k3k/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "8ef1ea06300e18fe48a217b12144f28f1a168c3d356261fc3d75a53d8087bb7d"
  license "Apache-2.0"
  head "https://github.com/rancher/k3k.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X github.com/rancher/k3k/pkg/buildinfo.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"k3kcli"), "./cli"
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/k3kcli --version")
  end
end
```

### 2. Submission Workflow

1. Fork `Homebrew/homebrew-core` on GitHub.
2. Check out a local working branch:
   ```sh
   brew tap --force homebrew/core
   export HOMEBREW_NO_INSTALL_FROM_API=1
   cd "$(brew --repository homebrew/core)"
   git remote add fork git@github.com:<your-user>/homebrew-core.git
   git checkout -b k3k origin/master
   cp /path/to/k3k.rb Formula/k/k3k.rb
   ```
3. Run validation matching core CI checks:
   ```sh
   brew audit --strict --new --online k3k
   brew style k3k
   brew install --build-from-source --verbose k3k
   brew test k3k
   ```
4. Commit and open a PR.
   - **PR Title Format**: `k3k 1.1.0 (new formula)`
   - Note in PR description that the upstream binary name is `k3kcli`.

### 3. Post-Merge Maintenance & Autobumps

- `homebrew-core` automatically checks for upstream releases and creates upgrade PRs.
- Sanity-check livecheck filtering to ensure pre-release `-rc` tags are excluded:
  ```sh
  brew livecheck --debug k3k
  ```
