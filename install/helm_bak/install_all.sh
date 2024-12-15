#!/bin/bash

#minio install
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-minio bitnami/minio --version 14.8.5 -n minio --create-namespace -f /opt/install/helm/minio/minio-values.yaml

#longhorn install
helm repo add longhorn https://charts.longhorn.io
helm install my-longhorn longhorn/longhorn --version 1.7.2 -n longhorn --create-namespace -f /opt/install/helm/longhorn/longhorn-values.yaml

#ingress-nignx install
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-ingress-nginx ingress-nginx/ingress-nginx --version 4.11.3 -n kube-system

#metallb install
helm repo add metallb https://metallb.github.io/metallb
helm install my-metallb metallb/metallb --version 0.14.8 -n kube-system
# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

cat >> /opt/install/helm/metallb/metallb-config.yaml<<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: kube-system
spec:
  addresses:
  - 172.16.16.240-172.16.16.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: metallb-12adv
  namespace: kube-system
EOF

kubectl apply -f /opt/install/helm/metallb/metallb-config.yaml > /dev/null 2>&1


#metrics-server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install my-metrics-server metrics-server/metrics-server --version 3.12.2 -n metrics-server --create-namespace
kubectl patch deployment -n metrics-server my-metrics-server --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

#nexus install
helm repo add stevehipwell https://stevehipwell.github.io/helm-charts/
helm install my-nexus3 stevehipwell/nexus3 --version 5.4.0 -n nexus --create-namespace -f /opt/install/helm/nexus/nexus-values.yaml

#sonarqube install
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm install my-sonarqube sonarqube/sonarqube --version 10.7.0+3598 -n sonarqube --create-namespace -f /opt/install/helm/sonarqube/sonarqube-values.yaml

#jenkins install
helm repo add jenkinsci https://charts.jenkins.io/
helm install my-jenkins jenkinsci/jenkins --version 5.7.12 -n jenkins --create-namespace -f /opt/install/helm/jenkins/jenkins-values.yaml

#Argocd install
helm repo add argo https://argoproj.github.io/argo-helm
helm install my-argo-cd argo/argo-cd --version 7.7.3 -n argocd --create-namespace -f /opt/install/helm/argocd/argocd-values.yaml

#loki install
helm repo add grafana https://grafana.github.io/helm-charts
helm install my-loki grafana/loki --version 6.20.0 -n loki --create-namespace -f /opt/install/helm/loki/loki-values.yaml

#tempo install
helm repo add grafana https://grafana.github.io/helm-charts
helm install my-tempo grafana/tempo --version 1.14.0 -n tempo --create-namespace -f /opt/install/helm/tempo/tempo-values.yaml

#mimir-install
helm repo add grafana https://grafana.github.io/helm-charts
helm install my-mimir-distributed grafana/mimir-distributed --version 5.5.1 -n mimir --create-namespace -f /opt/install/helm/mimir/mimir-values.yaml

#alloy install
helm repo add grafana https://grafana.github.io/helm-charts
helm install my-alloy grafana/alloy --version 0.10.0 -n alloy --create-namespace -f /opt/install/helm/alloy/alloy-values.yaml

#grafana install
helm repo add grafana https://grafana.github.io/helm-charts
helm install my-grafana grafana/grafana --version 8.6.0 -n grafana --create-namespace -f /opt/install/helm/grafana/grafana-values.yaml

#mattermost & redmine install
helm install my-postgresql bitnami/postgresql --version 16.2.1 -n postgresql --create-namespace

export POSTGRES_PASSWORD=$(kubectl get secret --namespace postgresql my-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

kubectl run my-postgresql-client --rm --tty -i --restart='Never' --namespace postgresql --image docker.io/bitnami/postgresql:17.1.0-debian-12-r0 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host my-postgresql -U postgres -d postgres -p 5432 < /opt/install/helm/postgresql/schema.sql

helm install my-mattermost-team-edition mattermost/mattermost-team-edition --version 6.6.66 -n mattermost --create-namespace -f /opt/install/helm/mattermost/mattermost-values.yaml

helm install my-redmine bitnami/redmine --version 32.0.1 -n redmine --create-namespace -f /opt/install/helm/redmine/redmine-values.yaml
