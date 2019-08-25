#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "+------------------------------------------------------------------------+"
echo "|                     congratulations WRF is Installing                      |"
echo "+------------------------------------------------------------------------+"
echo "|            Go for coffee because Its take some time...enjoy Boss              |"
echo "+------------------------------------------------------------------------+"
echo "|            Author: Subhadeep Maishal  Email: mtrs10006.17@bitmesra.ac.in               |"
echo "+------------------------------------------------------------------------+"

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to execute install.sh"
    exit 1
fi

# Install GCC & GC++ etc.
apt-get -y install build-essential gfortran
apt-get -y install csh
apt-get -y install perl
apt-get -y install m4 gzip curl wget
apt-get -y install mpich
apt-get -y install libhdf5-mpich-dev
apt-apt-get -y install libpng-dev
apt-get -y install libjasper-dev
apt-get -y install libnetcdff-dev
apt-apt-get -y install netcdf-bin
apt-apt-get -y install ncl-ncarg

cur_dir=$(pwd)


Build_WRF=$cur_dir/Build_WRF

mkdir -p $Build_WRF

echo "WRF will be compiled in $Build_WRF"

echo "All Compile Tests Passwd!!!"

# Building Libraries
cd $Build_WRF

mkdir -p LIBRARIES
LIBRARIES_DIR=$Build_WRF/LIBRARIES
cd $LIBRARIES_DIR
## Downloads libraries
if [ ! -f "mpich-3.0.4.tar.gz" ]; then
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/mpich-3.0.4.tar.gz
fi
if [ ! -f "netcdf-4.1.3.tar.gz" ]; then
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz
fi
if [ ! -f "jasper-1.900.1.tar.gz" ]; then
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
fi
if [ ! -f "libpng-1.2.50.tar.gz" ]; then
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
fi
if [ ! -f "zlib-1.2.7.tar.gz" ]; then
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz
fi

## install NetCDF
export COMP=intel
export CC=icc
export CFLAGS='-O3 -ip -fPIC'
export CXX=icpc
export CXXFLAGS='-O3 -ip'
export CPP='icc -E'
export CXXCPP='icpc -E'
export FC=ifort
export F77=ifort
export F9X=ifort
export FFLAGS='-O3 -ip -DARCH_INTEL'

tar zxvf netcdf-4.1.3.tar.gz
cd netcdf-4.1.3
./configure --prefix=$DIR/netcdf --disable-dap --disable-netcdf-4 --disable-shared
make
make install
export PATH=$DIR/netcdf/bin:$PATH
export NETCDF=$DIR/netcdf
cd ..

## install MPICH
tar xzvf mpich-3.0.4.tar.gz
cd mpich-3.0.4
./configure --prefix=$DIR/mpich
make
make install
export PATH=$DIR/mpich/bin:$PATH
cd ..

## install zlib
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar xzvf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=$DIR/grib2
make
make install
cd ..

## install libpng
tar xzvf libpng-1.2.50.tar.gz
cd libpng-1.2.50
./configure --prefix=$DIR/grib2
make
make install
cd ..

## install JasPer
tar xzvf jasper-1.900.1.tar.gz
cd jasper-1.900.1
./configure --prefix=$DIR/grib2
make
make install
cd ..


# Library Compatibility Tests
cd $Build_WRF/test
if [ ! -f "Fortran_C_NETCDF_MPI_tests.tar" ]; then
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
fi
tar -xf Fortran_C_NETCDF_MPI_tests.tar
## Test Fortran + C + NetCDF
cp ${NETCDF}/include/netcdf.inc .
gfortran -c 01_fortran+c+netcdf_f.f
gcc -c 01_fortran+c+netcdf_c.c
gfortran 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
./a.out > a.out.log
if grep -q "SUCCESS" a.out.log
then
        echo "Fortran + C + NetCDF test SUCCESS"
else
        echo "Error: test Fortran + C + NetCDF!"
        exit 1
fi
rm -f a.out a.out.log

## Test Fortran + C + NetCDF + MPI
cp ${NETCDF}/include/netcdf.inc .
mpif90 -c 02_fortran+c+netcdf+mpi_f.f
mpicc -c 02_fortran+c+netcdf+mpi_c.c
mpif90 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
mpirun ./a.out > a.out.log
if grep -q "SUCCESS" a.out.log
then
        echo "Fortran + C + NetCDF + MPI test SUCCESS"
else
        echo "Error: test Fortran + C + NetCDF + MPI!"
        exit 1
fi
rm -f a.out a.out.log

# Building WRFV3
cd $Build_WRF
if [ ! -f "WRFV3.9.1.1.TAR.gz" ]; then
wget http://www2.mmm.ucar.edu/wrf/src/WRFV3.9.1.1.TAR.gz
fi
tar zxvf WRFV3.9.1.1.TAR.gz
cd WRFV3

echo 34 |  ./configure
./compile em_real > log.compile
ls -ls main/*.exe
if [ ! -f "main/wrf.exe" ]; then
	echo "WRF INSTALLED FAILURE."
	exit 1
else
	echo "WRF INSTALLED SUCCESS!"
fi

# Building WPS
cd $Build_WRF
if [ ! -f "WPSV3.7.TAR.gz" ]; then
wget http://www2.mmm.ucar.edu/wrf/src/WPSV3.9.1.TAR.gz
fi
tar zxvf WPSV3.9.1.TAR.gz
cd WPS
./clean
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
echo 1 | ./configure
./compile > log.compile
ls -ls *.exe
if [ ! -f "geogrid.exe" ]; then
	echo "WPS INSTALLED FAILURE."
	exit 1
else
	echo "WPS INSTALLED SUCCESS!"
fi

# Static Geography Data
cd $Build_WRF
mkdir -p $Build_WRF/WPS_GEOG
if [ ! -f "geog_minimum.tar.bz2" ]; then
	wget http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_complete.tar.gz
        mv geog_complete.tar.gz WPS_GEOG
        cd WPS_GEOG
        tar zxvf  geog_complete.tar.gz
        mv geog_complete.tar.gz ..
fi
cd $Build_WRF/WPS
cp namelist.wps namelist.wps.bak
sed -i "s#/home/wrf/arch#$Build_WRF#g" namelist.wps
