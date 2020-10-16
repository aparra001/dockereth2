FROM nvidia/driver:440.64.00-1.0.0-4.15.0-91-ubuntu18.04

WORKDIR /

ADD \
https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-ubuntu1604.pin \
.

ADD \
https://developer.download.nvidia.com/compute/cuda/10.0/secure/Prod/local_installers/cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1_amd64.deb \
.

# Package and dependency setup
RUN \
mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
&& dpkg -i cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1_amd64.deb
&& apt-key add /var/cuda-repo-10-0-local-10.0.130-410.48/7fa2af80.pub
&& apt-get update
&& apt-get -y install cuda
&& apt-get install libcurl3 -y

RUN apt-get update \
    && apt-get -y install software-properties-common \
    && apt-get update \
    && apt-get install -y git cmake build-essential

# Git repo set up
RUN git clone https://github.com/ethereum-mining/ethminer.git; \
    cd ethminer; \
    git submodule update --init --recursive; \
    git checkout tags/v0.16.1

# Build. Use all cores.
RUN cd ethminer; \
    mkdir build; \
    cd build; \
    cmake .. -DETHASHCUDA=ON -DAPICORE=ON -DETHASHCL=OFF -DBINKERN=OFF; \
    cmake --build . -- -j; \
    make install;

# Miner API port inside container
ENV ETHMINER_API_PORT=3333
EXPOSE ${ETHMINER_API_PORT}

# Prevent GPU overheading by stopping in 80C and starting again in 50C
ENV GPU_TEMP_STOP=80
ENV GPU_TEMP_START=50

# Start miner. Note that wallet address and worker name need to be set
# in the container launch.
CMD ["bash", "-c", "/usr/local/bin/ethminer -U --api-port ${ETHMINER_API_PORT} \
--HWMON 1 --tstart ${GPU_TEMP_START} --tstop ${GPU_TEMP_STOP} --exit \
-P stratums://$ETH_WALLET.$WORKER_NAME@eu1.ethermine.org:5555 \
-P stratums://$ETH_WALLET.$WORKER_NAME@asia1.ethermine.org:5555 \
-P stratums://$ETH_WALLET.$WORKER_NAME@us1.ethermine.org:5555 \
-P stratums://$ETH_WALLET.$WORKER_NAME@us2.ethermine.org:5555"]
