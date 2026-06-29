#Usage & Tutorial

# Resources & Local Processing Tutorial

## Input Data

HBCD-MADE takes raw, BIDS formatted HBCD data in .set file format. 
Please visit the [HBCD Data Release Docs](https://docs.hbcdstudy.org/latest/) for more information.

## Required Porcessing Inputs

The following files are required inputs to the HBCD-MADE pipeline:

Channel locations file: `./0_2AverageNet128_v1.sfp`

Metadata in .set files: `./SUBSES_task-<label>_acq-eeg_eeg.set`

EEG data matrix in .fdt: `./SUBSES_task-<label>_acq-eeg_eeg.fdt`

Processing settings .json: `proc_settings_HBCD.json`


## HBCD-MADE Local Processing Tutorial

!!! note
    These steps will configure the user to run local processing. However, due to the computational demands of EEG pre-processing, it is recommended to use the HBCD-MADE container for HPC instead of locally processing data files.

1. Download example data.

	> Click [here](https://osf.io/wg46a/files/osfstorage) to download the raw and fully processed EEG file for one session. 

2. Install HBCD-MADE

	> Visit our [GitHub](https://github.com/ChildDevLab/HBCD-MADE) to download the HBCD-MADE Pipeline.

3. Install dependencies

	> HBCD-MADE is known to work well with MATLAB version 2024a. The Signal Processing Toolbox and Statistics/Machine Learning Toolboxes must also be installed into MATLAB. Users may elect to install the Parallel Processing Toolbox for faster processing. EEGLAB must also be installed and installation instructions can be found [here](https://sccn.ucsd.edu/eeglab/downloadtoolbox.php). We recommend using version eeglab2023.0.
 
4. Initialize ‘test_HBCD_MADE.m’

- Change file paths to the location of HBCD-MADE on your computer.

- Set ``output_dir_name`` to your preferred output directory.

- Set ``bids_dir`` to the location of the data folder downloaded from OSF.

- Set ``participant_label`` to the subject’s ID: (e.g. sub-123456).

- Set ``session_label`` to the visit number for that file: (e.g. ses-V03).

- Set ``json_settings_file`` to the file path of ``proc_settings_HBCD.json``. This will be the same directory as the HBCD-MADE folder.

- Open ``proc_settings_HBCD.json`` and set the ``channel_locations`` path to the location of HBCD-MADE.


5. Run ``test_HBCD_MADE.m``
	Once complete, output will be available in the user-selected output directory. See :doc:`Expected Outputs </expected_outputs>` for descriptions of all HBCD-MADE output. 
