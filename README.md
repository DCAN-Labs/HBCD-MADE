# HBCD-MADE
HBCD branch of the MADE pipeline for EEG preprocessing

## HBCD-specific Parameters

### ROI_of_Interest:
Selects the ROI for the ERP. The channels in the coded name are in “clusters” (e.g. “oz”, “p8”, “user_defined”). The researcher can feel free to add more ROIs in the “clusters” section and then indicate them in the FACE.ROI_of_Interest section (or MMN, RS, VEP, depending on the task of interest). 
### pre_latency:
  Time of start of the epoch. Please consider that the value will turn negative in the script. (E.g. 0.1 will be -100 ms). This is also the time where the range for the ERP will start.
### post_latency:
  Time of the end of the epoch. It is seconds and will be transform in milliseconds (E.g. 0.5 will be 500 ms). This is also the time where the range for the ERP will end.
### ERP_window_start:
  This will be used for the time window of interest in the topoplots and in the averages for the .mat files (and potentially future metrics).
### ERP_window_end:
  This will be used for the time window of interest in the topoplots and in the averages for the .mat files (and potentially future metrics).
### erp_filter:
  This gives the option on applying a second lowpass filter before creating the ERPs. (1 for using the filter, 0 for not)
### erp_lowpass:
  In case we apply a second filter right before epoching, this will determine the lowpass filter used (e.g. 30).
### marker_names:
  The “event” code name where the data is epoched around (e.g. “DIN3”)


