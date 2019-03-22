#!/bin/bash -e
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/lore/yang/build/core-deps
usage() {
   echo "Usage: $0 <source directory> <optimized=on|off> \
   <buildType=default|asan> <mdsid=int|long> <valgrind=on|off> \
   <fortranInterface=on|off> <kernels=ON|OFF>"
}

srcdir=$1
[ ! -e "$srcdir" ] && 
  echo 'source directory does not exist' &&
  usage &&
  exit 1

opt=$2
[[ "on" != "$opt" &&
   "off" != "$opt" ]] && 
   usage &&
   exit 1

type=$3
[[ "default" != "$type" &&
   "asan" != "$type" ]] && 
   usage &&
   exit 1

mds_type=$4
[[ "int" != "$mds_type" &&
   "long" != "$mds_type" ]] &&
   usage &&
   exit 1

valgrind=$5
[[ "on" != "$valgrind" &&
   "off" != "$valgrind" ]] &&
   usage &&
   exit 1

ftn=$6
[[ "on" != "$ftn" &&
   "off" != "$ftn" ]] &&
   usage &&
   exit 1

kernels=$7
[[ "ON" != "$kernels" &&
   "OFF" != "$kernels" ]] &&
   usage &&
   exit 1

valgrind_cmd=""
valgrind_args=""
[ ${valgrind} = "on" ] &&
  valgrind_cmd="valgrind" &&
  valgrind_args="--leak-check=full"

flags_default=""
flags_asan="-fsanitize=address "
flags=flags_${type}

echo "flags ${!flags}"

set -x
cmake $srcdir \
-DCMAKE_C_COMPILER=mpicc \
-DCMAKE_CXX_COMPILER=mpicxx \
-DCMAKE_Fortran_COMPILER=gfortran \
-DSCOREC_CXX_OPTIMIZE=${opt} \
-DSCOREC_EXTRA_CXX_FLAGS="${!flags}" \
-DVALGRIND=${valgrind_cmd} \
-DVALGRIND_ARGS=${valgrind_args} \
-DMDS_ID_TYPE=${mds_type} \
-DPCU_COMPRESS=ON \
-DENABLE_ZOLTAN=ON \
-DPUMI_FORTRAN_INTERFACE=${ftn} \
-DENABLE_OMEGA_H=OFF \
-DIS_TESTING=ON \
-DENABLE_SIMMETRIX=ON \
-DSIM_MPI=mpich3.2.1 \
-DSIM_PARASOLID=${kernels} \
-DSIM_ACIS=${kernels} \
-DMESHES=/lore/yang/mfem_develop \
-DCMAKE_INSTALL_PREFIX=$PWD/install
set +x
