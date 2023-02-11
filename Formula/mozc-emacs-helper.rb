class MozcEmacsHelper < Formula
  desc "Mozc - a Japanese Input Method Editor designed for multi-platform"
  homepage "https://github.com/google/mozc.git"
  url "https://github.com/google/mozc.git", :using => :git, :tag => "2.28.4880.102"
  version "2.28.4880.102"

  depends_on xcode: :build
  depends_on "python@3.11" => :build
  depends_on "ninja" => :build
  depends_on "six" => :build
  uses_from_macos "curl" => :build

  patch :DATA

  def install
    target = `xcodebuild -version -sdk macosx SDKVersion`.chomp
    ENV["GYP_DEFINES"] = "mac_sdk=#{target} mac_deployment_target=#{target}"

    cd "src" do
      system "curl", "-sL", "-o", "third_party/abseil-cpp/absl/base/integral_types.h",
             "https://raw.githubusercontent.com/google/s2geometry/e5eb2c38582392888e48e5b982add6aafa94f0c8/src/s2/third_party/absl/base/integral_types.h"
      system "python", "build_mozc.py", "gyp", "--noqt", "--branding=GoogleJapaneseInput"
      system "python", "build_mozc.py", "build", "-c", "Release", "unix/emacs/emacs.gyp:mozc_emacs_helper"
    end

    bin.install Dir["src/out_mac/Release/mozc_emacs_helper"]
  end
end

__END__
--- a/src/build_mozc.py
+++ b/src/build_mozc.py
@@ -165,6 +165,8 @@ def GetGypFileNames(options):
     if not PkgExists('ibus-1.0 >= 1.4.1'):
       logging.info('removing ibus.gyp.')
       gyp_file_names.remove('%s/unix/ibus/ibus.gyp' % SRC_DIR)
+  elif options.target_platform == 'Mac':
+    gyp_file_names.extend(glob.glob('%s/unix/emacs/*.gyp' % SRC_DIR))
   gyp_file_names.sort()
   return gyp_file_names
 
--- a/src/mac/mac.gyp
+++ b/src/mac/mac.gyp
@@ -519,7 +519,6 @@
             ['branding=="GoogleJapaneseInput"', {
               'dependencies': [
                 'DevConfirmPane',
-                'codesign_client',
               ],
             }],
           ],
