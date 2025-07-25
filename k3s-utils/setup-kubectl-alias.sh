#!/bin/sh

PROFILE="$HOME/.profile"
KCFG_LINE='export UTILS_KUBE_CONFIG_PATH="$HOME/.kube/cp-kubeconfig"'
ALIAS_LINE='alias k="kubectl --kubeconfig \$UTILS_KUBE_CONFIG_PATH"'

### copy kubeconfig file ###
echo 'start copy kubeconfig file...'

mkdir -p "$HOME/.kube"
cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/cp-kubeconfig"
chmod 644 "$HOME/.kube/cp-kubeconfig"
echo 'success to copy kubeconfig file, you can see in $HOME/.kube/cp-kubeconfig'
echo

### set up alias ###
echo 'start setup alias...'

# update UTILS_KUBE_CONFIG_PATH
if grep -q '^export UTILS_KUBE_CONFIG_PATH=' "$PROFILE"; then
    sed -i 's#^export UTILS_KUBE_CONFIG_PATH=.*#'"$KCFG_LINE"'#' "$PROFILE"
else
    echo "$KCFG_LINE" >> "$PROFILE"
fi

# update alias 'k'
if grep -q '^alias k=' "$PROFILE"; then
    sed -i 's#^alias k=.*#'"$ALIAS_LINE"'#' "$PROFILE"
else
    echo "$ALIAS_LINE" >> "$PROFILE"
fi

echo

### apply profile ###
source ~/.profile

echo 'setup success!'
