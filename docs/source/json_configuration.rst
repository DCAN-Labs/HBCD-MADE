Processing Settings/Configuring the JSON File
#############################################

First off, an example json file used for processing data can be
found :download:`here <proc_settings.json>`. The settings
specified in the json file fall under two general categories.
The first category is for global settings. These settings will
all fall under the json key "global_settings" and serve as the
default settings across tasks. The second category is for unique
task settings. If you are processing three unique tasks, you will
then have three unique json key with the names for each task. 
It is important that the name of your files follow BIDS formatting
for the pipeline to be able to correctly identify the task name
for a given EEG file. For example, if you have a file named
sub-1_ses-1_task-MMN_run-2_acq-eeg_eeg.set, you should then
have a field in your json file named MMN to denote the processing
settings used for this task.

Parameters can be set in both "global_settings" and task-specific
keys, and when there are conflicting settings, HBCD-MADE will
continue processing with the task speficic settings. Because
some processing (i.e. ICA) will occur on a merged version of
all tasks, some settings such as high and low-pass filter cutoffs
should be the same across all tasks.

Parameters
----------
The total list of supported settings are as follows:

* boundary_marker: string
      If this marker is present in the
      EEG file, data from before this marker will be removed
      prior to analysis.
* channel_locations: string
      The path to the *.sfp file with electrode
      channel locations. The sample_locs folder
      from EEGLAB is place under /sample_locs in
      the container, so these files can be directly
      referenced from within the container
      (i.e. /sample_locs/GSN129.sfp). Alternatively,
      an external path can be provided to a custom
      file, but the path to this folder will then
      need to be binded to singularity.
* down_sample: binary (1 or 0)
      Whether or not to down sample the data.
* sampling_rate: float
      The new sampling rate you want following down sampling.
      This is only used if down_sample = 1.
* delete_outerlayer: binary (1 or 0)
      Whether the outer layer of channels should be deleted.
* delete_outerlayer_channel : list of strings
      Outerlayer of channels to be deleted if
      delete_outerlayer = 1.
* highpass: float
      The high pass filter cutoff frequency
* lowpass: float
      The low pass filter cutoff frequency
* remove_baseline: binary (1 or 0)
      Whether to remove baseline
* baseline_window: list
      baseline window
* voltthresh_rejection: binary (1 or 0)
      Whether to remove epochs based on voltage
      rejection
* volt_threshold: list of two floats
      The negative and positive values in uV
      to use for epoch thresholding
* interp_epoch: binary (1 or 0)
      Whether to interpolate over removed
      epochs
* interp_channels: binary (1 or 0)
      Whether to interpolate channels
* frontal_channels : list of strings
      Frontal channels.
* refef_data: binary (1 or 0)
      Whether to rereference the daa
* reref: list of strings
      Either [] for electrode average
      rereferencing, or provide the
      electrodes to use as reference
*  output_format: 1 or 2
      1 = .set, 2 = .mat
*  make_dummy_events: true or false
      Whether to insert dummy events into
      your scan. This option is used to
      create new events in the case of
      resting-state acquisitions where
      there are no triggers to denote
      epochs.
*  marker_names: list of strings
      The markers that you want to construct
      epochs around. If make_dummy_events = true,
      then this should instead represent the first
      marker in your EEG file. Dummy events will
      then be placed after the first instance of
      this marker.
*  pre_latency: float
      The amoubt of time (in seconds) to include
      in an epoch prior to the event specified by
      the entries in marker_names.
*  post_latency: float
      The amoubt of time (in seconds) to include
      in an epoch following the event specified by
      the entries in marker_names.
*  num_dummy_events: int
      The number of dummy events to make if
      make_dummy_events = true.
*  dummy_event_spacing: float
      The amount of time (in seconds) to have
      between dummy events. Note: epochs are
      constructed around events, so this isn't
      the same as spacing between epochs.
      
Example JSON
------------
Example :download:`json <proc_settings.json>`.

      
      
.. toctree::
   :maxdepth: 2
   :caption: Contents: