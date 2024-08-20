.. toctree::
   :maxdepth: 2
   :caption: Table of Contents
   
   computational_requirements
   installation
   usage
   running_made
   data_requirements
   json_configuration
   expected_outputs
   resources
   

Input Data Requirements
========================

Contents of Raw HBCD data folders
----------------------------------

Each HBCD subject/session pair has a corresponding BIDS dataset for that session, containing EEG data and other information. 

(1)	``./sub-*`` folder
(2)	``./dataset_description.json``
(3)	``./participants.json``
(4)	``./participants.tsv``
(5)	``./README``

``./sub-* folder``

Description
  Raw data and metadata.

Contents
  Contains a folder called ses-V03 which houses an eeg folder and a .tsv labeled with the subject ID and recording session. This .tsv contains the file names and date and time of each EEG recording. The eeg folder contains several .json, .fdt, .txt and .edat3 files in BIDS format providing information about the recording system, location of electrodes, events for each task, and raw data.

``./dataset_description.json``

  Contains basic information about the dataset such as the subject ID number, version of BIDS used and type of data.

``./participants.json``

  File with descriptions of all variables stored in participants.tsv.

``./participants.tsv``

  Lists basic information about the participant such as the ID and study site where the data were collected.

``./README``

  Provides references and information about BIDS format.


For use with non-HBCD data
---------------------------

The HBCD-MADE pipeline may be useful for your purposes if you:

(1) Have BIDS formatted EEG data where the EEG data is in .set/.fdt file format
(2) Have a number of tasks that are collected in a given session and want to run ICA denoising across all tasks simultaneously
(3) Want your processed EEG data to be epoched
(4) Are fine with data processing only using metadata from .set/.fdt files, while ignoring the rest of the files in your BIDS directory

