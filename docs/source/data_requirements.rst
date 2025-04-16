
Input Data 
===========

HBCD-MADE takes raw, BIDS formatted HBCD data in .set file format. 

- :ref:`Contents of Raw HBCD data folders <./data_contents>`

- :ref:`Required Processing Inputs <./required_inputs>`

.. _./data_contents:

Contents of Raw HBCD data folders
----------------------------------

.. note:: Not all contents of HBCD EEG folders are used for processing with HBCD-MADE. See :ref:`Required Processing Inputs <./required_inputs>` for a list of required inputs. 

Raw HBCD data folders are curated using the `EEG2BIDS Wizard <https://hbcd-docs.readthedocs.io/en/latest/datacuration/eeg/#eeg2bids-wizard-details>`_, a custom developed software for HBCD EEG data management and BIDS formatting. Each raw data folder contains the following: 

**File Types:** 

- ``TXT``- Contain E-PRIME event log output.
- ``TSV``- Store metadata and other relevant information.
- ``JSON``- Store metadata and configuration settings in a format that is easy for users to read and edit.
- ``SET``- Contain metadata and parameters for the EEG dataset, such as channel locations, sampling rate, and event information.
- ``FDT``- Field data table files contain EEG data.


Each HBCD subject/session pair has a corresponding BIDS dataset for that session, containing EEG data and other information in the following files and folders:

(1)	``./sub-*`` folder
(2)	``./dataset_description.json``
(3)	``./participants.json``
(4)	``./participants.tsv``
(5)	``./README``

1. ``./sub-* folder``

  Stores raw data and metadata. Contains a folder called ``ses-V03`` which houses an ``eeg`` folder and a ``.tsv`` labeled with the subject ID and recording session. This ``.tsv`` contains the file names and date and time of each EEG recording. The eeg folder contains several ``.json``, ``.fdt``, and ``.txt`` files in BIDS format providing information about the recording system, location of electrodes, events for each task, and raw data.

2. ``./dataset_description.json``

  Contains basic information about the dataset such as the subject ID number, version of BIDS used and type of data.

3. ``./participants.json``

  File with descriptions of all variables stored in participants.tsv.

4. ``./participants.tsv``

  Lists basic information about the participant such as the ID and study site where the data were collected.

5. ``./README``

  Provides references and information about BIDS formatting.


.. _./required_inputs:

Required Processing Inputs
---------------------------

The following files are required inputs to the HBCD-MADE pipeline: 

(1)	Channel locations file: ``./0_2AverageNet128_v1.sfp``
(2)	Metadata in .set files: ``./sub-<label>_ses-<label>_task-<label>_acq-eeg_eeg.set``
(3)	EEG data matrix in .fdt: ``./sub-<label>_ses-<label>_task-<label>_acq-eeg_eeg.fdt``
(4)	Processing settings .json: ``proc_settings_HBCD.json``
