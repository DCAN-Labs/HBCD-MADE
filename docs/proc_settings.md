# Processing Settings and Configuration 

Selections of HBCD-MADE processing parameters are made in JSON keys rather than in the MATLAB preprocessing scripts. An example .json that has been used for processing data can be found [here](https://github.com/DCAN-Labs/HBCD-MADE/blob/main/proc_settings_HBCD.json). 

The settings specified in the JSON fall under two general categories:

**Global parameters** : These settings fall under the JSON key global_parameters and serve as the default settings across tasks.

**Unique task settings** : Task-specific parameters are specified below global_parameters. It is important that the name of your files follows BIDS formatting for the pipeline to correctly identify the task name for a given EEG file. For example, if you have a file named sub-{X}_ses-{X}_task-MMN_run-1_acq-eeg_eeg.set, you should have a field in your JSON file named MMN to denote the processing settings used for this task.

Parameters can be set in both global and task-specific keys. When there are conflicting settings, HBCD-MADE will continue processing with the task-specific settings. Because some processing (i.e., ICA) will occur on a merged version of all tasks, some settings should be the same across all tasks (e.g., high and low-pass filter cutoffs).

For a list of processing specifications for HBCD EEG data, see HBCD Processing Settings

## Global Parameters

These supported global settings are specified in the proc_settings_HBCD_container.json:

- boundary_marker: (string) If this marker is present in the EEG file, data from before this marker will be removed prior to analysis.

- ekg_channels: (string) Non-cortical electrode measuring the electrocardiogram.

- channel_locations: (string) The path to the .sfp file with electrode channel locations. The sample_locs folder from EEGLAB is placed under /sample_locs in the container, so these files can be directly referenced from within the container (i.e., /sample_locs/GSN129.sfp). Alternatively, an external path can be provided to a custom file, but the path to this folder will then need to be bound to Singularity.

- down_sample: (binary 1 or 0) Whether or not to downsample the data.

- sampling_rate: (float) The new sampling rate you want following downsampling. This is only used if down_sample = 1.

- delete_outerlayer: (binary 1 or 0) Whether the outer layer of channels should be deleted.

- outerlayer_channel: (list of strings) Outer layer of channels to be deleted if delete_outerlayer = 1.

- highpass: (float) The high-pass filter cutoff frequency.

- lowpass: (float) The low-pass filter cutoff frequency.

- remove_baseline: (binary 1 or 0) Whether to remove the baseline.

- baseline_window: (list) Baseline time window.

- voltthresh_rejection: (binary 1 or 0) Whether to remove epochs based on voltage rejection.

- volt_threshold: (list of two floats) The negative and positive values in uV to use for epoch thresholding.

- interp_epoch: (binary 1 or 0) Whether to interpolate over removed epochs.

- frontal_channels: (list of strings) Frontal channels.

- interp_channels: (binary 1 or 0) Whether to interpolate channels.

- rerefer_data: (binary 1 or 0) Whether to re-reference the data.

- reref: (list of strings) Either [] for the default re-referencing (average re-referencing) or provide the electrodes to use as reference.

- output_format: (binary 1 or 2) 1 = .set; 2 = .mat

## Unique Task Settings

- ROI_of_interest: Selects the regions of interest for scoring of ERPs.

- make_dummy_events: (true or false) Whether to insert dummy events into your scan. This option is used to create new events in the case of resting-state acquisitions where there are no triggers to denote epochs.

- num_dummy_events: (int) The number of dummy events to make if make_dummy_events = true.

- dummy_event_spacing: (float) The amount of time (in seconds) to have between dummy events. Note that epochs are constructed around events, so this isn’t the same as spacing between epochs.

- pre_latency: (float) The amount of time (in seconds) to include in an epoch prior to the event specified by the entries in marker_names.

- post_latency: (float) The amount of time (in seconds) to include in an epoch following the event specified by the entries in marker_names.

- ERP_window_start: Time window of interest in the topographic plots and the averages for the .mat files.

- ERP_window_end: Time window of interest in the topographic plots and the averages for the .mat files.

- erp_filter: Boolean variable indicating whether to apply a second low-pass filter before creating ERPs.

- erp_lowpass: Hz at which to apply the second low-pass filter.

- marker_names: (list of strings) Name of event code markers you want to construct epochs around (e.g., DIN3). If make_dummy_events = true, then this should instead represent the first marker in your EEG file. Dummy events will then be placed after the first instance of this marker.

- ERP_dirs: Direction of ERP components listed in "ERP_names". [-1] indicates a negaive-going component, and [1] indicates positive. These values are used to specify whether MADE should search for a positive or negative peak when computing peak latency and adaptive-mean amplitude for a given ERP. 

- score_ages: List of age bins used to compute ERPS with age-dependent time windows. 

- score_times{X}: Time ranges (in seconds) to use for plotting and scoring SME, ERP, and peak measures.

- score_ROIs: Regions of interest to use for plotting and scoring SME, ERP, and peak measures.

- ERP_names: Names of the scored ERP components


!!! note
    DIN markers are inserted by a StimTracker and denote specific types of stimuli. DIN2 markers represent auditory stimuli from computer speakers, and DIN3 markers represent visual stimuli captured by a photocell on the participant monitor. DIN2 flags will always be present in MMN, and will appear in the FACE and VEP task only in cases when the researcher prompted “attention getter” stimuli which involve an auditory signal to bring the participant’s attention back to the computer screen. See [HBCD EEG Task Information](https://docs.hbcdstudy.org/latest/instruments/eeg/tasks/#hbcd-eeg-tasks) for more information.


### Age-Dependent ERP time windows
Age-dependent time windows are defined in the [processing settings .json file](https://github.com/DCAN-Labs/HBCD-MADE/blob/main/proc_settings_HBCD.json). For each task, the first age bin specified (e.g. 3-6 months) corresponds to the list of time windows in `score_times1`. The number of time windows listed matches the number of `score_ROIs` and the list of `ERP_names`. 

Here's an example of how to interpret the code specifying the age-dependent ERP time windows:

 The code below states that for the VEP task in ses-V03, ERPs are scored as follows for participants who were 3-6 months old at EEG acquisition: 

- The N1 component is scored at the Oz cluster between 40 ms - 79 ms

- The P1 component is scored at the Oz cluster between 80 ms - 140 ms

- The N2 component is scored at the Oz cluster between 141 ms - 300 ms. 

`score_times2` defines the time windows for participants who were 6-9 months old at EEG acquisition. Unlike the ERP time windows, the ROI clusters used to score any given ERP are stable across age groups.  

```
"VEP": {
    "ses-V03": { 
        "ERP_dirs": [-1, 1, -1], #Direction of the N1, P1, and N2 components
        "score_ages": [[3,6],[6,9]], #age bins are 3-6 months and 6-9 months
        "score_times1":[[40, 79], [80,140], [141, 300]], # ERP time windows for 3-6 month olds for the N1, P1, and N2 components
        "score_times2":[[40, 79], [80,120], [121, 170]], # ERP time windows for 6-9 month olds for the N1, P1, and N2 components
        "score_ROIs": ["oz", "oz", "oz"], # Electrode cluser at ERP regions of interest for the N1 P1, and N2 components
        "ERP_names": ["N1", "P1", "N2"] # list of ERP components scored
    }
}
```

