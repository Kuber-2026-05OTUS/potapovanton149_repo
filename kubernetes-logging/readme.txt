 Я не использую managed k8s в Yandex cloud, а использу свой локальный кластер с тремя worker и тремя cp.

 Согласно заданию на третий воркер был назначен taint и лейбл в типоп infra


Посмотрим лейблы:

➜  ~ kubectl get node -o wide --show-labels
NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP       EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION             CONTAINER-RUNTIME    LABELS
k8s-cp1   Ready    control-plane   37d   v1.36.3   192.168.190.131   <none>        Ubuntu 26.04 LTS   7.0.0-29-generic (amd64)   containerd://2.3.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-cp1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
k8s-cp2   Ready    control-plane   37d   v1.36.3   192.168.190.132   <none>        Ubuntu 26.04 LTS   7.0.0-29-generic (amd64)   containerd://2.3.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-cp2,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
k8s-cp3   Ready    control-plane   37d   v1.36.3   192.168.190.133   <none>        Ubuntu 26.04 LTS   7.0.0-29-generic (amd64)   containerd://2.3.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-cp3,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
k8s-w1    Ready    <none>          37d   v1.36.3   192.168.190.134   <none>        Ubuntu 26.04 LTS   7.0.0-29-generic (amd64)   containerd://2.3.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,homework=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-w1,kubernetes.io/os=linux
k8s-w2    Ready    <none>          37d   v1.36.3   192.168.190.135   <none>        Ubuntu 26.04 LTS   7.0.0-29-generic (amd64)   containerd://2.3.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,homework=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-w2,kubernetes.io/os=linux
k8s-w3    Ready    <none>          37d   v1.36.3   192.168.190.136   <none>        Ubuntu 26.04 LTS   7.0.0-29-generic (amd64)   containerd://2.3.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,homework=true,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-w3,kubernetes.io/os=linux,node-role=infra


Посмотрим тейнты:

➜  ~ kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
NAME      TAINTS
k8s-cp1   [map[effect:NoSchedule key:node-role.kubernetes.io/control-plane]]
k8s-cp2   [map[effect:NoSchedule key:node-role.kubernetes.io/control-plane]]
k8s-cp3   [map[effect:NoSchedule key:node-role.kubernetes.io/control-plane]]
k8s-w1    <none>
k8s-w2    <none>
k8s-w3    [map[effect:NoSchedule key:node-role value:infra]]



Так как кластре развенут локально, то вместо s3 развернем MinIO (см. minio-values.yaml)


Сама реализация задания находится в:
- grafana-values.yaml
- loki-values.yaml
- promtail-values.yaml


Установка:

# Подтягииваем репозитории:

helm repo add grafana https://grafana.github.io/helm-charts
helm repo add minio https://charts.min.io/
helm repo update

# установка MinIO:

helm install minio minio/minio \
  --namespace storage \
  --create-namespace \
  -f minio-values.yaml

# установка Loki:

helm install loki grafana/loki \
  --namespace loki \
  --create-namespace \
  -f loki-values.yaml

# установка Promtail:

helm install promtail grafana/promtail \
  --namespace loki \
  -f promtail-values.yaml

# установка Grafana:
helm install grafana grafana/grafana \
  --namespace grafana \
  --create-namespace \
  -f grafana-values.yaml



# Смотрим все поды

➜  ~ kubectl get pods -A | grep -E "loki|promtail|grafana|minio"
grafana              grafana-5d667f76b6-gr788                                  1/1     Running            0                 91m
loki                 loki-0                                                    2/2     Running            0                 80m
loki                 loki-1                                                    2/2     Running            0                 80m
loki                 loki-canary-gmfjc                                         1/1     Running            0                 81m
loki                 loki-canary-nthqk                                         1/1     Running            0                 81m
loki                 promtail-4vd59                                            1/1     Running            0                 82m
loki                 promtail-9zz6s                                            1/1     Running            0                 82m
loki                 promtail-cpp82                                            1/1     Running            0                 82m
loki                 promtail-pqcm9                                            1/1     Running            0                 82m
loki                 promtail-v9kdn                                            1/1     Running            0                 82m
loki                 promtail-xwbz5                                            1/1     Running            0                 82m
monitoring           prometheus-operator-grafana-5666d664f4-fn772              3/3     Running            3 (26h ago)       13d
storage              minio-5d8c8bb98c-smbl9                                    1/1     Running            0                 25h


# Смотрим сервисы 

➜  ~ kubectl get svc -n loki
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
loki              ClusterIP   10.233.12.255   <none>        3100/TCP,9095/TCP   82m
loki-canary       ClusterIP   10.233.41.158   <none>        3500/TCP            82m
loki-headless     ClusterIP   None            <none>        3100/TCP            82m
loki-memberlist   ClusterIP   None            <none>        7946/TCP            82m
➜  ~ kubectl get svc -n grafana
NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
grafana   NodePort   10.233.31.202   <none>        80:30300/TCP   92m
➜  ~ kubectl get svc -n storage
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
minio           NodePort    10.233.40.144   <none>        9000:32000/TCP   25h
minio-console   ClusterIP   10.233.52.228   <none>        9001/TCP         25h


Также подтверждение работы см. на скриншот.png

