# Creating Airfoil Mesh using Solidworks and SimModeler
This page contains instructions for creating a CAD file of an airfoil suitable for meshing with SimModeler.


##CAD File and Mesh Creation

1. Get coordinates of airfoil profile.  The last point should be the same as the first to ensure the profile forms a closed curve

2.  Import the curve into Solidworks
```
    - Insert - Curve - Curve Though XYZ Points
```

3. Create a bounding box around the airfoil profile
```
    - Create a new sketch in the same plane as the curve
    - Select the curve in the graphics area and click Convert Entities (on the Sketch toolbar)
    - Create a centerline from the forwardmost point on the leading edge of the airfoil to the point on the trailing edge
    - Create a rectangle centered at the midpoint of the centerline that encompasses the airfoil
    - Exit the sketch
```

4. Create a Surface from the sketch
  
Thus far we have created 1 dimensional entities (edges), but SimModeler requires 2D model face to create a 2D mesh.  To turn the sketch into a surface
```
    - Insert - Surface - Planar
    - The area between the airfoil and the rectangle should be automatically selected.  If not, make sure that area (and not the area inside the airfoil) is selected.  
      The selected area is what will be meshed by SimModeler
    - Click the green check mark to accept
```

5. Strip Extranious Features from the model

If we import the model as it currently exists into SimModeler, it will see the airfoil curve and the surface containing the airfoil cutout as different parts, which will cause problems when we convert the mesh to the Pumi format.  It is recommended to save the model at this time.  To eliminate extranious features:
```
    - File - Save As - Save as type - Parasolid Binary *.x_b
    - Close the solidworks part currently open
    - Open the Parasolid Binary file (decline any Feature Recognition or Import Diagnositcs)
    - Left click on the ImportedCurve in the feature Manger Design Tree and click Suppress
    - File - Save As - Save as type - Parasolid *.x_t
```
	
6.  Use SimModeler to Create Mesh
```
    - Set up your environment to use SimModeler (see instructions below)
    - Open SimModeler
    - File - Import Geometry - select the Parasolid x_t file
    - Use SimModeler to specify all parameters for the Surface Mesh
    - Meshing - Generate Mesh - unselect Volume Meshing - Start
    - Click Show Mesh when completed
    - File - Save Mesh
```

7.  Convert to Pumi format

In a shell with envionrment set up to use SimModeler:
```
    - convert meshname.smd meshname.sms meshname.smb
```
If you want to use geometry information in Pumi:
```
    - mdlConvert meshname.smd meshname.dmg
```
If you want to partition the mesh for parallel computation
```
    - split meshname.dmg meshname.smb meshname_parallel.smb num_partitions
```

# Configuring your Environment to use SimModeler

On the Debian 6 machines, source this shell script:
```
#!/bin/bash

source /usr/local/etc/bash_profile
module load mpich3/3.1.2-thread-multiple
module load parmetis/mpich3.1.2/4.0.3
module load zoltan/mpich3.1.2/3.81
module load simmetrix/simModSuite
module load simmetrix/simModeler/4.0-140403

module load simmetrix/simModeler
module load pumi
```

Or on the RHEL7 machines:
```
#!/bin/bash

module load simmetrix/simModeler
module load gcc/7.3.0-bt47fwr
module load mpich/3.2.1-niuhmad 
module load pumi/develop-int64-shared-sim-haofhpo
```

## Some Notes on SimModeler
This is not a complete introduction to SimModeler.  A few pieces of information that are useful for meshing and airfoil are:

* SimModeler should connect edges into Loops, making it easy to apply mesh parameters to the airfoil and the bounding box

* The Gradation parameter is useful for controlling how quickly the mesh coarsens at a distance from some place where the mesh size is specified.  It can only be applied to Parts in the Model List window. 
	
* Be careful with the mesh size.  It is easy to specify a very small mesh size that will take the computer a long time to generate.  Looking at the memory usage of SimModler compared to the total amount of memory the computer has is a good way to check if you have specified too fine a mesh for the computer to generate.

