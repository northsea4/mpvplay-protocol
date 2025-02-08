#!/bin/bash -ex
rm -rf mpvplay-protocol.app.zip mpvplay-protocol.app
./build.sh
cp -r mpvplay-protocol-app mpvplay-protocol.app
zip -r mpvplay-protocol.app.zip mpvplay-protocol.app -x '*.DS_Store'
