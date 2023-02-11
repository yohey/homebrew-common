class MozcEmacsHelper < Formula
  desc "Mozc - a Japanese Input Method Editor designed for multi-platform"
  homepage "https://github.com/google/mozc.git"
  url "https://github.com/google/mozc.git", :using => :git, :revision => "afb03ddfe72dde4cf2409863a3bfea160f7a66d8"
  version "afb03dd"

  depends_on "ninja" => :build
  depends_on "pyenv" => :build
  depends_on "openssl@1.1" => :build
  depends_on "readline" => :build
  depends_on "zlib" => :build
  depends_on "bzip2" => :build
  depends_on xcode: :build

  patch :p1 do
    url "https://gist.githubusercontent.com/10sr/f5719ec8c2e42eb12fcb51b9a33d1505/raw/633ab51170fd2e8b71a03139464c79fe46209894/mozc_emacs_helper.patch"
    sha256 "7ed609badf38bb572291b46821447247e67844f36a338f7e6126753a3fd93aa4"
  end

  patch :DATA

  def install
    ENV.append_path "PATH", HOMEBREW_PREFIX/"bin"
    ENV.append_path "PATH", Pathname(`pyenv root`.chomp)/"shims"

    ENV.prepend "LDFLAGS",  "-L#{Formula["zlib"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["zlib"].opt_include}"
    ENV.prepend "LDFLAGS",  "-L#{Formula["bzip2"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["bzip2"].opt_include}"

    system "pyenv", "install", "-s", "2.7.18"
    system "pyenv", "local", "2.7.18"

    version = `xcodebuild -version -sdk macosx SDKVersion`.chomp
    ENV["GYP_DEFINES"] = "mac_sdk=#{version} mac_deployment_target=#{version}"

    path = Pathname(`xcodebuild -version -sdk macosx Path`.chomp)
    ENV.prepend "CPPFLAGS", "-I#{path/"System/Library/Frameworks/CoreGraphics.framework/Versions/Current/Headers"}"

    cd "src" do
      system "python", "build_mozc.py", "gyp", "--noqt", "--branding=GoogleJapaneseInput"
      system "python", "build_mozc.py", "build", "-c", "Release", "unix/emacs/emacs.gyp:mozc_emacs_helper"
    end

    bin.install Dir["src/out_mac/Release/mozc_emacs_helper"]
  end
end

__END__
--- a/src/base/mac_util.mm
+++ b/src/base/mac_util.mm
@@ -34,6 +34,8 @@
 #include <launch.h>
 #include <CoreFoundation/CoreFoundation.h>
 #include <IOKit/IOKitLib.h>
+#include <CGWindow.h>
+#include <CGWindowLevel.h>
 
 #include "base/const.h"
 #include "base/logging.h"
