.. HBCD_EEG_MADE documentation master file, created by
   sphinx-quickstart on Mon May 16 10:41:56 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

HBCD-MADE Introduction
======================

This page serves as documentation for the HBCD-MADE pipeline, an adapted version of the Maryland Analysis of Developmental EEG (MADE) pipeline (Debnath et al., 2020) for use with data from the Healthy Brain and Child Development (HBCD) study. The github repository for the MADE pipeline upon which HBCD-MADE is based, can be found `here <https://github.com/ChildDevLab/MADE-EEG-preprocessing-pipeline>`_, and a publication describing the original pipeline can be found `here <https://onlinelibrary.wiley.com/doi/full/10.1111/psyp.13580>`_.

The HBCD-MADE pipeline will run preprocessing on BIDS formatted data in the .set file format. All metadata required for running the HBCD-MADE pipeline is present within the .set files themselves, and other BIDS metadata will not be referenced during processing. In general, HBCD-MADE's functionality is roughly as follows:

#. **Identify all session level EEG data for a given
   recording session.**
#. **Iterate through all EEG files for the identified session,
   downsample the data, delete the outer layer of channels,
   and filter each file with the desired high-pass/low-pass settings.**
#. **Merge all task files together.**
#. **Check whether any electrodes are outliers at the session level. For each electrode the following measures will be calculated to judge outlier status, and any electrodes that have deviations greater than 3 stds on any given measure will be excluded from further analysis:**
   
   * The average temporal correlation to other electrodes
   * The Hurst exponent (measuring the self-similarity within each electrode's
     time signal
   * The signal variance
   
#. **Run through ICA on the electrodes:** 

   * Create temporaty copy of EEG signal
     high passed at 1Hz for ICA
   * Create 1s epochs and remove those with
     outlier characteristics
   * Generate ICs on good electrodes and
     good epochs
   * Classify the ICs into categories (such
     as blink) based on temporal characteristics)
   * Subract the bad ICs from the original data
#. **Seperate the merged data back into individual tasks**
#. **Epoch task based data based on event markers and resting-state data based on MADE generated dummy markers.**
#. **Remove epochs that have high voltage fluctations.**
#. **Interpolate over bad channels within epoch.**
#. **Interpolate deleted channels across epochs.**
#. **Re-reference the data.**
#. **Save the final output consisting of cleaned and epoched EEG data.**


.. toctree::
   :maxdepth: 2
   :caption: Contents:
   
Contents
--------

.. toctree::

   computational_requirements
   container_info
   data_requirements
   json_configuration
   tutorial
   expected_outputs
   task_info
   resources


