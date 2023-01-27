.DEFAULT_GOAL := all

all: fmt os show
init: vsc-ext

PRIV_PATH ?= ../priv
HS_FMT    ?= ormolu --no-cabal -i

NIX_CMD   ?= nix --experimental-features 'nix-command flakes'
USE_PRIV  ?= --override-input priv ${PRIV_PATH}
NIX_BUILD ?= ${NIX_CMD} build ${USE_PRIV}
NIX_FLAKE ?= ${NIX_CMD} flake

HOSTNAME ?= $(shell ${NIX_CMD} eval ${PRIV_PATH}'#privCfg.hostName' | xargs)

develop:
	${NIX_CMD} develop ${USE_PRIV}

fmt:
	fd -e hs  -x ${HS_FMT}
	fd -e nix -x nixfmt
	${NIX_CMD} fmt ${USE_PRIV}

show:
	${NIX_FLAKE} show ${USE_PRIV}

update-lock:
	${NIX_FLAKE} update ${USE_PRIV}

os:
	${NIX_BUILD} ${PWD}'#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel'

os-install:
	sudo -E nixos-install --flake ${PWD}'#${HOSTNAME}'

disko:
	${NIX_BUILD} ${PWD}'#nixosConfigurations.${HOSTNAME}.config.system.build.disko'

installer:
	NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/$(shell jq '.nodes.nixpkgs.locked.rev' flake.lock).tar.gz \
	nix-shell -p nixos-generators --run                                                                                 \
		"nixos-generate --format iso --configuration ./installer.nix -o result"

vsc-ext:
	./scripts/vsc-ext.sh > gen/vsc.nix
	nixfmt         gen/vsc.nix
	nixpkgs-fmt -i gen/vsc.nix
