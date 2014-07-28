#!/bin/sh

# add the couchbase repo so we can get libcouchbase
sudo rm -rf /etc/apt/sources.list.d/*
sudo add-apt-repository -y ppa:pypy/ppa
wget -O- http://packages.couchbase.com/ubuntu/couchbase.key | sudo apt-key add -
echo "deb http://packages.couchbase.com/ubuntu oneiric oneiric/main" | sudo tee /etc/apt/sources.list.d/couchbase.list
sudo apt-get update

# install couchbase
couchbase_file="couchbase-server-enterprise_${COUCHBASE_VERSION}_x86_64.deb"
cd /tmp
echo "Downloading Couchbase $COUCHBASE_VERSION"
wget http://packages.couchbase.com.s3.amazonaws.com/releases/$COUCHBASE_VERSION/$couchbase_file
echo "Installing Couchbase $COUCHBASE_VERSION"
# more control on start needed sorry debian package
sudo env INSTALL_DONT_START_SERVER=1 dpkg -i $couchbase_file

# start the server
/opt/couchbase/bin/couchbase-server -- -noinput -detached
# wait for it to accept connections
while ! echo exit | nc localhost 8091; do sleep 10; done

# setting up the server with the test bucket
CBCLI=/opt/couchbase/bin/couchbase-cli
$CBCLI node-init -c localhost:8091

$CBCLI cluster-init -c localhost:8091 \
  --cluster-init-username=Administrator --cluster-init-password=asdasd \
  --cluster-init-ramsize=256

$CBCLI bucket-create -c localhost:8091 \
  --bucket=orm_adapter \
  --bucket-type=couchbase \
  --bucket-ramsize=256 \
  --enable-flush=1 \
  -u Administrator -p asdasd



