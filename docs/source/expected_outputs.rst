Expected Outputs
----------------

The output structure of HBCD-MADE will mimic the input BIDS structure. If you have some EEG file that is found under "/bids_dir/sub-1/ses-1/eeg/", then the output of HBCD-MADE will fall under "output_dir/sub-1/ses-1/eeg/". 

The output of HBCD-MADE will primarily be found in *.set `EEGLAB <https://eeglab.org/>`_ formatted data structures. Different stages of data processing will be saved, but the final data elements to be used for subsequent analyses will be found under the 'processed_data' folder. Each file found under this folder will have a corresponding json file in the parent directory that specifies the settings that were used for the specific task. If you load an EEG file, from the processed_data folder, it's 'data' field will have dimensions <num_electrodes, num_samples, num_epochs>, with the epochs placed around the events specified in the json file.

The .set/.fdt files saved by HBCD-MADE can be loaded back into Matlab with EEGLAB's pop_loadset function, or loaded in python using `MNE <https://mne.tools/stable/install/manual_install.html>`_

The file MADE_preprocessing_report.csv will contain summary level statistics related to the processing of your data. Because the EEG data is merged across tasks for portions of the pre-processing, some of these entries will be the same for all tasks.

.. toctree::
   :maxdepth: 2
   :caption: Contents:
      