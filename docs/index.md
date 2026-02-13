# HBCD-MADE- an automated developmental EEG preprocessing pipeline

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14194452.svg)](https://doi.org/10.5281/zenodo.14194452) [![HBCD-MADE](https://img.shields.io/badge/NMIND-17%2F42-orange?logo=data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjQgMjQiIGZpbGw9IiNDRDdGMzIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPHBhdGggZD0iTTMuMzc3NTIgNS4wODI0MUMzIDUuNjIwMjggMyA3LjIxOTA3IDMgMTAuNDE2N1YxMS45OTE0QzMgMTcuNjI5NCA3LjIzODk2IDIwLjM2NTUgOS44OTg1NiAyMS41MjczQzEwLjYyIDIxLjg0MjQgMTAuOTgwNyAyMiAxMiAyMkMxMy4wMTkzIDIyIDEzLjM4IDIxLjg0MjQgMTQuMTAxNCAyMS41MjczQzE2Ljc2MSAyMC4zNjU1IDIxIDE3LjYyOTQgMjEgMTEuOTkxNFYxMC40MTY3QzIxIDcuMjE5MDcgMjEgNS42MjAyOCAyMC42MjI1IDUuMDgyNDFDMjAuMjQ1IDQuNTQ0NTQgMTguNzQxNyA0LjAyOTk2IDE1LjczNTEgMy4wMDA3OUwxNS4xNjIzIDIuODA0NzJDMTMuNTk1IDIuMjY4MjQgMTIuODExNCAyIDEyIDJDMTEuMTg4NiAyIDEwLjQwNSAyLjI2ODI0IDguODM3NzIgMi44MDQ3Mkw4LjI2NDkxIDMuMDAwNzlDNS4yNTgzMiA0LjAyOTk2IDMuNzU1MDMgNC41NDQ1NCAzLjM3NzUyIDUuMDgyNDFaIi8+Cjwvc3ZnPgo=)](https://www.nmind.org/proceedings/hbcdmade/)

This page serves as documentation for the HBCD-MADE pipeline, an adapted version of the Maryland Analysis of Developmental EEG (MADE) pipeline (Debnath et al., 2020) designed for use with data from the Healthy Brain and Child Development (HBCD) study. The GitHub repository for the MADE pipeline upon which HBCD-MADE is based can be found [here](https://github.com/ChildDevLab/MADE-EEG-preprocessing-pipeline), and a publication describing the original pipeline can be found [here](https://pubmed.ncbi.nlm.nih.gov/32293719/).

## Overview of MADE processing 

The HBCD-MADE pipeline will run preprocessing on BIDS-formatted data with EEG files being in .set and .fdt file format. All metadata required for running the HBCD-MADE pipeline is present within the .set files themselves, and other BIDS metadata will not be referenced during processing. In general, HBCD-MADE’s functionality is as follows:

![flowchart](flowchart.png)

1. Identify all session-level EEG data for a given recording session.
2. Iterate through all EEG files for the identified session, downsample the data, delete the outer layer of channels (which are often noisy in infant populations), and filter each file with the desired high-pass/low-pass settings.
3. Merge all task files together.
4. Check whether any electrodes are outliers at the session level. This is done by using FASTER (Nolan, 2010). In short, for each electrode, the following measures will be calculated to judge outlier status, and any electrodes that have deviations greater than 3 SDs on any given measure will be excluded from further analysis:
    * The average temporal correlation to other electrodes
    * The Hurst exponent (measuring the self-similarity within each electrode’s time signal
    * The signal variance
5. Run through ICA on the electrodes:
    * Create a temporary copy of the EEG signal high passed at 1Hz for ICA
    * Create 1s epochs and remove those with outlier characteristics
    * Generate independent components (ICs) on good electrodes and good epochs
    * Classify the ICs into categories (such as blink) based on spatial and temporal characteristics
    * Subtract the bad ICs from the original data
6. Separate the merged data back into individual tasks
7. Epoch task-based data based on event markers
8. Remove epochs that still have high voltage fluctuations.
9. Interpolate over bad channels within epochs.
10. Interpolate deleted channels across epochs.
11. Re-reference the data to the average reference.
12. Save the final output consisting of cleaned and epoched EEG data.

## Contributors
**Original Contributors to MADE pipeline:**

* Ranjan Debnath (ranjan.ju@gmail.com)
* George A. Buzzell (gbuzzell@fiu.edu)
* Santiago Morales (santiago.morales@usc.edu)
* Stephanie Leach (stephanie-leach@uiowa.edu)
* Maureen Elizabeth Bowers (maureenbowers@gmail.com)
* Nathan A. Fox (fox@umd.edu)

**Past Contributors:**

* Martin Antunez Garcia (mantunez@umd.edu)
* Lydia Yoder (lyoder@umd.edu)
* Marco McSweeney (mmcsw1@umd.edu)
* Savannah McNair (smcnair1@umd.edu)
* Jessica Norris (jnorri10@umd.edu)
* Erik Lee (eex6144@umn.edu)

**Ongoing Contributors:**

* Alicia Vallorani (avallora@umd.edu)
* Kira Ashton (kashton7@umd.edu)
* Trisha Maheshwari (tmahesh@umd.edu)
* Whitney E. Kasenetz (kasenetz@umd.edu)
* Dylan Gilbreath (dylangil@umd.edu)
            
## Contents 

- [Installation](https://docs-hbcd-made.readthedocs.io/en/latest/installation/)
- [Usage & Tutorial](https://docs-hbcd-made.readthedocs.io/en/latest/tutorial/)
- [Processing Settings and Configuration](https://docs-hbcd-made.readthedocs.io/en/latest/proc_settings/)
- [Expected Outputs](https://docs-hbcd-made.readthedocs.io/en/latest/expected-outputs/)
- [Derivatives and ERP Specifications](https://docs-hbcd-made.readthedocs.io/en/latest/derivatives_ERPspecs/)
- [Help](https://https://docs-hbcd-made.readthedocs.io/en/latest/help/)
