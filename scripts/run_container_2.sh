#!/bin/bash -l
#SBATCH --time=4:00:00
#SBATCH --ntasks=1
#SBATCH --mem=4g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=leex6144@umn.edu



output_dir_name=/home/midb-ig/shared/data_sources/leex6144/UMD0012_546802_V03_MADE_CONTAINER_OUTPUT_7_29_22/
bids_dir=/home/midb-ig/shared/data_sources/leex6144/UMD0012_546802_V03_bids/
participant_label=sub-UMD0012
container_path=/home/midb-ig/shared/containers/leex6144/hbcd_made_112_1.sif
json_folder=/home/midb-ig/shared/repositories/leex6144/HBCD-MADE/
save_interim_result=1
channel_locs_dir=/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/eeglab2021.0/sample_locs/

export TIME="time result\ncmd:%C\nreal %es\nuser %Us \nsys  %Ss \nmemory:%MKB \ncpu %P"
module load singularity
/usr/bin/time singularity run -B $output_dir_name:/output_dir \
-B $bids_dir:/bids_dir \
-B $json_folder:/json_folder \
$container_path  \
/bids_dir \
/output_dir \
participant \
/json_folder/proc_settings_HBCD_container.json 

