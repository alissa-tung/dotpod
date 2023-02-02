#!/usr/bin/env python3

# https://github.com/shadowsocks/shadowsocks-rust/blob/master/acl/genacl_proxy_gfw_bypass_china_ip.py

from typing import List

GEN_PATH: str = "gen/"
OUT_PATH: str = GEN_PATH + "shadowsocks.acl"
GFW_LIST_PATH: str = GEN_PATH + "gfwlist.acl.json"
CN_IP_LIST_PATH: str = GEN_PATH + "china_ip_list.txt"

CUSTOM_BYPASS: List[str] = [
    "127.0.0.1",
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "fd00::/8",
]

CUSTOM_PROXY: List[str] = []


def main():
    file.write(f"[proxy_all]\n")
    file.write(f"\n[proxy_list]\n")
    write_gfw_list(file)
    file.write(f"\n[bypass_list]\n")
    write_cn_ip_list(file)


if __name__ == "__main__":
    main()
