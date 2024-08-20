.. toctree::
   :maxdepth: 2
   :caption: Table of Contents
   
   computational_requirements
   installation
   usage
   running_made
   data_requirements
   json_configuration
   expected_outputs
   resources

Computational Requirements
--------------------------

The computational requirements for running HBCD-MADE depend on the input data
(length of acquisition, number of channels, etc), along with the processing settings
(down sampling, filtering, etc.).

For an HBCD style acquisition (1kHz sampling rate, 129 electrodes),
processing generally takes between one and three hours. Within HBCD processing,
MADE is generally initiated with 2 CPUs, 40GB of RAM, and 7 hours of compute time.

.. toctree::
   :maxdepth: 3
   :caption: Contents: