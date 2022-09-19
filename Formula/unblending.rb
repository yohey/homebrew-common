class Unblending < Formula
  desc "Decomposing an input image into layers via \"color unblending\""
  homepage "https://github.com/yuki-koyama/unblending"
  head "https://github.com/yuki-koyama/unblending.git"

  depends_on "cmake" => :build

  depends_on "eigen"
  depends_on "qt@5"

  def install
    args = std_cmake_args
    args << "-DUNBLENDING_BUILD_CLI_APP=ON"
    args << "-DUNBLENDING_BUILD_GUI_APP=ON"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
      bin.install "unblending-cli/unblending-cli"
      prefix.install "unblending-gui/unblending-gui.app"
    end
  end
end
