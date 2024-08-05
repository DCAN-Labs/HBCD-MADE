.. OSPREY_BIDS documentation master file, created by
   sphinx-quickstart on Thu Jun 13 14:05:35 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to OSPREY_BIDS's documentation!
=======================================

DOCUMENTATION IS STILL A WORK IN PROGRESS. ANY DETAILS FOUND ON THESE PAGES
SHOULD BE CONSIDERED TEMPORARY/INCOMPLETE UNTIL THIS DISCLAIMER IS REMOVED.

This tool is used in the Healthy Brain and Child Development (HBCD) study
for processing magnetic resonance spectroscopy (MRS) data. The tool acts 
as a BIDS extension to the `OSPREY <https://github.com/schorschinho/osprey>`_ pipeline.

The utility of this application is largely three-fold: 

1. To make the core functionality of OSPREY available via Docker/Singularity
   containers so that users do not need to install any dependencies or have a Matlab
   license before processing.
2. Extending OPSREY to have BIDS App functionality. OSPREY_BIDS takes as input a BIDS
   dataset, automates processing by assuming the input follows BIDS guidelines, and structures
   processing outputs using general BIDS derivatives principles.
3. Registration. OSPREY_BIDS allows for registering high anatomical T1w/T2w images
   to a localizer image collected immediately before/after the MRS acquisition. This
   step ensures that even if there is movement between the high-res anatomical and 
   MRS localizer that (a) segmentation-based tissue correction can still occur
   and (b) the MRS voxel positioning can be displayed on a high-res underlay.







.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   usage
   expected_inputs
   processing_pipeline_details

