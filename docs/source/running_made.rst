
Running HBCD-MADE
#################

The intended workflow of running HBCD-MADE involves utilizing a containerized version of the pipeline in Singularity. If the container is being used to run the pipeline, the inputs will be formatted as follows:

  * A json file with the configurations for processing the data for the current run.
  * The output directory to store the results (this will be the same for all subjects in a study).
  * The BIDS directory with the input data.
  * The participant label whose EEG data you want to process.
  * The session label to process for the given participant. (**V03** is the only session label available as of September 2024). 
  

An example command to run HBCD-MADE
-----------------------------------

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
   
  
.. toctree::
   :maxdepth: 2
   :caption: Contents:

