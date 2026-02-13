# Derivatives and ERP specifications

Click [here](https://github.com/Child-Development-Lab/HBCD-EEG-Utilities/blob/main/docs/csv_data_dictionary_derivatives.csv) for a data dictionary defining the fields in each .csv output file.  

## Derivatives by task

Click [here](https://docs.hbcdstudy.org/latest/instruments/eeg/tasks/) to view descriptions of each HBCD EEG task.

`HBCD-MADE.m` computes the following derivatives for each task: 

| Task | Derivatives     |
|------|----------------|
| FACE | SME, Mean amplitude            |
| MMN  | SME, Mean amplitude           |
| VEP  | SME, Mean amplitude, Adaptive mean, Peak latency            |
| RS   | Absolute power (μV²), Power (dB), Natural log power |

- **Mean amplitude**: Mean amplitude (μV) during specified measurement window.

- **Adaptive mean**: Adaptive mean amplitude is calculated by finding the peak during the specified time window and averaging the amplitude across all sampling points within 1 standard deviation of the peak.

- **Peak latency**: Latency (ms) to the peak amplitude during the specified time window.

- **SME**: Standardized Measurement Error (SME) is a universal measure of data quality for ERP data. See [Luck et al., 2021](https://onlinelibrary.wiley.com/doi/full/10.1111/psyp.13793) for more information.

- **Power**: Absolute power (μV²), power (dB), and natural log power for each frequency bin ranging from 1-50Hz.

#### Regions of Interest (ROIs)

See below for the ROIs that are used to compute ERPs. The full list of ROIs can also be found on the [GitHub repository for HBCD-MADE](https://github.com/DCAN-Labs/HBCD-MADE/blob/main/proc_settings_HBCD.json).

 ![ROI clusters](ROIs.png)
 
!!! note
    Please note that most ERPs are scored using age-dependent time windows. See "Processing Settings and Configuration" for details.  

### Task-based ERP Derivatives
ERPs are computed separately for each task condition in the FACE and MMN task. See tables below for details. 

#### FACE Task 
ERP derivatives for the FACE task contain the following components at the specified time windows and ROIs:

| Task | Component | Time window | ROI  | Age |
|------|-----------|-------------|------|-----|
| FACE | P1        | 75-125 ms     | Oz   | 3-9 |
| FACE | N290      | 200-390 ms    | P8   | 3-6 |
| FACE | N290      | 200-340 ms    | P8   | 6-9 |    
| FACE | N290      | 200-390 ms    | P7   | 3-6 |
| FACE | N290      | 200-340 ms    | P7   | 6-9 | 
| FACE | N290      | 200-390 ms    | Oz   | 3-6 |
| FACE | N290      | 200-340 ms    | Oz   | 6-9 |
| FACE | P400      | 400-600 ms    | Oz   | 3-6 |                              
| FACE | P400      | 350-600 ms    | Oz   | 6-9 |
| FACE | Nc        | 300-650 ms    | FCz  | 3-9 |

**1- FACE Trial Measures Output**: `SUBSES_task-FACE-ERPTrialMeasures.csv`

Trial-level derivatives for the FACE task include mean amplitude.

| Variable Name | Description                              |
|---------------|------------------------------------------|
| Condition | inverted, object, uprightInv, uprightObj |
| TrialNum | trial index |
| MeanAmplitude_<WindowStart-WindowEnd>_ROI | Mean amplitude within specified time window at specified ROI |

**2- FACE Summary Statistics Output**: `SUBSES_task-FACE-ERPSummaryStatistics.csv`

Subject-level derivatives for the FACE task include mean amplitude and SME.

| Variable Name | Description                              |
|---------------|------------------------------------------|
| Condition | inverted, object, uprightInv, uprightObj |
| NTrials | number of trials retained per condition |
| MeanAmplitude_WindowStart-WindowEnd_ROI | Mean amplitude within specified time window at specified ROI |
| SME_WindowStart-WindowEnd_ROI | Standard measurement error during specified time window at specified ROI |

#### Mismatch Negativity/Auditory Oddball (MMN) task

ERP derivatives for the MMN task contain the following components at the specified time windows and ROIs:

| Task | Conditions | Time window | ROI  | Age |
|------|-----------|-------------|------|-----|
| MMN  | PreDeviant, Deviant, Standard       | 200-400 ms    | t7t8 | 3-9 |
| MMN  | PreDeviant, Deviant, Standard       | 200-400 ms    | f7f8 | 3-9 |
| MMN  | PreDeviant, Deviant, Standard       | 200-400 ms    | FCz  | 3-9 |

!!! note
    Users are advised to score the amplitude of the Mismatch Response (MMR) component by subtracting the amplitude of PreDeviant trials from Deviant trials.

**1- MMN Trial Measures Output**: `SUBSES_task-MMN-ERPTrialMeasures.csv`

Trial-level derivatives for the MMN task include mean amplitude.

| Variable Name | Description                              |
|---------------|------------------------------------------|
| Condition | deviant, predeviant, standard |
| TrialNum | trial index |
| MeanAmplitude_WindowStart-WindowEnd_ROI | Mean amplitude within specified time window at specified ROI |

**2- MMN Summary Statistics Output**: `SUBSES_task-MMN-ERPSummaryStatistics.csv`

Subject-level derivatives for the MMN task include mean amplitude and SME.

| Variable Name | Description                              |
|---------------|------------------------------------------|
| Condition | deviant, predeviant, standard |
| NTrials | number of trials retained per condition |
| MeanAmplitude_WindowStart-WindowEnd_ROI | Mean amplitude within specified time window at specified ROI |
| SME_WindowStart-WindowEnd_ROI | Standard measurement error during specified time window at specified ROI |


#### Visual Evoked Potential (VEP) Task

ERP derivatives for the VEP task contain the following components at the specified time windows and ROIs:

| Task | Component | Time window | ROI  | Age |
|------|-----------|-------------|------|-----|
| VEP  | N1        | 40-79 ms      | Oz   | 3-6 |
| VEP  | N1        | 40-79 ms      | Oz   | 6-9 |
| VEP  | P1        | 80-140 ms     | Oz   | 3-6 | 
| VEP  | P1        | 80-120 ms     | Oz   | 6-9 |
| VEP  | N2        | 141-300 ms    | Oz   | 3-6 |
| VEP  | N2        | 121-170 ms    | Oz   | 6-9 |


**1- VEP Trial Measures Output**: `SUBSES_task-VEP-ERPTrialMeasures.csv`

Trial-level derivatives for the VEP task include mean amplitude, adaptive mean (peak), and latency.

| Variable Name | Description                              |
|---------------|------------------------------------------|
| Condition | VEP |
| TrialNum | trial index |
| MeanAmplitude_WindowStart-WindowEnd_ROI | Mean amplitude within specified time window at specified ROI |
| Peak_WindowStart-WindowEnd_ROI | Adaptive mean amplitude within specified time window at specified ROI |
| Latency_WindowStart-WindowEnd_ROI | Latency to peak within specified time window at specified ROI |

**2- VEP Summary Statistics Output**: `SUBSES_task-VEP-ERPSummaryStatistics.csv`

Subject-level derivatives for the VEP task include SME, mean amplitude, adaptive mean (peak), and latency.

| Variable Name | Description                              |
|---------------|------------------------------------------|
| Condition | VEP |
| NTrials | number of trials retained per condition |
| SME_WindowStart-WindowEnd_ROI | Standard measurement error during specified time window at specified ROI |
| MeanAmplitude_WindowStart-WindowEnd_ROI | Mean amplitude within specified time window at specified ROI |
| Peak_WindowStart-WindowEnd_ROI | Adaptive mean amplitude within specified time window at specified ROI |
| Latency_WindowStart-WindowEnd_ROI | Latency to peak within specified time window at specified ROI |

### Resting State (RS) Power Derivatives

Power values are calculated as follows:

```{r}

Absolute Power (μV²) = (μV²  / Hz)

Log Power  = log10 (1 + (μV²  / Hz))

Power (dB) = 10 × log10 (μV² / Hz)

```

- When interpreting the 50.0 Hz bin in RS output, please be aware that the data are low-pass filtered at 50Hz. 

**1- RS Absolute Power (μV²) Spectra Output**: `SUBSES_task-RS-AbsPowerSpectra.csv`

Subject-level absolute power values for RS.  
   
| Variable Name | Description                              |
|---------------|------------------------------------------|
| Row | Electrode | 
| 1.0 Hz | Sum of absolute power in μV² centered at 1 Hz (within the 0.5hz to 1.5hz freq range) at corresponding electrode site |
| 2.0 Hz | Sum of absolute power in μV² centered at 2 Hz (within the 1.5hz to 2.5hz freq range) at corresponding electrode site |
| 3.0 Hz | Sum of absolute power in μV² centered at 3 Hz (within the 2.5hz to 3.5hz freq range) at corresponding electrode site |
| 50.0 Hz | Sum of absolute power in μV² centered at 50 Hz (within the 49.5hz to 50.5hz freq range) at corresponding electrode site |

**2- RS Power (dB) Spectra Output**: `SUBSES_task-RS-dbPowerSpectra.csv`

Subject-level dB power values for RS.  
   
| Variable Name | Description                              |
|---------------|------------------------------------------|
| Row | Electrode |
| 1.0 Hz | Sum of power in dB centered at 1 Hz (within the 0.5hz to 1.5hz freq range) at corresponding electrode site |
| 2.0 Hz | Sum of power in dB centered at 2 Hz (within the 1.5hz to 2.5hz freq range) at corresponding electrode site |
| 3.0 Hz | Sum of power in dB centered at 3 Hz (within the 2.5hz to 3.5hz freq range) at corresponding electrode site |
| 50.0 Hz | Sum of absolute power in μV² centered at 50 Hz (within the 49.5hz to 50.5hz freq range) at corresponding electrode site |

**3- RS Log Power Spectra Output**: `SUBSES_task-RS-LogPowerSpectra.csv`

Subject-level log power values for RS.  
   
| Variable Name | Description                              |
|---------------|------------------------------------------|
| Electrode | Electrode label |
| 1.0 Hz | Sum of natural log power centered at 1 Hz (within the 0.5hz to 1.5hz freq range) at corresponding electrode site |
| 2.0 Hz | Sum of natural log power centered at 2 Hz (within the 1.5hz to 2.5hz freq range) at corresponding electrode site |
| 3.0 Hz | Sum of natural log power centered at 3 Hz (within the 2.5hz to 3.5hz freq range) at corresponding electrode site |
| 50.0 Hz | Sum of absolute power in μV² centered at 50 Hz (within the 49.5hz to 50.5hz freq range) at corresponding electrode site |

**4- RS Power Spectra .mat Output**: `SUBSES_task-RS_spectra.mat`

Epoch-level derivatives for RS.
   
| Variable Name | Description                              |
|---------------|------------------------------------------|
| avg_abs_pow | Average absolute power (μV²) across epochs |
| avg_log_pow | Average natural log power across epochs |
| avg_db_pow | Average power (dB) across epochs |
| all_abs_power | Channels x abs power x epochs |
| all_log_power | Channels x log power x epochs |
| all_db_pow | Channels x dB power x epochs |
| epoch_level_abs_pow | Absolute power (μV²) for each epoch |
| epoch_level_log_pow | Log power for each epoch |
| epoch_level_db_pow | Power (dB)  for each epoch |
| channel locations | ... |
| freqs | Frequency bins (1hz increments, 1-50hz) |
| n_epochs | Number of epochs |
| Fs | Sampling rate |
| num_channels | Number of channels |

**5- RS Power Spectra Figure** : `SUBSES_task-RS-desc-allCh_PSD.jpg`

Subject-level plot visualizing power spectral density for each channel across the 1-50Hz frequency range. Data for this plot originates from `SUBSES_task-RS-dbPowerSpectra.csv`. See below for an example:
 ![PSD plot](PSDplot.png)

 
 