#!/bin/bash

#longhorn install
echo "[TASK 1] install longhorn"
helm repo add longhorn https://charts.longhorn.io
helm install my-longhorn longhorn/longhorn --version 1.7.2 -n longhorn --create-namespace -f /opt/install/helm/longhorn/longhorn-values.yaml

#minio install
echo "[TASK 2] install minio"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-minio bitnami/minio --version 14.8.5 -n minio --create-namespace -f /opt/install/helm/minio/minio-values.yaml


#ingress-nignx install
echo "[TASK 3] install ingress-nginx"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-ingress-nginx ingress-nginx/ingress-nginx --version 4.11.3 -n ingress-nginx --create-namespace

#metallb install
echo "[TASK 4] install metallb"
helm repo add metallb https://metallb.github.io/metallb
# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
helm install my-metallb metallb/metallb --version 0.14.8 -n metallb-system --create-namespace
kubectl apply -f /opt/install/helm/metallb/metallb-config.yaml

#metrics-server
echo "[TASK 5] install metric-server"
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install my-metrics-server metrics-server/metrics-server --version 3.12.2 -n metrics-server --create-namespace
kubectl patch deployment -n metrics-server my-metrics-server --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

#postgresql install
echo "[TASK 6] install postgresql"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-postgresql bitnami/postgresql --version 16.2.1 -n postgresql --create-namespace -f /opt/install/helm/postgresql/postgresql-values.yaml

#nexus install
echo "[TASK 7] install nexus3"
helm repo add stevehipwell https://stevehipwell.github.io/helm-charts/
helm install my-nexus3 stevehipwell/nexus3 --version 5.4.0 -n nexus --create-namespace -f /opt/install/helm/nexus/nexus-values.yaml

#sonarqube install
echo "[TASK 8] install sonarqube"
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm install my-sonarqube sonarqube/sonarqube --version 10.7.0+3598 -n sonarqube --create-namespace -f /opt/install/helm/sonarqube/sonarqube-values.yaml

#jenkins install
echo "[TASK 9] install jenkins"
helm repo add jenkinsci https://charts.jenkins.io/
helm install my-jenkins jenkinsci/jenkins --version 5.7.12 -n jenkins --create-namespace -f /opt/install/helm/jenkins/jenkins-values.yaml

#Argocd install
echo "[TASK 10] install argocd"
helm repo add argo https://argoproj.github.io/argo-helm
helm install my-argo-cd argo/argo-cd --version 7.7.3 -n argocd --create-namespace -f /opt/install/helm/argocd/argocd-values.yaml

#mattermost & redmine install
echo "[TASK 11] install mattermost"
helm repo add mattermost https://helm.mattermost.com
helm install my-mattermost-team-edition mattermost/mattermost-team-edition --version 6.6.66 -n mattermost --create-namespace -f /opt/install/helm/mattermost/mattermost-values.yaml

echo "[TASK 12] install redmine"
helm install my-redmine bitnami/redmine --version 32.0.1 -n redmine --create-namespace -f /opt/install/helm/redmine/redmine-values.yaml
