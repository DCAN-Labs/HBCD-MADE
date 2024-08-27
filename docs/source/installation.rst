Installation
=============

HBCD-MADE Container
--------------

We recommend using the HBCD-MADE container when processing large amounts of data. The container for HBCD-MADE can be found on Docker Hub. It can be downloaded with Singularity as follows:

.. code-block:: console

   singularity pull hbcd_made_latest.sif docker://dcanumn/hbcd-made:1.0.9

HBCD-MADE Github
-------

If you wish to run HBCD-MADE locally for processing a small number of EEG files, HBCD-MADE and associated scripts are also available `here <https://github.com/ChildDevLab/MADE-EEG-preprocessing-pipeline>`_. Visit `here <LINK>`_. for a tutorial on locally running a test file. 

** Dependencies **
Users must have MATLAB installed to run the HBCD-MADE pipeline locally. HBCD-MADE is known to work well with MATLAB version 2024a. The Signal Processing Toolbox and Statistics/ Machine Learning Toolboxes must also be installed into MATLAB. Users may elect to install the Parallel Processing Toolbox for faster processing. EEGLAB must also be installed, and installation instructions can be found `here <https://sccn.ucsd.edu/eeglab/downloadtoolbox.php/>_. We recommend using EEGLAB version 2023.0. 

License
MADE is freely available under the terms of the GNU General Public License (version 3). 

Installation
After downloading HBCD-MADE, add it to the MATLAB path. See our tutorial for more information on how to get started once the pipeline is downloaded
Dependencies 
