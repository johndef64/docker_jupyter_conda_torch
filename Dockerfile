# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# git clone https://github.com/johndef64/docker_jupyter_conda_torch.git

ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get install -y sudo
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install PyTorch with pip (https://pytorch.org/get-started/locally/)
# hadolint ignore=DL3013
#RUN pip install --no-cache-dir --index-url 'https://download.pytorch.org/whl/cu118' \
#    'torch' \
#    'torchvision' \
#    'torchaudio'  && \
#    fix-permissions "${CONDA_DIR}" && \
#    fix-permissions "/home/${NB_USER}"

#######################################################
#
# Update and install necessary packages
RUN apt-get update && apt-get install -y sudo openssh-server
#RUN apt update && apt install  openssh-server sudo -y

#possible Fix
#RUN usermod -o -u 1000 <user>
RUN usermod -o -u 1000 ${NB_USER}

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g ${NB_USER} -G sudo -u 1000 user
#RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 user
# => ERROR [5/7] RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 user:
#0 0.335 useradd: UID 1000 is not unique


RUN echo 'user:Iknos2023' | chpasswd

RUN service ssh start

EXPOSE 22
CMD ["/bin/bash", "-c", "/usr/sbin/sshd && jupyter lab --ip='0.0.0.0' --port=8888 --no-browser --allow-root --notebook-dir=/opt/data"]