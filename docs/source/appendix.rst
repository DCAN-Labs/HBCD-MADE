

.. include:: links.rst

.. _citation:

=============================================
Appendix
=============================================

Supplementary Material 
-----------------------

HBCD-MADE Local Processing Tutorial
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: These steps will configure the user to run local processing. However, due to the computational demands of EEG pre-processing, it is recommended to use the HBCD-MADE container for HPC instead of locally processing data files. 

1. Download example data.
	Click `here <https://osf.io/wg46a/files/osfstorage>`_ to download the raw and fully processed EEG file for one session. 

2. Install HBCD-MADE
	Visit our `GitHub <https://github.com/ChildDevLab/HBCD-MADE>`_ to download the HBCD-MADE Pipeline.

3. Install dependencies
	HBCD-MADE is known to work well with MATLAB version 2024a. The Signal Processing Toolbox and Statistics/Machine Learning Toolboxes must also be installed into MATLAB. Users may elect to install the Parallel Processing Toolbox for faster processing. EEGLAB must also be installed and installation instructions can be found `here <https://sccn.ucsd.edu/eeglab/downloadtoolbox.php>`_. We recommend using version eeglab2023.0.
 
4. **Initialize ‘test_HBCD_MADE.m’**

- Change file paths to where HBCD-MADE is stored on your computer.
- Set ``output_dir_name`` to your preferred output directory (we usually place the output directly into the subject’s data folder).
- Set ``bids_dir`` to the location of the data folder downloaded from OSF.
- Set ``participant_label`` to the subject’s ID: (e.g. sub-123456).
- Set ``session_label`` to the visit number for that file: (e.g. ses-V03).
- Set ``json_settings_file`` to the filepath where ``proc_settings_HBCD.json`` is stored on your computer. This will be the same directory as the entire HBCD-MADE folder.
- Open ``proc_settings_HBCD.json`` and set the ``channel_locations`` path to where HBCD-MADE is stored on your computer.

5. Run ``test_HBCD_MADE.m``
	Once complete, output will be available in the user-selected output directory. See :doc:`Expected Outputs </expected_outputs>` for descriptions of all HBCD-MADE output. 

