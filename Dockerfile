FROM nvidia/driver:440.64.00-ubuntu18.04

WORKDIR /

ADD \
https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin \
.

ADD \
https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub \
.

RUN \
mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
&& apt-get update \
&& apt-get -y --no-install-recommends install gnupg2 software-properties-common \
&& apt-key add 7fa2af80.pub \
&& add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" \
&& apt-get update \

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
-P stratums://0xB71E12CF3A8dA259FF191f0AD234FA46eEb88b72.ec2@eu1.ethermine.org:5555 \
-P stratums://0xB71E12CF3A8dA259FF191f0AD234FA46eEb88b72.ec2@asia1.ethermine.org:5555 \
-P stratums://0xB71E12CF3A8dA259FF191f0AD234FA46eEb88b72.ec2@us1.ethermine.org:5555 \
-P stratums://0xB71E12CF3A8dA259FF191f0AD234FA46eEb88b72.ec2@us2.ethermine.org:5555"]
