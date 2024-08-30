HBCD-MADE Container
====================

Installation
--------------------------
We recommend using the HBCD-MADE container when processing large amounts of data. The container for HBCD-MADE can be found on Docker Hub.  A tutorial on how to use containers is located `here <https://docker-curriculum.com/>`_. It can be downloaded with Singularity as follows (click `here <https://docs.sylabs.io/guides/latest/user-guide/>`_. for a Singularity user guide):

.. code-block:: console

   singularity pull hbcd_made_latest.sif docker://dcanumn/hbcd-made:1.0.9

Usage
--------------------------

The design of the application is meant to follow general 
`BIDS-App guidelines <https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005209>`_.
For more details on general usage principles of BIDS-Apps, see the linked documentation.

As described in the installation section, this tool is meant to be
interacted with in containerized form. The example below shows the
general layout for how you may want to interact with the container
to conduct processing if you have the container downloaded as a
singularity image: ::


        container_path=/path/to/container.sif
        bids_dir=/path/to/bids
        output_dir=/path/to/output
        bibsnet_dir=/path/to/bibsnet
        settings_file=/path/to/settings.json
        singularity run -B $bids_dir:/bids \
         -B $output_dir:/output \
         -B $settings_file:/settings_file/file.json \
         $container_path /bids /output participant /settings_file/file.json

To see more specific information about how this tool expects
the inputs to be formatted (i.e. file naming conventions), 
see the data requirements page.


The intended workflow of running HBCD-MADE involves utilizing a containerized version of the pipeline in Singularity. If the container is being used to run the pipeline, the inputs will be formatted as follows:

  * A json file with the configurations for processing the data for the current run.
  * The output directory to store the results (this will be the same for all subjects in a study).
  * The BIDS directory with the input data.
  * The participant label whose EEG data you want to process.
  * The session label to process for the given participant. (**V03** is the only session label available as of September 2024). 
  
Running HBCD-MADE
------------------

**An example command to run HBCD-MADE:**

This example will run processing for the test file available `here <https://osf.io/wg46a/>`_,
using the configuration file ``proc_settings_HBCD.json.``
Note that the path to the electrode
positioning files is determined in the json and not as an
input parameter to Singularity, but we still need to bind
the folder where the electrode positioning files are stored
so that Singularity can access it.

.. code-block:: console

   json_dir=/path/to/json_folder
   output_dir=/path/to/store/output
   bids_dir=/path/to/bids_data
   
   singularity run -B $json_dir:/json_dir \
   -B $output_dir:/output_dir \
   -B $bids_dir:/bids_dir \
   made_pipeline.sif \
   /json_folder/proc_settings_HBCD.json \
   /output_dir \
   /bids_dir \
   sub-144696 \
   ses-V03
   
