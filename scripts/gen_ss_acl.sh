#!/usr/bin/env bash
set -eu -o pipefail

cd ./gen || exit
curl --remote-name 'https://raw.githubusercontent.com/NateScarlet/gfwlist.acl/master/gfwlist.acl.json'
curl --remote-name 'https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt'
cd ..

./scripts/gen_ss_acl.py
