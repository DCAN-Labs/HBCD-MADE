
Input Data 
===========

HBCD-MADE takes raw, BIDS formatted HBCD data in .set file format. 

- :ref:`Required Processing Inputs <./required_inputs>`


.. _./required_inputs:

Required Processing Inputs
---------------------------

The following files are required inputs to the HBCD-MADE pipeline: 

(1)	Channel locations file: ``./0_2AverageNet128_v1.sfp``
(2)	Metadata in .set files: ``./sub-<label>_ses-<label>_task-<label>_acq-eeg_eeg.set``
(3)	EEG data matrix in .fdt: ``./sub-<label>_ses-<label>_task-<label>_acq-eeg_eeg.fdt``
(4)	Processing settings .json: ``proc_settings_HBCD.json``
