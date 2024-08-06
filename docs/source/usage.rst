.. HBCD_MADE documentation master file, created by
   sphinx-quickstart on Wed Jun  5 10:48:12 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Usage
=====

The design of the application is meant to follow general 
`BIDS-App guidelines <https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005209>`_.
For more details on general usage principles of BIDS-Apps, see the linked documentation.

As described in the installation section, this tool is meant to be
interacted with in containerized form. The example below shows the
general layout for how you may want to interact with the container
to conduct processing if you have the container downloaded as a
singularity image: ::


        container_path=/path/to/container.sif
        bids_dir=/path/to/bids
        output_dir=/path/to/output
        bibsnet_dir=/path/to/bibsnet
        settings_file=/path/to/settings.json
        singularity run -B $bids_dir:/bids \
         -B $output_dir:/output \
         -B $settings_file:/settings_file/file.json \
         $container_path /bids /output participant /settings_file/file.json

To see more specific information about how this tool expects
the inputs to be formatted (i.e. file naming conventions), 
see the data requirements page.


Command-Line Arguments
----------------------
.. argparse::
   :ref: python_code.run.build_parser
   :prog: made
   :nodefaultconst:

.. toctree::
   :maxdepth: 2
   :caption: Contents: