Expected Outputs
================

The output structure of HBCD-MADE will mimic the input BIDS structure. If you have some EEG file that is found under ``/bids_dir/sub-1/ses-1/eeg/``, then the output of HBCD-MADE will fall under ``output_dir/sub-1/ses-1/eeg/``. The following output folders and files are created throughout processing within each subject’s output directory:

- ``./filtered_data``
- ``./merged_data``
- ``./ica_data``
- ``./processed_data``
- ``./sub-*_ses-*_acq-eeg_MADE_preprocessing_report.csv``

``/filtered_data`` folder
-------------------------

**Description**

This folder contains all data saved early in the processing pipeline after filtering but prior to bad channel detection. These data have been subjected to the following operations:

- deletion of discontinuous data
- deletion of EKG channel(s) if present
- downsampling
- deletion of outer electrode ring
- filtering with 0.3 Hz high-pass with stopband of 0.1
- 60Hz low-pass with 10 Hz transition band using a noncausal FIR filter

**Contents**

Each EEG task administered will have a corresponding ``.set`` and ``.fdt`` file stored within this folder.

``/merged_data`` folder
-----------------------

**Description**

Immediately after filtering tasks are merged together into one file and re-saved into this folder.

**Contents**

Tasks present in the merged ``.fdt`` file are listed in the corresponding ``.json`` file.


``/ica_data`` folder
-------------------------

**Description**

These files are saved later in processing. After data are merged into one file, they undergo the following operations and are re-saved to the ``./ica_data`` folder:

- Run through FASTER algorithm for bad channel detection
- ICA preparation: 
* Dataset copied and 1Hz high-pass applied to the copy
* Broken into 1-s epochs for epoch-level rejection
* Bad channels rejected
- ICA
- Run through adjustedADJUST to identify artifacted ICs- see Leach et al (2021) for details (wip add citation) 


**Contents**

The ./ica_data folder contains the following:
- ``./sub-*_ses-*_adjust_report``: describes how each independent component was labeled by the adjusted-ADJUST algorithm.
- ``./sub-*_ses-*_ica_data.fdt``: EEG data with ICA weights
- ``./sub-*_ses-*_ica_data.set``: corresponding .set file to the .fdt


``/processed_data`` folder 
-------------------------

**Description** 

Each file found under this folder will have a corresponding json file in the parent directory that specifies the settings that were used for the specific task.  These data are saved at the end of the processing pipeline after the following operations have occurred:

- ICA artifact removal

- Merged tasks separated and epoched

- Baseline correction

- Artifact rejection

- Interpolation of removed channels

- Rereferencing


**Contents**

This folder contains all processed data and MADE output, described in detail below:

a. EEG Data (``.fdt``, ``.set``)

There is one .fdt and one corresponding .set file for each task containing fully processed data.

b. Figures (``.jpeg``)

  Several images containing plots and figures automatically produced by MADE:

- Each plot’s title will contain N values for the number of trials retained for each condition of each task.

	* MMN task plots are titled as follows: N = # standard trials, # predeviant trials, # deviant trials

	* FACE task plots are titled as follows: N = # uprightINV trials, # inverted trials, # object trials, # uprightOBJ trials

- PSD plots represent the power spectral density at either all electrodes or specific regions of interest (ROIs). The number of trials represented are specified in the plot’s title.

- ERP plots show the event-related potential wave across N trials at a specified ROI.

- Topo plots contain topographic maps of mean voltage across the scalp during a specified time window.

- DiffTopo plots represent the difference in mean voltage between two conditions during a specified time window.

- DiffERP plots display the difference in the ERP waveform between specified conditions.


c. MATLAB Data files (``.mat``) 
.mat files contain processing output.

- Output for the VEP, FACE, and MMN tasks contain the ``allData`` matrix, which is structured as Conditions x Electrodes x Timepoints.

- Output for the RS data contains the ``spectra_eo_db`` matrix, which is structured as Electrodes x Frequency. RS .mat output does not contain the time dimension.

d. CSV data files (``.csv``)

For each task, two .csv files are automatically produced by MADE: a summary statistics file and a trial measures file.

- Summary Statistics

	* For the MMN, VEP, and FACE tasks, the summaryStats file contains the standardized measurement error (SME) for a specified time range (e.g. 200-400ms after stimulus presentation) at an ROI (e.g. fcz). The SME is a universal measure of data quality for ERP data. See Luck et al. (2021) for more information.

	* For the RS (resting state), the summaryStats file contains the SME and mean power at each frequency bin ranging from 1-50Hz.

- Trial Measures 

	* For the MMN, VEP, and FACE tasks, the trialMeasures files contain trial-by-trial mean amplitudes across time ranges for different ROIs.

	* The RS does not have a trialMeasures file because this task does not contain trials.





.. toctree::
   :maxdepth: 2
   :caption: Contents:
      
      