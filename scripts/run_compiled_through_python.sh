#!/bin/bash

export MCR_PATH=/home/midb-ig/shared/repositories/leex6144/v910/
export EXECUTABLE_PATH=/panfs/roc/groups/8/faird/shared/data/TOTS_UMD_collab/code/cdl-eeg-processing/MADE-EEG-preprocessing-pipeline/MADE_edits_v111_ekg/run_MADE/for_testing/run_compiled.sh

/home/midb-ig/shared/repositories/leex6144/HBCD-MADE/run.py /home/midb-ig/shared/data_sources/leex6144/UMD0012_546802_V03_bids/ /home/midb-ig/shared/data_sources/leex6144/UMD0012_OUTPUT_7_28_22/ participant /home/midb-ig/shared/repositories/leex6144/HBCD-MADE/testing_settings.json
