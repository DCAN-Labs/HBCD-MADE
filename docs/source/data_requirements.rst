
Input Data 
===========

HBCD-MADE takes raw, BIDS formatted HBCD data in .set file format. Please visit the `HBCD Data Release Docs <https://docs.hbcdstudy.org>`_ for information once the data is released:

`HBCD EEG Overview <https://docs.hbcdstudy.org/measures/eeg/#electroencephalography-eeg>`_
`HBCD EEG Task Details <https://docs.hbcdstudy.org/measures/eeg/#electroencephalography-eeg/#eeg-task-details>`_
`HBCD EEG Raw BIDS Data <https://docs.hbcdstudy.org/datacuration/rawbids/#eeg>`_

Required Processing Inputs
---------------------------

The following files are required inputs to the HBCD-MADE pipeline: 

(1)	Channel locations file: ``./0_2AverageNet128_v1.sfp``
(2)	Metadata in .set files: ``./sub-<label>_ses-<label>_task-<label>_acq-eeg_eeg.set``
(3)	EEG data matrix in .fdt: ``./sub-<label>_ses-<label>_task-<label>_acq-eeg_eeg.fdt``
(4)	Processing settings .json: ``proc_settings_HBCD.json``
