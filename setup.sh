#!/bin/bash
######################################################################
# Configuration

BINUTILS=http://gnu.mirror.iweb.com/binutils/binutils-2.25.1.tar.bz2
GCC=http://gnu.mirror.iweb.com/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2
#GRUB=ftp://ftp.gnu.org/gnu/grub/grub-2.00.tar.gz          # stable
GRUB=http://alpha.gnu.org/gnu/grub/grub-2.02~beta3.tar.gz  # beta
XORRISO=ftp://gnu.mirror.iweb.com/xorriso/xorriso-1.4.0.tar.gz
MPC=ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
GMP=https://gmplib.org/download/gmp/gmp-6.1.0.tar.xz
MPFR=http://www.mpfr.org/mpfr-current/mpfr-3.1.4.tar.xz
NEWLIB=ftp://sourceware.org/pub/newlib/newlib-2.2.0.20150623.tar.gz

TARGET=x86_64-elf

TOPLEVEL=$PWD
# Archives is where we store .tar.gz, etc. files
ARCHIVES=$TOPLEVEL/archives
# Packages is where we build
PACKAGES=$TOPLEVEL/packages
# Cross is where we install
CROSS=$TOPLEVEL/cross

######################################################################
# Edit below at your own peril!

FILES="$BINUTILS $GCC $GRUB $XORRISO $MPC $GMP $MPFR $NEWLIB"

function header {
    echo =============== $1 ===============
}
function download {
    header "Downloading: $1"
    curl $1 -O
}
function error {
    echo Fatal error: $1
    exit 1
}

cd $ARCHIVES
for FILE in $FILES; do
    if [ ! -f $ARCHIVES/$(basename $FILE) ]; then
        download $FILE
    fi
done

function clean() {
    echo Cleaning...
    rm -rf packages/* cross/*
}

function build_gcc() {
    GCC_BN=$(basename $GCC)
    GCC_DIR="${GCC_BN%.*.*}"
    header "Building $GCC_DIR"

    NEWLIB_BN=$(basename $NEWLIB)
    BU_BN=$(basename $BINUTILS)
    GMP_BN=$(basename $GMP)
    MPC_BN=$(basename $MPC)
    MPFR_BN=$(basename $MPFR)

    MPC_DIR="${MPC_BN%.*.*}"
    MPC_DIR2="${MPC_DIR%-*}"
    GMP_DIR="${GMP_BN%.*.*}"
    GMP_DIR2="${GMP_DIR%-*}"
    MPFR_DIR="${MPFR_BN%.*.*}"
    MPFR_DIR2="${MPFR_DIR%-*}"

    GCC_SRC=$PACKAGES/gcc-src
    GCC_BLD=$PACKAGES/gcc-build

    # Extraction
    rm -rf $GCC_SRC && mkdir $GCC_SRC && cd $GCC_SRC
    tar xf $ARCHIVES/$NEWLIB_BN --strip-components 1
    tar xf $ARCHIVES/$BU_BN --strip-components 1
    tar xf $ARCHIVES/$GMP_BN && mv $GMP_DIR $GMP_DIR2
    tar xf $ARCHIVES/$MPC_BN && mv $MPC_DIR $MPC_DIR2
    tar xf $ARCHIVES/$MPFR_BN && mv $MPFR_DIR $MPFR_DIR2
    tar xf $ARCHIVES/$GCC_BN --strip-components 1

    rm -rf $GCC_BLD && mkdir $GCC_BLD && cd $GCC_BLD
    $GCC_SRC/configure --target=$TARGET -prefix=$CROSS --enable-languages=c \
                       --disable-nls --disable-tls --disable-shared \
                       --disable-libssp --disable-libgomp --disable-multilib \
                       --disable-decimal-float --disable-threads \
                       --disable-libmudflap \
                       --with-newlib || error "$GCC_DIR configure"
    make && make install || error "$GCC_DIR make"
}

function build_xorriso() {
    XORRISO_BN=$(basename $XORRISO)
    XORRISO_DIR="${XORRISO_BN%.*.*}"
    header "Building $XORRISO_DIR"

    XORRISO_SRC=$PACKAGES/xorriso-src
    XORRISO_BLD=$PACKAGES/xorriso-build

    cd $PACKAGES
    rm -rf $XORRISO_DIR && tar xf $ARCHIVES/$XORRISO_BN && cd $XORRISO_DIR
    ./configure --prefix=$CROSS || error "$XORRISO_DIR configure"
    make && make install || error "$XORRISO_DIR make"    
}

function build_grub() {
    GRUB_BN=$(basename $GRUB)
    GRUB_DIR="${GRUB_BN%.*.*}"
    header "Building $GRUB_DIR"

    GRUB_SRC=$PACKAGES/grub-src
    GRUB_BLD=$PACKAGES/grub-build
    
    rm -rf $GRUB_SRC && mkdir $GRUB_SRC && cd $GRUB_SRC
    tar xf $ARCHIVES/$GRUB_BN --strip-components 1

    rm -rf $GRUB_BLD && mkdir $GRUB_BLD && cd $GRUB_BLD
    $GRUB_SRC/configure --build=$TARGET --target=$TARGET --prefix=$CROSS \
                        --disable-werror --disable-device-mapper \
                        TARGET_CC=$CROSS/bin/x86_64-elf-gcc \
                        TARGET_OBJCOPY=$CROSS/bin/x86_64-elf-objcopy \
                        TARGET_STRIP=$CROSS/bin/x86_64-elf-strip \
                        TARGET_NM=$CROSS/bin/x86_64-elf-nm \
                        TARGET_RANLIB=$CROSS/binx86_64-elf-ranlib \
        || error "$GRUB_DIR configure"
    make && make install || error "$GRUB_DIR make"
}

while [ $# -gt 0 ]; do case "$1" in
gcc)
	build_gcc;;
xorriso)
    build_xorriso;;
grub)
	build_grub;;
clean)
	clean;;
*)
	echo unknown argument: $1
	echo available actions: gcc, xorriso, grub, clean;;
esac; shift; done
