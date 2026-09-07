#!/bin/sh
set -eu

image=$(grep '^  image: quay.io/kairos/hadron:' kubernetes/home-lab/apps/kube-system/kairos-operator/upgrades/node-op-upgrade.yaml)
k3s_version=${image#*-k3s-v}
k3s_version=${k3s_version%-k3s*}

sed -i -E "s|k3s-v[0-9]+\.[0-9]+\.[0-9]+-blue|k3s-v${k3s_version}-blue|" README.md
