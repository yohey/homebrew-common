class Gnuplot < Formula
  desc "Command-driven, interactive function plotting"
  homepage "http://www.gnuplot.info/"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.2.8/gnuplot-5.2.8.tar.gz"
  sha256 "60a6764ccf404a1668c140f11cc1f699290ab70daa1151bb58fed6139a28ac37"


  head do
    url "https://git.code.sf.net/p/gnuplot/gnuplot-main.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-aquaterm", "Build with AquaTerm support (first: brew cask install aquaterm)"
  option "with-wxmac", "Build with wxmac support"

  depends_on "pkg-config" => :build
  depends_on "gd"
  depends_on "libcerf"
  depends_on "lua"
  depends_on "pango"
  depends_on "qt"
  depends_on "readline"
  depends_on "wxmac" => :optional

  def install
    # Qt5 requires c++11 (and the other backends do not care)
    ENV.cxx11

    if build.with? "aquaterm"
      ENV.prepend "CPPFLAGS", "-F/Library/Frameworks"
      ENV.prepend "LDFLAGS", "-F/Library/Frameworks"
    end

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-readline=#{Formula["readline"].opt_prefix}
      --without-tutorial
      --with-qt
      --without-x
    ]

    args << "--disable-wxwidgets" if build.without? "wxmac"
    args << (build.with?("aquaterm") ? "--with-aquaterm" : "--without-aquaterm")

    system "./prepare" if build.head?
    system "./configure", *args
    ENV.deparallelize # or else emacs tries to edit the same file with two threads
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/gnuplot", "-e", <<~EOS
      set terminal dumb;
      set output "#{testpath}/graph.txt";
      plot sin(x);
    EOS
    assert_predicate testpath/"graph.txt", :exist?
  end
end
