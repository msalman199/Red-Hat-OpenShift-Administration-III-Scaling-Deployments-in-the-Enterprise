<div align="center">

# 📊 Lab 11: OpenShift Monitoring with Prometheus

![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![PromQL](https://img.shields.io/badge/PromQL-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)

</div>

---

## 📋 Table of Contents

- [🎯 Conclusion](#-conclusion)
- [🔑 Key Concepts](#-key-concepts)

---

## 🎯 Conclusion

Congratulations! You have successfully completed Lab 11: OpenShift Monitoring with Prometheus. Here's what you accomplished:

### ✅ Key Achievements

- **Installed Prometheus**: You deployed a complete Prometheus monitoring stack on OpenShift, including proper RBAC configuration and service accounts
- **Configured Metric Collection**: You set up Prometheus to automatically discover and scrape metrics from OpenShift cluster components, including API servers, nodes, pods, and services
- **Deployed Sample Applications**: You created sample applications with proper metric annotations to demonstrate how applications can expose metrics for Prometheus collection
- **Explored Prometheus UI**: You learned to navigate the Prometheus web interface, execute PromQL queries, and visualize time-series data
- **Implemented Service Discovery**: You configured Kubernetes service discovery to automatically find and monitor new targets as they are deployed
- **Set Up Alerting Rules**: You created basic alerting rules to monitor system health and application performance
- **Performed Troubleshooting**: You learned essential troubleshooting

---

## 🔑 Key Concepts

| Concept | Description |
|---|---|
| **Prometheus** | An open-source monitoring and time-series database system used to collect and query metrics |
| **RBAC (Role-Based Access Control)** | OpenShift/Kubernetes permission model used to grant Prometheus the access it needs to discover and scrape cluster resources |
| **Service Account** | An identity used by the Prometheus deployment to authenticate against the OpenShift API |
| **Service Discovery** | Prometheus's ability to automatically find and monitor new scrape targets as they are deployed |
| **Metric Annotations** | Labels on pods/services that tell Prometheus how and where to scrape metrics from an application |
| **PromQL** | Prometheus's query language, used to explore and visualize time-series metric data |
| **Alerting Rule** | A condition defined in Prometheus that triggers a notification when system or application health crosses a threshold |

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blue?style=for-the-badge)

</div>
