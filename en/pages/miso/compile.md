# Compiling MISO

To build `MISO`, the MISO directory should be in the same directory as the other MISO build dependencies which includes `mfem`, `Adept`, and `core`. This can be confirmed by using the command

```ls /path/to/packages/``` 
The above command should output mfem, Adept, and core, among others that may be present. /path/to/packages is the root directory containing these packages

**Note:** the following modules must be built before building MISO: `Adept`, `mfem`, and `core`.

## Clone MISO repository from GitHub
Navigate to the packages directory then clone MISO from GitHub using these commands
```
cd /path/to/packages/
git clone https://github.com/OptimalDesignLab/MISO.git
```
Depending on the MISO branch you will be working with, checkout the appropriate commit hash. See example below
```
cd MISO
git checkout cd7e53714ae3d3c6d4256d66a2ee67562224f47e

```


*This page is being worked on...*