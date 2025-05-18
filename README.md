[k8s-iperf](https://github.com/sempernow/k8s-iperf)


>Bandwidth test of your K8s Cluster (Pod) Network.

- Performs two measurements:
    - Same-node case
    - Cross-node case
- Throughput is expected to vary by host network,  
  CNI provider, their configurations,  
  and adjacent network-traffic conditions.

## Usage

```bash
bash k8s-iperf.sh
```

### Example report

```plaintext
=======================================================
🚀  Bandwidth test of K8s Pod Network using iperf3


🚧 === Create and set context to a per-run Namespace …
namespace/test-iperf3-1ofijkd created
NAME                  STATUS   AGE
test-iperf3-1ofijkd   Active   1s
Context "kubernetes-admin@lime" modified.

🚧 === Traffic port: 5555

🚧 === Creating the server …
pod/server created
Awaiting Node and IP status of Pod 'server' …
Awaiting Node and IP status of Pod 'server' …
✅ === Server pod 'server' running at node 'a1'.
Next, run client pods 'client' sequentially (Same-node, Cross-node) …

📊 === Same-node (a1-a1) traffic between server 'server@a1' and client 'client@a1' [Pod@Node] …
...
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  28.0 GBytes  24.1 Gbits/sec  4447             sender
[  5]   0.00-10.00  sec  28.0 GBytes  24.1 Gbits/sec                  receiver

iperf Done.
pod "client" deleted

📊 === Cross-node (a1-a2) traffic between server 'server@a1' and client 'client@a2' [Pod@Node] …
...
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  4.85 GBytes  4.17 Gbits/sec  845             sender
[  5]   0.00-10.01  sec  4.85 GBytes  4.16 Gbits/sec                  receiver

iperf Done.
pod "client" deleted

🚧 === Teardown
Context "kubernetes-admin@lime" modified.
namespace "test-iperf3-1ofijkd" deleted
🚧 === Done
```

---
