#!/bin/sh
set -eu

image=$(grep '^  image: quay.io/kairos/hadron:' kubernetes/home-lab/apps/kube-system/kairos-operator/upgrades/node-op-upgrade.yaml)
kairos_image=${image#*quay.io/kairos/hadron:}
k3s_version=${kairos_image#*-k3s-v}
k3s_version=${k3s_version%-k3s*}
node_name=$(printf '%s\n' "$kairos_image" | sed -E 's/^v([0-9]+)\.([0-9]+)\.([0-9]+)-standard-amd64-generic-v([0-9]+)\.([0-9]+)\.([0-9]+)-k3s-v([0-9]+)\.([0-9]+)\.([0-9]+)-k3s[0-9]+$/hadron-v\1-\2-\3-kairos-v\4-\5-\6-k3s-v\7-\8-\9/')

sed -i -E "s|^  name: hadron-v[0-9]+-[0-9]+-[0-9]+-kairos-v[0-9]+-[0-9]+-[0-9]+-k3s-v[0-9]+-[0-9]+-[0-9]+$|  name: ${node_name}|" kubernetes/home-lab/apps/kube-system/kairos-operator/upgrades/node-op-upgrade.yaml
sed -i -E "s|k3s-v[0-9]+\.[0-9]+\.[0-9]+-blue|k3s-v${k3s_version}-blue|" README.md
