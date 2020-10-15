#!/bin/sh

# Miner account
export ETH_WALLET=0xB71E12CF3A8dA259FF191f0AD234FA46eEb88b72
export WORKER_NAME=ec2

# Start mining!
docker run --gpus all -e 0xB71E12CF3A8dA259FF191f0AD234FA46eEb88b72 -e ec2 -P -it ethminer:0.18.0
