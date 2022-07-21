#!/usr/bin/env python3

import argparse
import os
parser = argparse.ArgumentParser()
parser.add_argument("json_settings", help="The path to JSON file that will be used to configure processing settings", type=str)
parser.add_argument("output_dir", help="The path to the folder where outputs will be stored (this is the same for all subjects)", type=str)
parser.add_argument("bids_dir", help="The path to the BIDS directory for your study (this is the same for all subjects)", type=str)
parser.add_argument('participant_label', help="The name of the subject to be processed (i.e. sub-01)", type=str)
parser.add_argument('-ss', '--session_label', help="OPTIONAL: the name of a specific session to be processed (i.e. ses-01)", type=str)
parser.add_argument('-ext', '--file_extension', help="OPTIONAL: file extension for EEG data (only supported option is .set right now)", type=str, default='.set')
parser.add_argument('-skip_interim', '--skip_saving_interim_results', help="Flag: skip saving interim results to output folder", action="store_true")
args = parser.parse_args()

#Set session label
if args.session_label:
    session_label = args.session_label
else:
    session_label = '_' #underscore instead of string to be able to make things easier for calling function
    
#Set file extension
if args.file_extension:
    file_extension = args.file_extension
else:
    file_extension = '.set'
    
#Set save interim results
if args.skip_saving_interim_results:
    save_interim = '0'
else:
    save_interim = '1'
    
compiled_executable_path = os.getenv("EXECUTABLE_PATH")
mcr_path = os.getenv("MCR_PATH")

os.system(compiled_executable_path + ' ' + mcr_path + ' ' + args.output_dir + ' ' + args.bids_dir + ' ' + args.participant_label + ' ' + session_label + ' ' + file_extension + ' ' + args.json_settings + ' ' + save_interim)

