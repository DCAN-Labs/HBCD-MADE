#!/usr/bin/env python3
import argparse, glob, os

def build_parser():

    #Configure the commands that can be fed to the command line
    parser = argparse.ArgumentParser()
    parser.add_argument("bids_dir", help="The path to the BIDS directory for your study (this is the same for all subjects)", type=str)
    parser.add_argument("output_dir", help="The path to the folder where outputs will be stored (this is the same for all subjects)", type=str)
    parser.add_argument("analysis_level", help="Should always be participant", type=str)
    parser.add_argument("json_settings", help="The path to the subject-agnostic JSON file that will be used to configure processing settings", type=str)

    parser.add_argument('--participant_label', '--participant-label', help="The name/label of the subject to be processed (i.e. sub-01 or 01)", type=str)
    parser.add_argument('--session_id', '--session-id', help="The name of a specific session to be processed (i.e. ses-01)", type=str)
    parser.add_argument('-ext', '--file_extension', '--file-extension', help="File extension for EEG data (.set is the only supported option right now)", type=str, default='.set')
    parser.add_argument('-skip_interim', '--skip_saving_interim_results', '--skip-saving-interim-results', help="Flag: skip saving interim results to output folder", action="store_true")

    return parser

def main():

    #Initialize the parser and get arguments
    parser = build_parser()
    args = parser.parse_args()

    #Grab paths from environment
    compiled_executable_path = os.getenv("EXECUTABLE_PATH")
    mcr_path = os.getenv("MCR_PATH")

    #Get cwd in case relative paths are given
    cwd = os.getcwd()

    #reassign variables to command line input
    bids_dir = args.bids_dir
    if os.path.isabs(bids_dir) == False:
        bids_dir = os.path.join(cwd, bids_dir)
    output_dir = args.output_dir
    if os.path.isabs(output_dir) == False:
        output_dir = os.path.join(cwd, output_dir)
    analysis_level = args.analysis_level
    if analysis_level != 'participant':
        raise ValueError('Error: analysis level must be participant, but program received: ' + analysis_level)
    json_settings = args.json_settings
    if os.path.isabs(json_settings) == False:
        json_settings = os.path.join(cwd, json_settings)
        
    #Find participants to try running
    if args.participant_label:
        participant_split = args.participant_label.split(' ')
        participants = []
        for temp_participant in participant_split:
            if 'sub-' not in temp_participant:
                participants.append('sub-' + temp_participant)
            else:
                participants.append(temp_participant)
    else:
        os.chdir(bids_dir)
        participants = glob.glob('sub-*')

    #Set session label
    if args.session_id:
        session_label = args.session_id
        if 'ses-' not in session_label:
            session_label = 'ses-' + session_label
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
        
    #Iterate through participants and run MADE (this is less efficient than handling in MATLAB, but okay for now)
    for temp_participant in participants:

        if session_label == '_':
            temp_sessions = glob.glob(os.path.join(bids_dir, temp_participant, 'ses-*', 'eeg'))
        else:
            temp_sessions = [os.path.join(bids_dir, temp_participant, session_label, 'eeg')]
        if len(temp_sessions) == 0:
            temp_sessions = glob.glob(os.path.join(bids_dir, temp_participant, 'eeg'))
            if len(temp_sessions) > 0:
                pass
            else:
                print('Skipping processing for {} since no eeg directory for this subject was found under the BIDS directory {}'.format(temp_participant, bids_dir))
                continue

        for temp_session in temp_sessions:
            temp_session_split = temp_session.split('/')
            temp_session_label = temp_session_split[-2]
            num_eeg_affiliated_files = len(glob.glob(os.path.join(temp_session, '*eeg.*')))
            if num_eeg_affiliated_files == 0:
                print('Skipping processing for {} since eeg directory appears to be empty (did not contain any files with character sequence "eeg." in file name)'.format(temp_session))
                continue
            #temp_log_file_path = os.path.join(temp_session, 'MCR_Processing_Log.txt')
            output_status = os.system(compiled_executable_path + ' ' + mcr_path + ' ' + output_dir + ' ' + bids_dir + ' ' + temp_participant + ' ' + temp_session_label + ' ' + file_extension + ' ' + json_settings + ' ' + save_interim)
            output_status = os.WEXITSTATUS(output_status)
            if output_status > 0:
                raise ValueError('Error: Matlab command line returned non-zero exit status ({})'.format(output_status))
            
    return

if __name__ == "__main__":
    main()
