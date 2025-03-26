FROM debian:bookworm-slim as builder

ARG BITCOIN_VERSION=${BITCOIN_VERSION:-28.1}

ARG TARGETPLATFORM  

RUN  apt-get update && \
  apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget libc6 procps python3
WORKDIR /tmp
# install bitcoin binaries
RUN case $TARGETPLATFORM in \
  linux/amd64) \
  echo "amd64" && export TRIPLET="x86_64-linux-gnu";; \
  linux/arm64) \
  echo "arm64" && export TRIPLET="aarch64-linux-gnu";; \
  esac && \
  BITCOIN_URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${TRIPLET}.tar.gz" && \
  BITCOIN_FILE="bitcoin-${BITCOIN_VERSION}-${TRIPLET}.tar.gz" && \
  wget -qO "${BITCOIN_FILE}" "${BITCOIN_URL}" && \
  mkdir -p bin && \
  tar -xzvf "${BITCOIN_FILE}" -C /tmp/bin --strip-components=2 "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-cli" "bitcoin-${BITCOIN_VERSION}/bin/bitcoind" "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-wallet" "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-util" 

# Download zipped sourced code for the tag and extract miner.py

# FROM debian:buster-slim as custom-signet-bitcoin
FROM debian:bookworm-slim as custom-signet-bitcoin


LABEL org.opencontainers.image.authors="Alpenlabs"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/alpenlabs/bitcoin_signet"

ENV BITCOIN_DIR /root/.bitcoin 


ENV RPCUSER=${RPCUSER:-"bitcoin"}
ENV RPCPASSWORD=${RPCPASSWORD:-"bitcoin"}
ENV COOKIEFILE=${COOKIEFILE:-"false"}
ENV ONIONPROXY=${ONIONPROXY:-""}
ENV TORPASSWORD=${TORPASSWORD:-""}
ENV TORCONTROL=${TORCONTROL:-""}
ENV I2PSAM=${I2PSAM:-""}

ENV UACOMMENT=${UACOMMENT:-"CustomSignet"}
ENV ZMQPUBRAWBLOCK=${ZMQPUBRAWBLOCK:-"tcp://0.0.0.0:28332"}
ENV ZMQPUBRAWTX=${ZMQPUBRAWTX:-"tcp://0.0.0.0:28333"}
ENV ZMQPUBHASHBLOCK=${ZMQPUBHASHBLOCK:-"tcp://0.0.0.0:28334"}

ENV RPCTHREADS=${RPCTHREADS:-"16"}
ENV RPCSERVERTIMEOUT=${RPCSERVERTIMEOUT:-"600"}
ENV RPCWORKQUEUE=${RPCWORKQUEUE:-"50"}


ENV RPCBIND=${RPCBIND:-"0.0.0.0:38332"}
ENV RPCALLOWIP=${RPCALLOWIP:-"0.0.0.0/0"}
ENV WHITELIST=${WHITELIST:-"0.0.0.0/0"}
ENV ADDNODE=${ADDNODE:-""}
ENV BLOCKPRODUCTIONDELAY=${BLOCKPRODUCTIONDELAY:-"30"}
ENV MINERENABLED=${MINERENABLED:-"1"}
ENV MINETO=${MINETO:-""}
ENV EXTERNAL_IP=${EXTERNAL_IP:-""} 

# Variable used to generate wallets used by bridge operators
# TODO: update this logic to match Testnet I requirement
ENV NUM_WALLETS=${NUM_WALLETS:-0}
VOLUME $BITCOIN_DIR
EXPOSE 28332 28333 28334 38332 38333 38334
RUN  apt-get update && \
  apt-get install -qq --no-install-recommends procps python3 python3-pip jq && \
  apt-get clean
COPY --from=builder "/tmp/bin" /usr/local/bin 
COPY *.sh /usr/local/bin/

# TODO: figure out these imports for the miner script
COPY miner_imports /usr/local/bin
# FIXME: the miner script should be used from the tar file of the downloaded source code
COPY miner /usr/local/bin/miner
COPY rpcauth.py /usr/local/bin/rpcauth.py
# RUN pip3 install setuptools
RUN pip3 install --break-system-packages setuptools

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["run.sh"]