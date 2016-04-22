#!/bin/bash

BINUTILS=http://gnu.mirror.iweb.com/binutils/binutils-2.25.1.tar.bz2
GCC=http://gnu.mirror.iweb.com/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2
MPC=ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
GMP=https://gmplib.org/download/gmp/gmp-6.1.0.tar.xz
MPFR=http://www.mpfr.org/mpfr-current/mpfr-3.1.4.tar.xz
NEWLIB=ftp://sourceware.org/pub/newlib/newlib-2.2.0.20150623.tar.gz
TARGET=x86_64-elf

TOPLEVEL=$PWD
ARCHIVES=$TOPLEVEL/archives
PACKAGES=$TOPLEVEL/packages

FILES="$BINUTILS $GCC $MPC $GMP $MPFR $NEWLIB"

if [ ! -z $1 ]; then
    echo Cleaning...
    rm -rf packages/* cross/*
    exit
fi

function header {
    echo =============== $1 ===============
}
function download {
    header "Downloading: $1"
    curl $1 -O
}

cd $ARCHIVES
for FILE in $FILES; do
    if [ ! -f $ARCHIVES/$(basename $FILE) ]; then
        download $FILE
    fi
done

# GCC ###########################################################################

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
$GCC_SRC/configure --target=$TARGET -prefix=$TOPLEVEL/cross --enable-languages=c \
                   --disable-nls --disable-tls --disable-shared --disable-libssp --disable-libgomp \
                   --disable-multilib --disable-decimal-float --disable-threads --disable-libmudflap \
                   --with-newlib
make && make install
