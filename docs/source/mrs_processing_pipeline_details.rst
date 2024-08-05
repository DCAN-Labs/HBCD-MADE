.. OSPREY_BIDS documentation master file, created by
   sphinx-quickstart on Wed Jun  5 10:48:12 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Processing Pipeline Details
===========================

As discussed in the expected inputs section, there a number of files that must
be present, following specific formatting requirements, for processing to occur.

At a high level there must be (a) a high resolution anatomical image, (b) MRS images,
and (c) a JSON file that describes how OSPREY should interact with the MRS images 
for processing purposes. 

Beyond that, it is optional that the user also has (d) a FreeSurfer-like segmentation
that is registered to (a), and (e) a localizer image that is (intrinsically) registered to (b).

In this section, we describe how OSPREY utilizes (a-e) to do processing. This section
is not meant to describe how input files should be formatted, but rather how they are
used by the OSPREY_BIDS pipeline. Prior to reading this, read the expected_inputs section
which has contains a subset of information not covered here.

1. OSPREY starts by finding the first group of files (whether a subject or session), that
   will be used for processing. Within OSPREY, a subject is first identified within the BIDS dataset.
   If this subject has sessions, then the session will be the fundamental unit of files to use for
   processing. Alterntively, the subject will be the fundamental unit of files for processing.
2. Search for the T1w and or T2w image to utilize as the high resolution anatomical for
   the session. Whether a T1w or T2w image is used is based on availability within the
   BIDS dataset, and based on the --preferred_anat_modality. There must be no more than 1
   image with the preferred anat modality. If there is a localizer image that also has
   this modality, then the --terms_not_allowed_in_anat flag should be used to avoid
   ambiguity. If there are 0 images from the preferred modality, then OSPREY will
   check if an image within the backup modality (i.e. T2w for T1w or T1w for T2w) is
   available to use instead.
3. If --segmentation_dir is specified, try to identify a segmentation that matches the 
   selected anatomical reference. If possible, confirm the correspondance between the
   segmentation and the anatomical images by utilizing the 'SpatialReference' field from
   the semgentation's JSON.
4. Iterate through all the processing configurations specified in the configuration JSON
   file. Steps (1-3) are common to all processing configurations, but the following steps
   will be ran seperately for each configuration (i.e. such as HERCULES and unedited).
5. Find all MRS files that match the naming pattern indicated in the current MRS 
   processing configuration. which files get chosen depend on how (c) is configured.
6. If localizer registration is being used, find all the localizers in the session.
7. Identify pairs of MRS files and localizers that should be used with one another for
   processing.
8. If only one pair of MRS files is found that is compatible for processing, then the
   output of processing will have a structure that mimics the input BIDS structure, 
   plus the name of the configuration. For example, if HERCULES is the name of the
   processing configuration, then the top output folder would be as follows in most
   cases: ::

      /output_dir/sub-<label>[/ses-<label>]/mrs/HERCULES/

   However, if there are multiple MRS file combos that are identified to be compatible
   with HERCULES processing for the given subject (and session if applicable), then
   the output structure would be as follows: ::

      /output_dir/sub-<label>[/ses-<label>]/mrs/HERCULES_filecombo_1
      /output_dir/sub-<label>[/ses-<label>]/mrs/HERCULES_filecombo_2

9. Once the output structure from the previous step is created, the localizer registration
   step will take place if it is requested by the user. If this is activated, the localizer
   that has been identified will be registered to the high-resolution anatomical image. This
   registration will then be used to create a new copy of the segmentation image and the
   high resolution anatomical image that are in the space of the localizer (which should by
   extension also be the same space as the MRS voxel).
   
   If this step is taken, OSPREY will then use these new copies of the anatomical/segmentation
   images. Otherwise, the original anatomical image will be provided to OSPREY, along with the
   segmentation image (assuming --segmentation_dir has been specified).

10. The end result of the previous steps is a new JSON file that tells OSPREY how processing
    should occur for the given subject (or session) and processing configuration. If the processing
    configuration was HERCULES, this would result in a new JSON file at the following path: ::

      /output_dir/sub-<label>[/ses-<label>]/mrs/HERCULES/wrapper_settings.json

    This JSON file is then provided to a MATLAB Compiler Runtime version of OSPREY
    that is within the OSPREY_BIDS container, to run processing and store output
    results within the desired output directory.

11. Following the previous steps, the same procedure will be repeated for any other
    subjects and or sessions in the BIDS directory.


From the steps above, the user should be aware that most of procedure above involve file
manipulations and image registrations. These steps are how OSPREY_BIDS streamlines
MRS processing to be BIDS compatible.

However, you will notice that the above steps do not provide any details about how
the MRS data is manipulated and modeled for the purpose of generating metabolite estimates.
All the workflows for that procedure are described in great detail at: 
https://github.com/schorschinho/osprey.