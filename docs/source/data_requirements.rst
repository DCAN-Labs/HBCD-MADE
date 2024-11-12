
Input Data 
===========

HBCD-MADE takes raw, BIDS formatted HBCD data in .set file format. 

- :ref:`HBCD EEG Task Information <./task_info>` 

- :ref:`Contents of Raw HBCD data folders <./data_contents>`

- :ref:`Required Processing Inputs <./required_inputs>`

.. _./task_info:

HBCD EEG Task Information
--------------------------

.. note:: HBCD EEG Task files can be downloaded from our `GitHub repository <https://github.com/ChildDevLab/Tasks>`_ 

1. Resting State 
^^^^^^^^^^^^^^^^^^

Abbreviation
	RS, Baseline

Construct
	The Resting State Task provides information about neural oscillations and dynamics between oscillatory rhythms across development. Ontogenetic changes in oscillatory activity reflect underlying developing large scale neural networks associated with early critical self-regulatory, cognitive, and affective processes and developmental outcomes.

Description
	In V03, a silent video with a variety of colorful and abstract toys and visuals on screen. The child watches the video for the duration of the task. 

.. image:: images/RS.png
   :width: 700px
   :height: 200px
   :alt: png image above

	In V04/6, a silent video with a variety of marble run and construction visuals on screen. The child watches the video for the duration of the task.

.. image:: images/RS_V4_V6.png
   :width: 400px
   :alt: png image above

**Visits Administered and corresponding age range of administration:**

- V03: 3-9 months
- V04: 9-15 months
- V06: 15-48 months

**Estimated length of time for completion:** Approximately 3 minutes.

2. Face Task 
^^^^^^^^^^^^^

Abbreviation
	FACE			

Construct
	The Face task assesses child and infant face processing abilities as well as the neural structures supporting face and object processing become increasingly specialized during the first years of life. ERPs will be recorded while infants view faces and objects using an oddball task designed to index different stages of processing including attention, perception, categorization, individuation and memory. 

Description
	The task consists of 2 blocks: 50 trials of upright faces & 50 trials of inverted faces and 50 trials of upright faces & 50 trials of objects. If the child loses attention, an attention getter may be played to bring the child’s focus back to the task. There are a total of 36 unique images in the set, with women all displaying neutral expressions, included from each of the following self identifying demographics: Indigenous, Black, White, Asian, Hispanic/Latino, South Asian. 

**Trial Count**

- Block 1: 50 trials of upright faces (UprightINV)
- Block 1: 50 trials of inverted faces (Inverted)
- Block 2: 50 trials of upright faces (UprightOBJ)
- Block 2: 50 trials of obkects. (Object)

**Timing Details**

- Stimulus duration: 500 ms
- Interstimulus interval: 600-700 ms
- Total trial length: 110-1200 ms

.. image:: images/FACE.png
   :width: 400px
   :alt: png image above

**Visits Administered and corresponding age range of administration:**

- V03: 3-9 months
- V04: 9-15 months
- V06: 15-48 months

**Estimated length of time for completion:** Approximately 5 minutes.

3. Auditory Mismatch Negativity Task 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Abbreviation 
	MMN

Construct
	The Auditory mismatch negativity (MMN) Task facilitates examining auditory evoked potentials, habituation/dishabituation to auditory stimuli, as well as perceptual narrowing in language processing. Speech stimuli have been shown to be an important index of future language abilities.

Description
	An auditory presentation of English syllables “ba” and “da”. Video played on iPad as a distractor with brightness all the way up, airplane mode, and not plugged in. The task may be paused if breaks are needed. The .wav files for the auditory stimuli are 196 ms long for the "ba" stimulus and 198 ms long for the "da" stimulus.

**Visits Administered and corresponding age range of administration:**

- V03: 3-9 months
- V04: 9-15 months
- V06: 15-48 months

**Estimated length of time for completion:** Approximately 12 minutes (V03) or 9 minutes (V04/6).

