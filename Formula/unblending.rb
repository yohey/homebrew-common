class Unblending < Formula
  desc "Decomposing an input image into layers via \"color unblending\""
  homepage "https://github.com/yuki-koyama/unblending"
  head "https://github.com/yuki-koyama/unblending.git"

  depends_on "cmake" => :build

  depends_on "eigen"
  depends_on "qt@5"

  def install
    qt5lib = Formula["qt@5"].opt_lib

    args = std_cmake_args
    args << "-DUNBLENDING_BUILD_CLI_APP=ON"
    args << "-DUNBLENDING_BUILD_GUI_APP=ON"
    args << "-DQt5_DIR:PATH=#{qt5lib}/cmake/Qt5"
    args << "-DQt5Core_DIR:PATH=#{qt5lib}/cmake/Qt5Core"
    args << "-DQt5Gui_DIR:PATH=#{qt5lib}/cmake/Qt5Gui"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
      bin.install "unblending-cli/unblending-cli"
      prefix.install "unblending-gui/unblending-gui.app"
    end
  end
end
