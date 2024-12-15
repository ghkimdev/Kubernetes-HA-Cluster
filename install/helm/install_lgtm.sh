#loki install
echo "[TASK 10] install loki"
helm repo add grafana https://grafana.github.io/helm-charts
helm install my-loki grafana/loki --version 6.20.0 -n loki --create-namespace -f /opt/install/helm/loki/loki-values.yaml

#tempo install
echo "[TASK 11] install tempo"
helm install my-tempo grafana/tempo --version 1.14.0 -n tempo --create-namespace -f /opt/install/helm/tempo/tempo-values.yaml

#mimir-install
echo "[TASK 12] install mimir"
helm install my-mimir-distributed grafana/mimir-distributed --version 5.5.1 -n mimir --create-namespace -f /opt/install/helm/mimir/mimir-values.yaml

#alloy install
echo "[TASK 13] install alloy"
helm install my-alloy grafana/alloy --version 0.10.0 -n alloy --create-namespace -f /opt/install/helm/alloy/alloy-values.yaml

#grafana install
echo "[TASK 14] install grafana"
helm install my-grafana grafana/grafana --version 8.6.0 -n grafana --create-namespace -f /opt/install/helm/grafana/grafana-values.yaml


