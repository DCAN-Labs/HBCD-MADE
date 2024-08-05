Input Data Requirements
-----------------------

The HBCD-MADE pipeline may be useful for your purposes if you:

(1) Have BIDS formatted EEG data where the EEG data is in .set/.fdt file format
(2) Have a number of tasks that are collected in a given session and want to run ICA denoising across all tasks simultaneously
(3) Want your processed EEG data to be epoched
(4) Are fine with data processing only using metadata from .set/.fdt files, while ignoring the rest of the files in your BIDS directory