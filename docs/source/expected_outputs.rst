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

.. toctree::
   :maxdepth: 2
   :caption: Contents:
      
      