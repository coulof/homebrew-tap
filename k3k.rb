class K3k < Formula
  desc "Run isolated k3s clusters within a host Kubernetes cluster"
  homepage "https://github.com/rancher/k3k"
  version "1.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-darwin-arm64"
      sha256 "8a59a3c1625050feac188a46c80cdbca1eaef577975d74999d3529d729e1eeb0"
    else
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-darwin-amd64"
      sha256 "9a244737d87f7dd845b0203be3de61294cbdc74177a8758aab74de990381cf6e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-linux-arm64"
      sha256 "04efce0968e7e7fd61f06e5f0f1aa15eed5cdda1fca6a71e1995baa6e1f88ea6"
    else
      url "https://github.com/rancher/k3k/releases/download/v#{version}/k3kcli-linux-amd64"
      sha256 "35a95255ab10cdd688e00527092d30a68b709bba1ba70903c07885fae4015f4c"
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
