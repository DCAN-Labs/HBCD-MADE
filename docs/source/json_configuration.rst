.. include:: links.rst

Processing Settings and Configuration
=====================================

Selections of HBCD-MADE processing parameters are made in .json keys rather than in the MATLAB preprocesing scripts. An example json file used for processing data can be
found :download:`here <proc_settings.json>`. The settings specified in the JSON file fall under two general categories:

1. :ref:`Global_settings` : These settings fall under the JSON key ``global_settings`` and serve as the default settings across tasks.
2. :ref:`Unique_task_settings` : If you are processing all four HBCD tasks, you will have four unique JSON keys titled accordingly. It is important that the name of your files follows BIDS formatting for the pipeline to correctly identify the task name for a given EEG file. For example, if you have a file named ``sub-1_ses-1_task-MMN_run-2_acq-eeg_eeg.set``, you should have a field in your JSON file named ``MMN`` to denote the processing settings used for this task.

Parameters can be set in both ``global_settings`` and task-specific keys. When there are conflicting settings, HBCD-MADE will continue processing with the task-specific settings. Because some processing (i.e., ICA) will occur on a merged version of all tasks, some settings such as high and low-pass filter cutoffs should be the same across all tasks.

.._Global_settings:

Global Setting Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These supported global settings are specified in the ``proc_settings_HBCD_container.json``:

- **boundary_marker**: (string) If this marker is present in the EEG file, data from before this marker will be removed prior to analysis.
- **ekg_channels**: (string) Non-cortical electrode measuring the electrocardiogram.
- **channel_locations**: (string) The path to the ``*.sfp`` file with electrode channel locations. The sample_locs folder from EEGLAB is placed under ``/sample_locs`` in the container so these files can be directly referenced from within the container (i.e., ``/sample_locs/GSN129.sfp``). Alternatively, an external path can be provided to a custom file, but the path to this folder will then need to be bound to Singularity.
- **down_sample**: (binary 1 or 0) Whether or not to downsample the data.
- **sampling_rate**: (float) The new sampling rate you want following downsampling. This is only used if ``down_sample`` = 1.
- **delete_outerlayer**: (binary 1 or 0) Whether the outer layer of channels should be deleted.
- **delete_outerlayer_channel**: (list of strings) Outer layer of channels to be deleted if ``delete_outerlayer`` = 1.
- **highpass**: (float) The high-pass filter cutoff frequency.
- **lowpass**: (float) The low-pass filter cutoff frequency.
- **remove_baseline**: (binary 1 or 0) Whether to remove the baseline.
- **baseline_window**: (list) Baseline time window.
- **voltthresh_rejection**: (binary 1 or 0) Whether to remove epochs based on voltage rejection.
- **volt_threshold**: (list of two floats) The negative and positive values in uV to use for epoch thresholding.
- **interp_epoch**: (binary 1 or 0) Whether to interpolate over removed epochs.
- **interp_channels**: (binary 1 or 0) Whether to interpolate channels.
- **frontal_channels**: (list of strings) Frontal channels.
- **reref_data**: (binary 1 or 0) Whether to re-reference the data.
- **reref**: (list of strings) Either ``[]`` for electrode average re-referencing or provide the electrodes to use as reference.
- **output_format**: (binary 1 or 2) 1 = ``.set``; 2 = ``.mat``
- **make_dummy_events**: (true or false) Whether to insert dummy events into your scan. This option is used to create new events in the case of resting-state acquisitions where there are no triggers to denote epochs.
- **num_dummy_events**: (int) The number of dummy events to make if ``make_dummy_events`` = true.
- **dummy_event_spacing**: (float) The amount of time (in seconds) to have between dummy events. Note that epochs are constructed around events, so this isn’t the same as spacing between epochs.
- **marker_names**: (list of strings) Name of event code markers you want to construct epochs around (e.g., ``DIN3``). If ``make_dummy_events`` = true, then this should instead represent the first marker in your EEG file. Dummy events will then be placed after the first instance of this marker.
- **pre_latency**: (float) The amount of time (in seconds) to include in an epoch prior to the event specified by the entries in ``marker_names``.
- **post_latency**: (float) The amount of time (in seconds) to include in an epoch following the event specified by the entries in ``marker_names``.

.._Unique_task_settings:

Task Specific Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Task-specific parameters are defined in the task's corresponding .json key ending in ``MADE_specification.json``. The following parameters are task-specific and not listed in the ``proc_settings_HBCD_container.json`` which defines global parameters and some task specific parameters:

- **ROI_of_interest**: Selects the ROI for ERPs.
- **ERP_window_start**: Time window of interest in the topographic plots and in the averages for the ``.mat`` files.
- **ERP_window_end**: Time window of interest in the topographic plots and in the averages for the ``.mat`` files.
- **erp_filter**: Boolean variable indicating whether to apply a second low-pass filter before creating ERPs.
- **erp_lowpass**: Hz at which to apply the second low-pass filter.
- **score_times**: Time ranges in seconds used for SME and mean amplitude computation. There have to be the same number of score_times and score_ROIs.
- **score_ROIs**: ROIs to be used for computing SME and mean amplitude. There have to be the same number of score_times and score_ROIs.

      
.. toctree::
   :maxdepth: 2
   :caption: Contents:
