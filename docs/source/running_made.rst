Running HBCD-MADE
#################

HBCD-MADE is an adapted version of the Maryland Analysis of Developmental EEG (MADE) pipeline (Debnath et al., 2020) for use with data from the Healthy Brain and Child Development (HBCD) study. The intended workflow of running HBCD-MADE involves
utilizing a containerized version of the pipeline
in singularity. If the container is being used
to run the pipeline, the inputs will be formatted
as follows:

  * A json file with the configurations for processing the data for the current run.
  * The output directory to store the results (this will be the same for all subjects in a study).
  * The BIDS directory with the input data.
  * The participant label whose EEG data you want to process.
  * The session label to process for the given participant (this is optional if the subject only has one session).
  

An example command to run HBCD-MADE
-----------------------------------

This example will run processing for sub-1's ses-1,
using the configuration file proc_settings_HBCD.json.
One thing to be aware of is that the path to the electrode
positioning files is determined in the json and not as an
input parameter to singularity, but we still need to bind
the folder where the electrode positioning files are stored
so that singularity can access it.


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
   sub-1 \
   ses-1
   
  
  
An example json file used for processing data can be
found :download:`here <proc_settings.json>`.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

