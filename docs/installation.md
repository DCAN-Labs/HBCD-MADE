# HBCD-MADE Container Installation & Usage

## HBCD-MADE Container Usage

We recommend using containerized HBCD-MADE when processing large amounts of data.
The container for HBCD-MADE can be found on [Docker Hub](https://hub.docker.com/r/dcanumn/hbcd-made/tags).
A tutorial on how to use containers is located [here](https://docker-curriculum.com/). It can be downloaded with Singularity as follows (click
[here](https://docs.sylabs.io/guides/latest/user-guide/) for
a Singularity user guide):

   `singularity pull hbcd_made_latest.sif docker://dcanumn/hbcd-made:1.0.9`


The design of HBCD-MADE is meant to follow general 
[BIDS-App guidelines](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005209).
For more details on general usage principles of BIDS-Apps, see the linked documentation.

The example below shows the general layout for how you may want to interact with the container
to conduct processing if you have the container downloaded as a singularity image:


        container_path=/path/to/container.sif
        bids_dir=/path/to/bids
        output_dir=/path/to/output
        bibsnet_dir=/path/to/bibsnet
        settings_file=/path/to/settings.json
        singularity run -B $bids_dir:/bids \
         -B $output_dir:/output \
         -B $settings_file:/settings_file/file.json \
         $container_path /bids /output participant /settings_file/file.json

The intended workflow of running HBCD-MADE involves utilizing a containerized version of the pipeline in Singularity. If the container is being used to run the pipeline, the inputs will be formatted as follows:

  * A json file with the configurations for processing the data for the current run.
  * The output directory to store the results (this will be the same for all subjects in a study).
  * The BIDS directory with the input data.
  * The participant label whose EEG data you want to process.
  * The session label to process for the given participant. 
  
## Running HBCD-MADE

**An example command to run HBCD-MADE:**

This example will run processing for sub-1's ses-1,
using the configuration file `proc_settings_HBCD.json.`
Note that the path to the electrode
positioning files is determined in the json and not as an
input parameter to Singularity, but we still need to bind
the folder where the electrode positioning files are stored
so that Singularity can access it.


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
     sub-123456 \
    ses-V03
   
## Command-Line Arguments

    usage: hbcd-made [-h] [--participant_label PARTICIPANT_LABEL]
                    [--session_id SESSION_ID] [-ext FILE_EXTENSION]
                    [-skip_interim]
                    bids_dir output_dir analysis_level json_settings

.. argparse::
   :ref: python_code.run.build_parser
   :prog: hbcd-made
   :nodefaultconst:

.. toctree::
   :maxdepth: 2
   :caption: Contents:

### Positional Arguments

`bids_dir`

The path to the BIDS directory for your study (this is the same for all subjects)

`output_dir`

The path to the folder where outputs will be stored (this is the same for all subjects)

`analysis_level`

Should always be participant

`json_settings`

The path to the subject-agnostic JSON file that will be used to configure processing settings

### Named Arguments

`--participant_label`, `--participant-label`

The name/label of the subject to be processed (i.e. sub-01 or 01)

`--session_id`, `--session-id`

The name of a specific session to be processed (i.e. ses-01)

`-ext`, `--file_extension`, `--file-extension`

File extension for EEG data (.set is the only supported option right now)

Default: '.set'

`-skip_interim`, `--skip_saving_interim_results`, `--skip-saving-interim-results`

Flag: skip saving interim results to output folder

## Computational Requirements

The computational requirements for running HBCD-MADE depend on the amount of input data
(length of acquisition, number of channels, number of files, etc.), along with the
processing settings (downsampling, filtering, etc.).

For an HBCD-style acquisition with 1kHz sampling rate and 128 electrodes,
processing generally takes between one and three hours per session. HBCD-MADE
processing is generally initiated with 2 CPUs, 40GB of RAM, and 7
hours of compute time.