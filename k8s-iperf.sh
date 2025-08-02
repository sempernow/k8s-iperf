#!/usr/bin/env bash
#################################################################
# Bandwidth (Throughput) test of your K8s Cluster (Pod) Network.
#
# - Performs two measurements:
#   - Same-node case
#   - Cross-node case
#
# - Throughput is expected to vary by host network,
#   CNI provider, their configurations,
#   and adjacent network-traffic conditions.
#
# ARGs: [PORT(else 5555)]
#################################################################
kubectl version >/dev/null || {
    echo '  REQUIREs kubectl'
    exit 1
}
img=nicolaka/netshoot               # https://github.com/nicolaka/netshoot
img=gd9h/iperf:3.19-patch-20250729  # https://hub.docker.com/repository/docker/gd9h/iperf/general
img=gd9h/iperf@sha256:e6714155eea9238cd91caf6373a4173d1d44b723037240c9e8f10de02c9ca859
port=${1:-5555} # Presumed okay

clear;echo "
=======================================================
🚀  Bandwidth test of K8s Pod Network using iperf3

    $img
"
echo -e '\n🛠️  === Create and set context to a per-run Namespace …'
echo -e "Traffic port: $port"
nonce="$(cat /dev/urandom |tr -dc 'a-z0-9' |fold -w 5 |head -n 1)" || 
    nonce="$(date '+%H%M%S')"
ns="test-iperf3-$nonce"
kubectl create ns $ns
kubectl get ns $ns || {
    echo "⚠   === ERR : Namespace '$ns' NOT EXIST"
    exit 2
}
kubectl config set-context --current --namespace $ns

# Server
sPod=server
echo -e '\n🛠️  === Creating the server …'
kubectl run $sPod --image=$img -- iperf3 -s -p $port
while [[ -z $sNode || -z $sIP ]]; do
    echo "Awaiting Node and IP status of Pod '$sPod' …" 
    export sNode=$(kubectl get pod $sPod -o jsonpath='{.spec.nodeName}')
    export sIP=$(kubectl get pod $sPod -o wide -o jsonpath='{.status.podIPs[].ip}')
    sleep 3
done
echo "✅  === Server pod '$sPod' running at node '$sNode'." 

# Clients : One case at a time
cNode=$sNode
cPod=client
echo -e "\n🛠️  === Run client pod '$cPod', same-node then cross-node WRT server, sequentially …"
# - Same-node (IntRA-node) case
echo -e "\n📊  === Same-node ($sNode-$cNode) traffic between server '$sPod@$sNode' and client '$cPod@$cNode' [Pod@Node] …"
kubectl run $cPod -it --rm \
    --image=$img \
    --overrides='{"spec": {"nodeName": "'$sNode'"}}' \
    --restart=Never  -- \
    iperf3 -c $sIP -p $port
while kubectl get pod $cPod &> /dev/null; do
    echo "Awaiting deletion of Pod '$cPod' …"
    sleep 2
done
# - Cross-node (IntER-node) case
cNode=$(kubectl get node -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}{end}' |grep -v "^$sNode" |head -n1)
echo -e "\n📊  === Cross-node ($sNode-$cNode) traffic between server '$sPod@$sNode' and client '$cPod@$cNode' [Pod@Node] …"
kubectl run $cPod -it --rm \
    --image=$img \
    --overrides='{"spec": {"nodeName": "'$cNode'"}}' \
    --restart=Never  -- \
    iperf3 -c $sIP -p $port

# Teardown
echo -e '\n🚧  === Teardown'
kubectl config set-context --current --namespace default
kubectl delete ns ${ns:-___nonexistent_namespace___}
echo -e '🔚  === Done'
