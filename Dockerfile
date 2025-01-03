#The base image is the latest ubuntu docker image
FROM python:3.9.16-slim-bullseye

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    apt-utils \
                    autoconf \
                    build-essential \
                    bzip2 \
                    ca-certificates \
                    curl \
                    gcc \
                    git \
                    gnupg \
                    libtool \
                    lsb-release \
                    pkg-config \
                    unzip \
                    wget \
                    xvfb \
                    zlib1g \
                    default-jre \
                    pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

RUN python3 -m pip install --upgrade pip
RUN pip install numpy

#Setup MCR - this grabs v912 of MCR that was downloaded from the matlab
#website, installed at MSI, and then zipped. If you want to use a
#different version of matlab then download the corresponding version
#of MCR, install it, zip it, and upload the new path to a public bucket
#on S3
RUN mkdir /mcr_path
RUN wget https://s3.msi.umn.edu/leex6144-public/v912.zip -O /mcr_path/mcr.zip \
    && cd /mcr_path && unzip -q ./mcr.zip \
    && rm /mcr_path/mcr.zip 

#Download the unique code for this project
RUN mkdir /python_code
RUN wget https://s3.msi.umn.edu/leex6144-public/HBCD-MADE-v150.zip -O /python_code/code.zip \
    && cd /python_code && unzip -q ./code.zip \
    && rm /python_code/code.zip

#Download the sample locations/electrode files
RUN mkdir /sample_locs
RUN wget https://s3.msi.umn.edu/leex6144-public/sample_locs_june24_24.zip  -O /sample_locs/sample_locs.zip \
    && cd /sample_locs && unzip -q ./sample_locs.zip \
    && rm /sample_locs/sample_locs.zip

#Export paths (make sure LD_LIBRARY_PATH is set to the correct version)
ENV MCR_PATH=/mcr_path/v912
ENV EXECUTABLE_PATH=/python_code/run_compiled.sh
ENV LD_LIBRARY_PATH ="${LD_LIBRARY_PATH}:/mcr_path/v912/runtime/glnxa64:/mcr_path/v912/bin/glnxa64:/mcr_path/v912/sys/os/glnxa64:/mcr_path/v912/extern/bin/glnxa64"


#Add code dir to path
ENV PATH="${PATH}:/python_code"
ENV pipeline_name=made
COPY ./python_code/run.py /python_code/$pipeline_name
COPY ./python_code/run.py /python_code/run.py

#Change Permissions
RUN chmod 555 -R /mcr_path /python_code /sample_locs

ENTRYPOINT ["made"]
