class Waifu2x < Formula
  desc "Improved fork of Waifu2X C++ using OpenCL and OpenCV"
  homepage "https://github.com/DeadSix27/waifu2x-converter-cpp"
  url "https://github.com/DeadSix27/waifu2x-converter-cpp/archive/v5.3.3.tar.gz"
  sha256 "036d82bb4ec2e4a098b084e5f82f21d3a274c6c16e60e7d5dd44478f2cb463ed"
  version "5.3.3"

  depends_on "cmake" => :build
  depends_on "llvm" => :build

  depends_on "opencv"

  def install
    llvm = Formula["llvm"]
    opencv = Formula["opencv"]

    args = std_cmake_args
    args << "-DCMAKE_C_COMPILER=#{llvm.opt_prefix}/bin/clang"
    args << "-DCMAKE_CXX_COMPILER=#{llvm.opt_prefix}/bin/clang++"
    args << "-DOPENCV_PREFIX=#{opencv.opt_prefix}"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end
