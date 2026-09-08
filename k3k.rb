class K3k < Formula
  desc "Run isolated k3s clusters within a host Kubernetes cluster"
  homepage "https://github.com/rancher/k3k"
  version "1.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-darwin-arm64"
      sha256 "bb4e563f8afbd1bae44b53842835525bae0a6fbf15ee04654364e40e9efb2759"
    else
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-darwin-amd64"
      sha256 "63e675f3f4e6708a816d30c2e49dc4eefb37efc49e62029ef1a40872243bb168"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-linux-arm64"
      sha256 "102c8262d32ee52ebed08fcd080556eaa473304b7cfd58c3410fb2dcf8d069ef"
    else
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-linux-amd64"
      sha256 "bb74d6ead3b7c5dd1cd843e32c3a2affd9a88b3b554a8c55c9105444393e3952"
    end
  end

  def install
    binary_name = if OS.mac?
      Hardware::CPU.arm? ? "k3kcli-darwin-arm64" : "k3kcli-darwin-amd64"
    else
      Hardware::CPU.arm? ? "k3kcli-linux-arm64" : "k3kcli-linux-amd64"
    end
    bin.install binary_name => "k3kcli"
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/k3kcli --version")
  end
end