**Trial Count**

- Standard condition: 569 
- Deviant condition: 98 
- Total: 667

**Timing Details**

- Stimulus duration: 200 ms
- InterStimulus interval: 820 ms (V03), 600 ms (V04/V06)
- Total trial length: 1020 ms (V03), 800 (V04/V06)

A schematic of the trial progression for Visit 3 is below.

.. image:: images/MMNtiming.png
   :width: 800px
   :alt: png image above

4. Visual Evoked Potential Task 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Abbreviation
	VEP

Construct
	The Visual Evoked Potential Task (VEP) is a measurement of the primary visual cortex response to visual stimuli. VEP amplitude and latency decreases with age during the first three years of life and has been associated with concurrent and later developmental measures. In addition, the morphology of the VEP likely reflects varying degrees of synaptic efficiency and as such, can be used as a readout of general cortical function.

Description
	A flashing black and white 20x20 checkerboard with a red circle in the center is shown for the duration of the task.

.. image:: images/VEP.png
   :width: 400px
   :alt: png image above

**Visits Administered and corresponding age range of administration:**

- V03: 3-9 months
- V04: 9-15 months
- V06: 15-48 months

**Estimated length of time for completion:** Approximately 1 minute. 

**Trial Counts:** 

- Checkerboard A: 60
- Checkerboard B: 60
- Total: 120

**Timing Details**

- Stimulus duration: 500ms
- Interstimulus interval: N/A
- Total trial length: 500ms

.. _./data_contents:

Contents of Raw HBCD data folders
----------------------------------

.. note:: Not all contents of HBCD EEG folders are used for processing with HBCD-MADE. See :ref:`Required Processing Inputs <./required_inputs>` for a list of required inputs. 

Raw HBCD data folders are curated using the `EEG2BIDS Wizard <https://hbcd-docs.readthedocs.io/en/latest/datacuration/eeg/#eeg2bids-wizard-details>`_, a custom developed software for HBCD EEG data management and BIDS formatting. Each raw data folder contains the following: 

**File Types:** 

- ``EDAT3``- Contain task-specific event information from E-PRIME (stimulus presentation software).
- ``TXT``- Contain E-PRIME event log output.
- ``TSV``- Store metadata and other relevant information.
- ``JSON``- Store metadata and configuration settings in a format that is easy for users to read and edit.
- ``SET``- Contain metadata and parameters for the EEG dataset, such as channel locations, sampling rate, and event information.
- ``FDT``- Field data table files contain EEG data.


Each HBCD subject/session pair has a corresponding BIDS dataset for that session, containing EEG data and other information in the following files and folders:

(1)	``./sub-*`` folder
(2)	``./dataset_description.json``
(3)	``./participants.json``
(4)	``./participants.tsv``
(5)	``./README``

1. ``./sub-* folder``

  Stores raw data and metadata. Contains a folder called ``ses-V03`` which houses an ``eeg`` folder and a ``.tsv`` labeled with the subject ID and recording session. This ``.tsv`` contains the file names and date and time of each EEG recording. The eeg folder contains several ``.json``, ``.fdt``, ``.txt`` and ``.edat3`` files in BIDS format providing information about the recording system, location of electrodes, events for each task, and raw data.

2. ``./dataset_description.json``

  Contains basic information about the dataset such as the subject ID number, version of BIDS used and type of data.

3. ``./participants.json``

  File with descriptions of all variables stored in participants.tsv.

4. ``./participants.tsv``

  Lists basic information about the participant such as the ID and study site where the data were collected.

5. ``./README``

  Provides references and information about BIDS formatting.


.. _./required_inputs:

Required Processing Inputs
---------------------------

(1)	Channel locations file: ``./participants.json``
(2)	EEG and metadata in .set files: ``./sub-<label>_ses-<label>_task-<label>_acq-eeg_eeg.set``
(3)	Processing settings .json: ``./0_2AverageNet128_v1.sfp``
