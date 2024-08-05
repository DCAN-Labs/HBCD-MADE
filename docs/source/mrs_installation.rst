.. OSPREY_BIDS documentation master file, created by
   sphinx-quickstart on Wed Jun  5 10:48:12 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Installation
============

The intended use of this pipeline is through the use of a Singularity/Docker
image. The image can be built using the Dockerfile found in the repository,
or it can be pulled from DockerHub as a singularity using the following command: ::
    
        singularity pull docker://dcanumn/osprey:<version_num>

Where version_num denotes the specific version of the container. All available
versions of the container can be found `here <https://hub.docker.com/r/dcanumn/osprey/tags>`_.

After downloading the container, singularity is the only other dependency needed
for processing. The full usage details can be seen under the usage section, but
the basic command to run the container is as follows: ::
    
        container_path=/path/to/container.sif
        bids_dir=/path/to/bids
        output_dir=/path/to/output
        bibsnet_dir=/path/to/bibsnet
        settings_file=/path/to/settings.json
        singularity run -B $bids_dir:/bids \
         -B $output_dir:/output \
         -B $bibsnet_dir:/bibsnet \
         -B $settings_file:/settings_file/file.json \
         $container_path /bids /output participant /settings_file/file.json

Where "singularity run" is followed by specific commands for singularity.
In this case it is a series of "bind" commands that will give singularity
access to the necessary directories for processing. This is followed by the path to the
container. Last, the user specifies the arguments that are unique to the current application,
such as input and output files, configuration files, and other processing settings.

Note: If you are not interested in interacting with this particular interface
of OSPREY, which includes BIDS and containerized functionality, consider using
OSPREY directly in Matlab following the instructions found `on the OSPREY github <https://github.com/schorschinho/osprey>`_.