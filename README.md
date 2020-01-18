# Ethereum CUDA Miner

### Docker container for Ethereum mining with CUDA.

Simple and easy to run, if you have a Nvidia GPU and want to mine eth. Dockerfile updated for Ubuntu 18.04 LTS and CUDA version 10.

**Note:** This image builds ethminer, which is an activily maintained Genoil fork <https://github.com/ethereum-mining/ethminer>. Version is 0.18.0.

### Requirements
- Nvidia drivers for your GPU, you can get them here: [Nvidia drivers](http://www.nvidia.com/Download/index.aspx)
- Nvidia-docker (so docker can access your GPU) install instructions here: [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) OR docker's version 19.x or above that supports natively Nvidia GPUs. Remember to install `nvidia-container-tools` and `nvidia-container-runtime`, though.

### How to run

See `run.example.sh` script.

### Help
`$ ethminer --help`
