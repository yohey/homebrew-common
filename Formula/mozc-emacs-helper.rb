class MozcEmacsHelper < Formula
  desc "Mozc - a Japanese Input Method Editor designed for multi-platform"
  homepage "https://github.com/google/mozc.git"
  url "https://github.com/google/mozc.git", :using => :git, :revision => "afb03ddfe72dde4cf2409863a3bfea160f7a66d8"
  version "afb03dd"

  depends_on "ninja" => :build

  patch :p1 do
    url "https://gist.githubusercontent.com/10sr/f5719ec8c2e42eb12fcb51b9a33d1505/raw/633ab51170fd2e8b71a03139464c79fe46209894/mozc_emacs_helper.patch"
    sha256 "7ed609badf38bb572291b46821447247e67844f36a338f7e6126753a3fd93aa4"
  end

  def install
    version = `xcodebuild -version -sdk macosx SDKVersion`.chomp
    ENV["GYP_DEFINES"] = "mac_sdk=#{version} mac_deployment_target=#{version}"

    cd "src" do
      system "python2", "build_mozc.py", "gyp", "--noqt", "--branding=GoogleJapaneseInput"
      system "python2", "build_mozc.py", "build", "-c", "Release", "unix/emacs/emacs.gyp:mozc_emacs_helper"
    end

    bin.install Dir["src/out_mac/Release/mozc_emacs_helper"]
  end
end
