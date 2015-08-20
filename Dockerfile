# best start with PASSWORD created from pwgen:
#   docker run -e PASSWORD=$(pwgen 44 1) mwaeckerlin/bitcoind
FROM ubuntu
MAINTAINER mwaeckerlin

# can be overwritten wth option -e name=value
# password is mandatory: -e PASSWORD=
ENV OPTIONS -debug-net -upgradewallet -printtoconsole
ENV USER bitcoinrpc
ENV PASSWORD ""

# install bitcound
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y bitcoind

# configure user bitcoin's home path /data as bitcoind data path
RUN useradd -s /bin/bash -m -d /data bitcoin
RUN chown bitcoin:bitcoin -R /data
VOLUME /data
WORKDIR /data
USER bitcoin

# public api
EXPOSE 8332 8333

# at each start:
# - check if PASSWORD is set (in "docker run -e PASSWORD=...") or abort
# - check if /data/bitcoin.conf exist, or create it
# - start bitcoind
CMD test -n "${PASSWORD}" || ( \
      echo "You must specify a password, use -e PASSWORD="; \
      exit 1; \
    ); \
    test -f /data/bitcoin.conf || ( \
      echo "rpcuser=${USER}"; \
      echo "rpcpassword=${PASSWORD}"; \
    ) > /data/bitcoin.conf && chmod go= /data/bitcoin.conf; \
    bitcoind -datadir=/data -server ${OPTIONS};
