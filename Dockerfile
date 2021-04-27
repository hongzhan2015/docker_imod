FROM ubuntu:16.04 AS ubuntu-base
RUN  apt-get clean \
&& apt-get update \
&& apt-get install -y --no-install-recommends \
&& apt-get install -y ca-certificates

FROM ubuntu-base as ubuntu-with-prerequisites
RUN apt-get install -y libjpeg62 \
libglu1 \
python

FROM ubuntu-with-prerequisites as ubuntu-with-build-tools
RUN apt-get install -y libjpeg62 \
libglu1 \
build-essential=12.1ubuntu2 \
bzip2 \
cmake=3.5.1-1ubuntu3 \
gcc=4:5.3.1-1ubuntu1 \
unzip=6.0-20ubuntu1 \
zip=3.0-11 \
git \
wget \
python \
&& rm -rf /var/lib/apt/lists/*

FROM ubuntu-with-build-tools as build-imod
RUN mkdir installIMOD \
&& wget https://bio3d.colorado.edu/imod/AMD64-RHEL5/imod_4.11.5_RHEL6-64_CUDA8.0.sh \
&& yes | sh imod_4.11.5_RHEL6-64_CUDA8.0.sh -dir /installIMOD 

FROM ubuntu-with-prerequisites
WORKDIR /opt/imod
COPY --from=build-imod /installIMOD/IMOD /opt/imod
RUN cp ~/.profile /tmp/.profile.bak \
    && echo 'export IMOD_DIR=/opt/imod' > ~/.profile \
    && echo 'if [ -e $IMOD_DIR/IMOD-linux.sh ] ; then source $IMOD_DIR/IMOD-linux.sh ; fi' >> ~/.profile \
    && cat /tmp/.profile.bak >> ~/.profile \
    && rm /tmp/.profile.bak \
    && cp ~/.bashrc /tmp/.bashrc.bak \
    && echo 'export IMOD_DIR=/opt/imod' > ~/.bashrc \
    && echo 'if [ -e $IMOD_DIR/IMOD-linux.sh ] ; then source $IMOD_DIR/IMOD-linux.sh ; fi' >> ~/.bashrc \
    && cat /tmp/.bashrc.bak >> ~/.bashrc \
    && rm /tmp/.bashrc.bak

ENV PATH="/opt/imod/:$PATH"

ARG DEBIAN_FRONTEND=noninteractive