# [`sempernow/k8s-iperf`](https://github.com/sempernow/k8s-iperf "GitHub.com") | [iPerf | iPerf3](https://iperf.fr/ "iperf.fr") | [`gd9h/iperf`](https://hub.docker.com/r/gd9h/iperf/tags "hub.docker.com")

### TL;DR

Performs __network throughput__ tests.

__iPerf__ performs a measure of the __maximum network transfer rate between server and client__.
Used in a K8s environment having Calico CNI configured for direct path (eBPF), on Hyper-V guest VMs running RHEL 9, we measured that maximum `Gbits/sec` (`Gbps`) for east-west traffic, both cross-node (__5 Gpbs__) and intra-node (__35 Gbps__). 

__Throughput__ for traffic on Pod Network:

|East-west| `Gbps`|
|--|--|
|Intra-node| __`5`__|
|Inter-node|__`35`__|


## [`k8s-iperf3.sh`](k8s-iperf.sh) 

```bash
git clone git@github.com:sempernow/k8s-iperf.git
cd k8s-iperf
bash k8s-iperf.sh
```

## Pod Network Performce Test

@ __Server__

```bash
img=gd9h/iperf:3.19-hard
p=5555
name=server
k run $name --image=$img -- iperf3 -s -p $p

```

@ __Client__ : __Same node__

```bash
name=server
node=$(kubectl get pod $name -o jsonpath='{.spec.nodeName}') ||
    echo "⚠️  ERR @ node: $?" >&2
ip=$(kubectl get pod $name -o wide -o jsonpath='{.status.podIPs[].ip}') ||
    echo "⚠️  ERR @ ip: $?" >&2
img=gd9h/iperf:3.19-hard
p=5555
name=client-same
k run $name -it --rm \
    --image=$img \
    --overrides='{"spec": {"nodeName": "'$node'"}}' \
    --restart=Never  -- \
    iperf3 -c $ip -p $p

```
```plaintext
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  4.24 GBytes  36.4 Gbits/sec  317   1.18 MBytes
[  5]   1.00-2.00   sec  4.27 GBytes  36.7 Gbits/sec  426   1.31 MBytes
[  5]   2.00-3.00   sec  4.16 GBytes  35.8 Gbits/sec  277   1.27 MBytes
[  5]   3.00-4.00   sec  4.13 GBytes  35.5 Gbits/sec    0   1.61 MBytes
[  5]   4.00-5.00   sec  4.10 GBytes  35.2 Gbits/sec  394   1.83 MBytes
[  5]   5.00-6.00   sec  4.03 GBytes  34.6 Gbits/sec    0   1.84 MBytes
[  5]   6.00-7.00   sec  4.10 GBytes  35.2 Gbits/sec  751   1.84 MBytes
[  5]   7.00-8.00   sec  3.75 GBytes  32.2 Gbits/sec    1   1.93 MBytes
[  5]   8.00-9.00   sec  3.94 GBytes  33.8 Gbits/sec  259   2.08 MBytes
[  5]   9.00-10.00  sec  4.03 GBytes  34.6 Gbits/sec    0   2.09 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  40.8 GBytes  35.0 Gbits/sec  2425             sender
[  5]   0.00-10.00  sec  40.8 GBytes  35.0 Gbits/sec                  receiver
```


@ __Client__ : __Cross node__

```bash
name=server
node=$(kubectl get pod $name -o jsonpath='{.spec.nodeName}')
node=$(kubectl get node -o yaml |yq '.[][].metadata |select (.name != "'$node'") |.name' |head -n1) ||
    echo "⚠️  ERR @ node: $?" >&2
ip=$(kubectl get pod $name -o wide -o jsonpath='{.status.podIPs[].ip}') ||
    echo "⚠️  ERR @ ip: $?" >&2

img=gd9h/iperf:3.19-hard
name=client-cross
k run $name -it --rm \
    --image=$img \
    --overrides='{"spec": {"nodeName": "'$node'"}}' \
    --restart=Never  -- \
    iperf3 -c $ip -p $p

```
```plaintext
...
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   700 MBytes  5.87 Gbits/sec   66   1.06 MBytes
[  5]   1.00-2.00   sec   625 MBytes  5.24 Gbits/sec    0   1.37 MBytes
[  5]   2.00-3.00   sec   618 MBytes  5.19 Gbits/sec    0   1.46 MBytes
[  5]   3.00-4.00   sec   618 MBytes  5.18 Gbits/sec  319   1.50 MBytes
[  5]   4.00-5.00   sec   614 MBytes  5.15 Gbits/sec   77   1.52 MBytes
[  5]   5.00-6.00   sec   598 MBytes  5.02 Gbits/sec   62   1.53 MBytes
[  5]   6.00-7.00   sec   599 MBytes  5.02 Gbits/sec  421   1.55 MBytes
[  5]   7.00-8.00   sec   579 MBytes  4.86 Gbits/sec    0   1.56 MBytes
[  5]   8.00-9.00   sec   584 MBytes  4.90 Gbits/sec    0   1.57 MBytes
[  5]   9.00-10.00  sec   601 MBytes  5.04 Gbits/sec    0   1.58 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  5.99 GBytes  5.15 Gbits/sec  945             sender
[  5]   0.00-10.00  sec  5.99 GBytes  5.14 Gbits/sec                  receiver
```

Note these metrics are also at iperf3 server __log__:

```bash
☩ k logs nbox1
-----------------------------------------------------------
Server listening on 5555 (test #1)
-----------------------------------------------------------
Accepted connection from 10.244.182.130, port 33168
[  5] local 10.244.182.128 port 5555 connected to 10.244.182.130 port 33172
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  4.38 GBytes  37.6 Gbits/sec
[  5]   1.00-2.00   sec  4.72 GBytes  40.5 Gbits/sec
[  5]   2.00-3.00   sec  4.64 GBytes  39.8 Gbits/sec
[  5]   3.00-4.00   sec  4.75 GBytes  40.8 Gbits/sec
[  5]   4.00-5.00   sec  4.57 GBytes  39.2 Gbits/sec
[  5]   5.00-6.00   sec  4.39 GBytes  37.8 Gbits/sec
[  5]   6.00-7.00   sec  4.46 GBytes  38.3 Gbits/sec
[  5]   7.00-8.00   sec  4.38 GBytes  37.7 Gbits/sec
[  5]   8.00-9.00   sec  4.31 GBytes  37.0 Gbits/sec
[  5]   9.00-10.00  sec  4.35 GBytes  37.4 Gbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-10.00  sec  45.0 GBytes  38.6 Gbits/sec                  receiver
```



### &nbsp;
