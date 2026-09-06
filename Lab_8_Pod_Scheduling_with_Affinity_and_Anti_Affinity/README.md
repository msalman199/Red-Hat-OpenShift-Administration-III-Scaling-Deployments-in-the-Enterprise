<div align="center">

# 🎯 Pod Scheduling with Affinity and Anti-Affinity

![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Pod Scheduling](https://img.shields.io/badge/Pod%20Scheduling-4B0082?style=for-the-badge&logo=kubernetes&logoColor=white)
![High Availability](https://img.shields.io/badge/High%20Availability-003366?style=for-the-badge&logo=cloudflare&logoColor=white)

*Controlling pod placement in OpenShift using node affinity, pod affinity, and pod anti-affinity rules*

</div>

---

## 📑 Table of Contents

- [🏁 Conclusion](#-conclusion)
- [🧠 Key Concepts](#-key-concepts)

---

## 🏁 Conclusion

In this lab, you have successfully:

### 🏆 Key Achievements

- 🎯 **Mastered Node Affinity** — Learned to control pod placement on specific nodes using both required and preferred affinity rules
- 🔀 **Implemented Pod Anti-Affinity** — Created high-availability deployments by ensuring pods are distributed across different nodes
- 🤝 **Configured Pod Affinity** — Co-located related pods to improve performance and reduce network latency
- 🧪 **Tested Complex Scenarios** — Combined multiple affinity rules and handled scheduling failures
- 📊 **Developed Monitoring Skills** — Created tools to validate and troubleshoot scheduling behavior

### 💡 Why This Matters

Pod scheduling with affinity and anti-affinity is crucial for:

- 🛡️ **High Availability** — Ensuring application resilience by distributing pods across failure domains
- ⚡ **Performance Optimization** — Co-locating related services to reduce latency
- 💰 **Resource Efficiency** — Placing workloads on nodes with appropriate hardware characteristics
- 📋 **Compliance Requirements** — Meeting regulatory or organizational constraints for data locality

These skills are essential for Red Hat OpenShift Administration and enterprise Kubernetes deployments, where proper pod scheduling directly impacts application performance, availability, and operational costs. Understanding these concepts prepares you for real-world scenarios where workload placement decisions can make the difference between a successful and failed deployment.

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| **Node Affinity** | Scheduling rules that attract pods toward nodes matching specified labels |
| **Pod Affinity** | Scheduling rules that co-locate pods with other pods matching specified criteria |
| **Pod Anti-Affinity** | Scheduling rules that spread pods apart from other pods matching specified criteria |
| **Required vs. Preferred Rules** | "Required" (hard) rules must be met for scheduling; "preferred" (soft) rules are best-effort |
| **High Availability / Failure Domains** | Distributing pods across nodes, zones, or racks so a single failure doesn't take down an application |
| **Scheduling Failures & Troubleshooting** | Diagnosing why a pod remains unscheduled due to unsatisfiable affinity/anti-affinity constraints |

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blue?style=for-the-badge)

</div>
