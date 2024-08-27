
Input Data 
===========

Contents of Raw HBCD data folders
----------------------------------

**File Types:** 

- ``EDAT3``- Contain task-specific event information from E-PRIME (stimulus presentation software).
- ``TSV``- Plain text files store metadata and other relevant information.
- ``JSON``- Store metadata and configuration settings in a format that is easy for users to read and edit.
- ``SET``- Cotain metadata and parameters for the EEG dataset, such as channel locations, sampling rate, and event information.
- ``FDT``- Field data table files contain EEG data.


Each HBCD subject/session pair has a corresponding BIDS dataset for that session, containing EEG data and other information in the following files and folders:

(1)	``./sub-*`` folder
(2)	``./dataset_description.json``
(3)	``./participants.json``
(4)	``./participants.tsv``
(5)	``./README``

1. ``./sub-* folder``

  Stores raw data and metadata. Contains a folder called ``ses-V03`` which houses an ``eeg`` folder and a ``.tsv`` labeled with the subject ID and recording session. This ``.tsv`` contains the file names and date and time of each EEG recording. The eeg folder contains several ``.json``, ``.fdt``, ``.txt`` and ``.edat3`` files in BIDS format providing information about the recording system, location of electrodes, events for each task, and raw data.

2. ``./dataset_description.json``

  Contains basic information about the dataset such as the subject ID number, version of BIDS used and type of data.

3. ``./participants.json``

  File with descriptions of all variables stored in participants.tsv.

4. ``./participants.tsv``

  Lists basic information about the participant such as the ID and study site where the data were collected.

5. ``./README``

  Provides references and information about BIDS formatting.


For use with non-HBCD data
---------------------------

The HBCD-MADE pipeline may be useful for your purposes if you:

(1) Have BIDS formatted EEG data where the EEG data is in .set/.fdt file format
(2) Have a number of tasks that are collected in a given session and want to run ICA denoising across all tasks simultaneously
(3) Want your processed EEG data to be epoched
(4) Are fine with data processing only using metadata from .set/.fdt files, while ignoring the rest of the files in your BIDS directory

