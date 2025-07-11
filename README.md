# [`k8s-iperf3.sh`](k8s-iperf.sh) | [`sempernow/k8s-iperf`](https://github.com/sempernow/k8s-iperf "GitHub.com")

>Bandwidth test of your K8s Cluster (Pod) Network.

- Performs two measurements:
    - Same-node case
    - Cross-node case
- Throughput is expected to vary by host network,  
  CNI provider, their configurations,  
  and adjacent network-traffic conditions.
- Uses a hardened containerized `iperf3`

## Usage

```bash
bash k8s-iperf.sh
```
- Requires `kubectl` configured to your cluster.

---
