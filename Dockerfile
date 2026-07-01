# syntax=docker/dockerfile:1.6

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

# -----------------------------
# MATLAB Runtime (optimized)
# -----------------------------
RUN mkdir -p /mcr_path

# Stream extraction (NO COPY layer, no ZIP retained in image)
RUN --mount=type=bind,source=R2023b_mcr.zip,target=/tmp/mcr.zip \
    cd /mcr_path && \
    unzip -q /tmp/mcr.zip || { echo "Unzip failed"; exit 1; }

# -----------------------------
# Python code
# -----------------------------
RUN mkdir /python_code
RUN wget https://s3.msi.umn.edu/pandh015-public/HBCD-MADE-V170-R2023b-beta3.zip -O /python_code/code.zip \
    && cd /python_code && unzip -q ./code.zip \
    && rm /python_code/code.zip

# -----------------------------
# Sample locations
# -----------------------------
RUN mkdir /sample_locs
RUN wget https://s3.msi.umn.edu/leex6144-public/sample_locs_june24_24.zip  -O /sample_locs/sample_locs.zip \
    && cd /sample_locs && unzip -q ./sample_locs.zip \
    && rm /sample_locs/sample_locs.zip

# -----------------------------
# Environment variables
# -----------------------------
ENV MCR_PATH=/mcr_path/R2023b
ENV EXECUTABLE_PATH=/python_code/run_compiled.sh
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/mcr_path/R2023b/runtime/glnxa64:/mcr_path/R2023b/bin/glnxa64:/mcr_path/R2023b/sys/os/glnxa64:/mcr_path/R2023b/extern/bin/glnxa64"

ENV PATH="${PATH}:/python_code"
ENV pipeline_name=made
ENV PYTHONUNBUFFERED=1

COPY ./python_code/run.py /python_code/$pipeline_name
COPY ./python_code/run.py /python_code/run.py

# Change permissions
RUN chmod 555 -R /mcr_path /python_code /sample_locs

ENTRYPOINT ["made"]