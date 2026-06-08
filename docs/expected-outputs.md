# Expected Outputs from HBCD-MADE

The output structure of HBCD-MADE will mimic the input BIDS structure. If you have some EEG file that is found under `/bids_dir/sub-<label>/ses-<label>/eeg/`, then the output of HBCD-MADE will fall under `output_dir/sub-<label>/ses-<label>/eeg/`.

The output of HBCD-MADE will primarily be found in `.set` [EEGLAB](https://eeglab.org/) formatted data structures and `.csv` files. Different stages of data processing will be saved, but the final data elements to be used for subsequent analyses will be found in the ./processed_data folder. If you load an EEG file from this folder, its `data` field will have dimensions `<num_electrodes, num_samples, num_epochs>`, with the epochs placed around the events specified in the `proc_settings.json` file. The `.set/.fdt` files saved by HBCD-MADE can be loaded back into Matlab with EEGLAB’s `pop_loadset` function, or loaded in python using MNE.

The following output folders and files are created throughout processing within each subject’s output directory:

```
 |__ made/
        |__ sub-{ID}/
            |__ ses-{V0X}/
                |__ eeg/
                    |__ filtered_data/
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|RS|VEP>_acq-eeg_run-{X}_desc-filtered_eeg.fdt
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|RS|VEP>_acq-eeg_run-{X}_desc-filtered_eeg.set
                    |
                    |__ ica_data/
                    |   |__ sub-{ID}_ses-{V0X}_adjustReport.txt
                    |   |__ sub-{ID}_ses-{V0X}_desc-mergedICA_eeg.fdt
                    |   |__ sub-{ID}_ses-{V0X}_desc-mergedICA_eeg.set
                    | 
                    |__ merged_data/
                    |   |__ sub-{ID}_ses-{V0X}_desc-merged_eeg.fdt
                    |   |__ sub-{ID}_ses-{V0X}_desc-merged_eeg.json
                    |   |__ sub-{ID}_ses-{V0X}_desc-merged_eeg.set
                    | 
                    |__ processed_data/
                    |   |__ sub-{ID}_ses-{V0X}_task-FACE_desc-<F-TOPO>_topo.jpg
                    |   |__ sub-{ID}_ses-{V0X}_task-FACE_desc-oz_<diffERP|ERP>.jpg
                    |   |__ sub-{ID}_ses-{V0X}_task-MMN_desc-oz_<MMN-TOPO>_topo.jpg
                    |   |__ sub-{ID}_ses-{V0X}_task-MMN_desc-t7t8_<diffERP|ERP>.jpg
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN>_desc-{IMG}.jpg
                    |   |__ sub-{ID}_ses-{V0X}_task-RS_desc-allCh_PSD.jpg
                    |   |__ sub-{ID}_ses-{V0X}_task-RS_LogPowerSpectra.csv
                    |   |__ sub-{ID}_ses-{V0X}_task-RS_dbPowerSpectra.csv
                    |   |__ sub-{ID}_ses-{V0X}_task-RS_AbsPowerSpectra.csv
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|VEP>_ERPSummaryStats.csv
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|VEP>_ERPTrialMeasures.csv
                    |   |__ sub-{ID}_ses-{V0X}_task-VEP_<desc-oz_ERP|topo>.jpg
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|VEP>_acq-eeg_run-{X}_ERP.mat
                    |   |__ sub-{ID}_ses-{V0X}_task-RS_spectra.mat
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|RS|VEP>_acq-eeg_run-{X}_desc-filteredprocessed_eeg.fdt
                    |   |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|RS|VEP>_acq-eeg_run-{X}_desc-filteredprocessed_eeg.set
                    | 
                    |__ sub-{ID}_ses-{V0X}_acq-eeg_preprocessingReport.csv
                    |__ sub-{ID}_ses-{V0X}_task-<FACE|MMN|RS|VEP>_acq-eeg_run-{X}_MADEspecification.json

# Label Values Legend
<F-TOPO>: diffInvVsUpr, diffObjVsUp2, inverted, object, upright, upright2
<MMN-TOPO>: deviant, diffDevVsSta, diffDevVsPre, preDeviant, standard 
```

## HBCD-MADE output file types:

**JPEG**- topographic and ERP plots.

**MAT** - MATLAB data files contain processing output.

**CSV**- stores data in tabular format.

**JSON**- stores metadata and saves task-specific configuration settings in a format that is easy for users to read and edit.

**SET**- contains metadata and parameters for the EEG dataset, such as channel locations, sampling rate, and event information.

**FDT**- field data table (FDT) files contain EEG data resaved across different stages of processing.

## HBCD-MADE output: 

### ./filtered_data folder

This folder contains all data saved early in the processing pipeline after filtering but prior to bad channel detection. Each EEG task administered will have a corresponding .set and .fdt file stored within this folder. These data have undergone the following operations:

* deletion of discontinuous data

* deletion of EKG channel(s) if present

* downsampling

* deletion of outer electrode ring

* filtering with 0.3 Hz high-pass with stopband of 0.1

* 60 Hz low-pass with 10 Hz transition band using a noncausal FIR filter


### ./merged_data folder

Immediately after filtering, tasks are merged together into one file and re-saved into this folder. Tasks present in the merged .fdt file are listed in the corresponding .json file.


### ./ica_data folder

After data are merged into one file, they undergo the following operations and are re-saved into `ica_data/` with ICA weights:

* apply FASTER algorithm for bad channel detection

* ICA preparation (dataset copied and 1Hz high-pass applied to the copy, broken into 1-s epochs for epoch-level rejection, bad channels rejected)

* ICA

* run adjustedADJUST to identify artifact-containing independent components- see [Leach et al., 2020](https://onlinelibrary.wiley.com/doi/10.1111/psyp.13566) for details. Output from adjustedADJUST is written to `SUBSES_adjust_report.csv` and contains IC labels assigned by the algorithm.  


### ./processed_data folder

The `processed_data` folder contains all MADE ERP and resting state power derivatives.  See [Derivatives and ERP Specifications](https://docs-hbcd-made.readthedocs.io/en/latest/derivatives_ERPspecs) for descriptions of MADE derivatives. 

### Preprocessing report and specification files

#### MADE preprocessing report 

The MADE preprocessing report is automatically generated for each session and contains a summary of data processing. Some entries will be the same for all tasks in a given subject because the EEG is merged across tasks for portions of preprocessing. See [Debnath et al., 2020](https://pubmed.ncbi.nlm.nih.gov/32293719/) for more information on MADE preprocessing. The following columns are present-


| Column Name | Description                              |
|---------------|------------------------------------------|
| datafile_name | file name of EEG data |
| subject_id | unique subject identifier |
| task | FACE, MMN, RS, VEP |
| line_noise | estimate of how much electrical line noise is present in the EEG signal. Values of 1 indicate no line noise, values of 0 indicate pure line noise. |
| reference_for_faster | reference electrode used by the FASTER algorithm used for bad channel detection (Nolan et al., 2010). |
| faster_bad_channels | list of channels identified by FASTER algorithm as being artifactual, or not representative of brain activity. |
| ica_prep_bad_channels | channels deleted by FASTER before ICA. |
| length_ica_data | how much continuous data (in seconds) was used for independent component analysis. |
| total_ICs | number of independent components identified. |
| ICs_removed | independent components removed by adjusted-ADJUST (Leach et al, 2020). |
| total_epochs_pre_artifact_rej | number of epochs collected. |
| total_epochs_post_artifact_rej | number of epochs retained after epoch-level artifact rejection. |
| total_channels_interp | number of channels interpolated using spline interpolation after bad channel removal. |
| avg_chan_interp_artifact_rej | average number of channels interpolated per epoch using spline interpolation for each task. |
| std_chan_interp_artifact_rej | standard deviation of the number of channels removed per epoch for each task. |
| range_chan_interp_artifact_rej | range of number of channels interpolated per epoch. |

The following variables within the MADE preprocessing report represent the number of trials retained after artifact rejection from each condition of each task.

| Variable Name | Task | Description                     | 
|---------------|------|---------------------------------|
|FACE_UpInv |FACE | face stimuli in block 1 (upright faces vs inverted faces) |
| FACE_Inv | FACE | inverted face stimuli in block 1 (upright faces vs inverted faces) |
| FACE_Obj |FACE | object stimuli in block 2 (upright faces vs objects) |
| FACE_UpObj | FACE | FACE task, upright face stimuli in block 2 (upright faces vs objects) |
| MMN_Standard | MMN | mismatch negativity, standard stimulus |
| MMN_PreDev | MMN | mismatch negativity, standard stimulus preceding deviant stimulus |
| MMN_Dev | MMN | mismatch negativity, deviant stimulus |

#### MADE specification file

For each session processed, HBCD-MADE writes an output file which containing a record of the processing parameters that were specified. See the [Processing Settings and Configuration](https://docs-hbcd-made.readthedocs.io/en/latest/proc_settings) for a description of the contents of the MADE specification file. 