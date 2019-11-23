cmake ../mfem \
-DCMAKE_BUILD_TYPE=Debug \
-DMFEM_USE_MPI=YES \
-DMFEM_USE_METIS_5=YES \
-DMFEM_DEBUG=YES \
-DMFEM_USE_PUMI=YES \
-DMFEM_USE_PETSC=YES \
-DMFEM_USE_LAPACK=YES \
-DMFEM_ENABLE_EXAMPLES=YES \
-DMFEM_ENABLE_MINIAPPS=YES \
-DPETSC_DIR=/opt/scorec/spack/install/linux-rhel7-x86_64/gcc-7.3.0/petsc-3.11.0-264efxjpnpgl5ls3erg652m6jy4qn4a7 \
-DPETSC_ARCH="" \
-DPUMI_DIR=/opt/scorec/spack/install/linux-rhel7-x86_64/gcc-7.3.0/pumi-develop-us33llshzz5i6cgitw2ugcdq5d3r6gze \
-DMETIS_DIR=/opt/scorec/spack/install/linux-rhel7-x86_64/gcc-7.3.0/metis-5.1.0-rn7k363kqpvbznmxb3jkkejwjcgfqpyu \
-DCMAKE_INSTALL_PREFIX=/lore/kaurs3/ODL_common/mfem_build/install_mfem_pumi