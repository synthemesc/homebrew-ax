class Ax < Formula
  desc "Expose macOS accessibility tree as JSON for AI agents"
  homepage "https://github.com/synthemesc/ax"
  url "https://github.com/synthemesc/ax/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on :macos
  depends_on xcode: ["14.0", :build]

  def install
    axlockd_path = "#{libexec}/axlockd.app/Contents/MacOS/axlockd"

    # Build ax with configured axlockd path
    system "xcodebuild", "build",
           "-scheme", "ax",
           "-configuration", "Release",
           "-derivedDataPath", buildpath/"build",
           "SYMROOT=#{buildpath}/build",
           "OTHER_CFLAGS=-DAXLOCKD_PATH_VALUE='\"#{axlockd_path}\"'"

    # Build axlockd
    system "xcodebuild", "build",
           "-scheme", "axlockd",
           "-configuration", "Release",
           "-derivedDataPath", buildpath/"build",
           "SYMROOT=#{buildpath}/build"

    bin.install buildpath/"build/Build/Products/Release/ax"
    libexec.install buildpath/"build/Build/Products/Release/axlockd.app"
  end

  def caveats
    <<~EOS
      ax requires Accessibility permission to function.
      Grant access in: System Settings > Privacy & Security > Accessibility

      For screenshots, also grant Screen Recording permission.

      For input locking (ax lock), axlockd.app also needs Accessibility permission.
    EOS
  end

  test do
    output = shell_output("#{bin}/ax ls 2>&1", 0)
    assert_match "displays", output
  end
end
