class Imagemagick < Formula
  homepage "http://www.imagemagick.org"
  url "http://www.imagemagick.org/download/releases/ImageMagick-6.9.1-3.tar.xz"
  mirror "https://downloads.sourceforge.net/project/imagemagick/6.9.1-sources/ImageMagick-6.9.1-3.tar.xz"
  sha256 "5fd180603e60c624c05c644a8340f4f4e92c19dc3c41d374d38f76c69cd48ba3"

  head "https://subversion.imagemagick.org/subversion/ImageMagick/trunk",
       :using => :svn

  bottle do
    revision 2
    sha256 "93ab704f93848a9814c23ebfa318215db417ad1c635e0ab764b486f23d47c94a" => :yosemite
    sha256 "48b860afdc1aa673e33c46473220e7a1f6e2fb6a411c643193998c66e37d8e55" => :mavericks
    sha256 "c8998c1ff9224a488301a9dade2d85cc645a0f03eb425d8242bbc0898462de43" => :mountain_lion
  end

  deprecated_option "enable-hdri" => "with-hdri"

  option "with-fftw", "Compile with FFTW support"
  option "with-hdri", "Compile with HDRI support"
  option "with-jp2", "Compile with Jpeg2000 support"
  option "with-openmp", "Compile with OpenMP support"
  option "with-perl", "enable build/install of PerlMagick"
  option "with-quantum-depth-8", "Compile with a quantum depth of 8 bit"
  option "with-quantum-depth-16", "Compile with a quantum depth of 16 bit"
  option "with-quantum-depth-32", "Compile with a quantum depth of 32 bit"
  option "without-opencl", "Disable OpenCL"
  option "without-magick-plus-plus", "disable build/install of Magick++"

  depends_on "xz"
  depends_on "libtool" => :run
  depends_on "pkg-config" => :build

  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "freetype" => :recommended

  depends_on :x11 => :optional
  depends_on "fontconfig" => :optional
  depends_on "little-cms" => :optional
  depends_on "little-cms2" => :optional
  depends_on "libwmf" => :optional
  depends_on "librsvg" => :optional
  depends_on "liblqr" => :optional
  depends_on "openexr" => :optional
  depends_on "ghostscript" => :optional
  depends_on "webp" => :optional
  depends_on "homebrew/versions/openjpeg21" if build.with? "jp2"
  depends_on "fftw" => :optional
  depends_on "pango" => :optional

  needs :openmp if build.with? "openmp"

  skip_clean :la

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-shared
      --disable-static
      --with-modules
    ]

    if build.with? "openmp"
      args << "--enable-openmp"
    else
      args << "--disable-openmp"
    end
    args << "--disable-opencl" if build.without? "opencl"
    args << "--without-gslib" if build.without? "ghostscript"
    args << "--without-perl" if build.without? "perl"
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" if build.without? "ghostscript"
    args << "--without-magick-plus-plus" if build.without? "magick-plus-plus"
    args << "--enable-hdri=yes" if build.with? "hdri"
    args << "--enable-fftw=yes" if build.with? "fftw"
    args << "--without-pango" if build.without? "pango"

    if build.with? "quantum-depth-32"
      quantum_depth = 32
    elsif build.with? "quantum-depth-16"
      quantum_depth = 16
    elsif build.with? "quantum-depth-8"
      quantum_depth = 8
    end

    if build.with? "jp2"
      args << "--with-openjp2"
    else
      args << "--without-openjp2"
    end

    args << "--with-quantum-depth=#{quantum_depth}" if quantum_depth
    args << "--with-rsvg" if build.with? "librsvg"
    args << "--without-x" if build.without? "x11"
    args << "--with-fontconfig=yes" if build.with? "fontconfig"
    args << "--with-freetype=yes" if build.with? "freetype"
    args << "--with-webp=yes" if build.with? "webp"

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  def caveats
    s = <<-EOS.undent
      For full Perl support you must install the Image::Magick module from the CPAN.
        https://metacpan.org/module/Image::Magick

      The version of the Perl module and ImageMagick itself need to be kept in sync.
      If you upgrade one, you must upgrade the other.

      For this version of ImageMagick you should install
      version #{version} of the Image::Magick Perl module.
    EOS
    s if build.with? "perl"
  end

  test do
    system "#{bin}/identify", test_fixtures("test.png")
  end
end
