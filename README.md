[k8s-iperf](https://github.com/sempernow/k8s-iperf)


>Bandwidth (Throughput) test of your K8s Cluster (Pod) Network.

- Both same-node and cross-node cases are measured.
- Often referred to as east-west or inter-pod traffic,
  these throughput measurements are expected to vary
  by host network, CNI provider, their configurations,
  and adjacent network-traffic conditions.

## Usage

```bash
bash k8s-iperf.sh
```
```plaintext
=======================================================
🚀  Bandwidth test of K8s Pod Network using iperf3


🚧 === Create and set context to a per-run Namespace …
namespace/test-iperf3-8whoepq created
NAME                  STATUS   AGE
test-iperf3-8whoepq   Active   0s
Context "kubernetes-admin@lime" modified.

🚧 === Traffic port: 5555

🚧 === Creating the server …
pod/server created
Awaiting Node and IP status of Pod 'server' …
Awaiting Node and IP status of Pod 'server' …
✅ === Server pod 'server' running at node 'a1'.
Next, run client pods 'client' sequentially (IntRA-node, IntER-node) …

📊 === Same-node (a1-a1) traffic between server 'server@a1' and client 'client@a1' [Pod@Node] …
If you don't see a command prompt, try pressing enter.
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.74 GBytes  23.5 Gbits/sec  3775   3.16 MBytes
...
[  5]   9.00-10.00  sec  2.87 GBytes  24.7 Gbits/sec   32   1.31 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  27.6 GBytes  23.7 Gbits/sec  6590             sender
[  5]   0.00-10.00  sec  27.6 GBytes  23.7 Gbits/sec                  receiver

iperf Done.
pod "client" deleted

📊 === Cross-node (a1-a2) traffic between server 'server@a1' and client 'client@a2' [Pod@Node] …
If you don't see a command prompt, try pressing enter.
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   328 MBytes  2.75 Gbits/sec    1   4.10 MBytes
...
[  5]   9.00-10.00  sec   427 MBytes  3.58 Gbits/sec   58   4.10 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  3.93 GBytes  3.37 Gbits/sec   59             sender
[  5]   0.00-10.00  sec  3.93 GBytes  3.37 Gbits/sec                  receiver

iperf Done.
pod "client" deleted

🚧 === Teardown
Context "kubernetes-admin@lime" modified.
namespace "test-iperf3-8whoepq" deleted

======================[ DONE ]=========================
```
