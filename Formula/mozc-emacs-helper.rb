class MozcEmacsHelper < Formula
  desc "Mozc - a Japanese Input Method Editor designed for multi-platform"
  homepage "https://github.com/google/mozc.git"
  url "https://github.com/google/mozc.git", tag: "3.34.6239"
  version "3.34.6260.1" # to match the cask "google-japanese-ime"

  depends_on "bazelisk" => :build
  depends_on "python@3.14" => :build
  depends_on xcode: :build

  patch :DATA

  def install
    xcode_ok, xcode_message = check_xcode

    if xcode_ok
      ohai xcode_message.strip
    else
      odie xcode_message
    end

    cd "src" do
      system "python3", "build_tools/update_deps.py",
             "--noqt", "--noninja", "--nondk"

      system "bazelisk", "build",
             "//unix/emacs:mozc_emacs_helper",
             "--config", "prod_macos",
             "--config", "stable_channel",
             "--config", "release_build",
             "--macos_cpus", "arm64"
    end

    bin.install "src/bazel-bin/unix/emacs/mozc_emacs_helper"
    pkgshare.install "src/unix/emacs/mozc.el"
  end

  def caveats
    _xcode_ok, xcode_message = check_xcode
    xcode_message
  end

  def check_xcode
    require "open3"

    xcode_stdout, xcode_stderr, xcode_status = Open3.capture3("xcodebuild", "-version")

    if xcode_status.success?
      return [
        true,
        <<~EOS
          Xcode found:
          #{xcode_stdout.strip}
        EOS
      ]
    end

    xcode_select_stdout, xcode_select_stderr, xcode_select_status = Open3.capture3("xcode-select", "-p")

    current_developer_dir =
      if xcode_select_status.success?
        xcode_select_stdout.strip
      else
        "(failed to run xcode-select -p: #{xcode_select_stderr.strip})"
      end

    [
      false,
      <<~EOS
        xcodebuild was not available.

        Current active developer directory:
          #{current_developer_dir}

        This formula requires full Xcode for building.
        Install Xcode from the App Store or Apple Developer site, then run:

          sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
          sudo xcodebuild -license accept

      EOS
    ]
  end
end

__END__
--- a/src/config.bzl
+++ b/src/config.bzl
@@ -33,7 +33,7 @@
 # The following command reverts it.
 # % git update-index --no-assume-unchanged config.bzl
 
-BRANDING = "Mozc"
+BRANDING = "GoogleJapaneseInput"
 
 BAZEL_TOOLS_PREFIX = "@bazel_tools"
 
--- a/src/version.bzl
+++ b/src/version.bzl
@@ -32,7 +32,7 @@ MAJOR = 3
 MINOR = 34
 
 # BUILD number used for the OSS version.
-BUILD_OSS = 6239
+BUILD_OSS = 6260
 
 # Number to be increased. This value may be replaced by other tools.
 BUILD = BUILD_OSS
