# ВМ

| Роль    | Hostname | IP (ens37, host-only) | vCPU | RAM |
|---------|----------|-----------------------|------|-----|
| master  | master   | 192.168.190.138       | 2    | 8GB |
| worker1 | worker1  | 192.168.190.140       | 2    | 8GB |
| worker2 | worker2  | 192.168.190.142       | 2    | 8GB |
| worker3 | worker3  | 192.168.190.144       | 2    | 8GB |


# 1. Подготовка нод

- выключаем ``swap``;
- модули `overlay`, `br_netfilter`;
- sysctl: `net.bridge.bridge-nf-call-iptables=1`, `net.ipv4.ip_forward=1`;
- установка containerd, `SystemdCgroup = true`;
- подключение apt-репо pkgs.k8s.io v1.30;
- установка `kubelet kubeadm kubectl` + `apt-mark hold`;
- уникальный hostname + общий `/etc/hosts`.

# 2. Инициализация master

```bash
sudo kubeadm init \
  --apiserver-advertise-address=192.168.190.138 \
  --pod-network-cidr=10.244.0.0/16 \
  --kubernetes-version=v1.30.14
```

kubeconfig:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

# 3. CNI Flannel

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

# 4. Присоединяем воркеры

На каждой ноде:

```bash
sudo kubeadm join 192.168.190.138:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

# Результат до обновления

```
$ kubectl get nodes -o wide
<см скриншоты>
```

## 5. Обновление master до v1.31.14

```bash
# подключить репо v1.31, обновить только kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.31.14-1.1
sudo apt-mark hold kubeadm

# план и применение
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.31.14

# drain
kubectl drain master --ignore-daemonsets --delete-emptydir-data

# kubelet/kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.31.14-1.1 kubectl=1.31.14-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# вернуть в строй
kubectl uncordon master
```

## 6. Обновление воркеров (по одному)

Для каждого worker:

```bash
# --- на master ---
kubectl drain workerN --ignore-daemonsets --delete-emptydir-data

# --- на workerN ---
# подключить репо v1.31
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.31.14-1.1
sudo apt-mark hold kubeadm

sudo kubeadm upgrade node

sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.31.14-1.1 kubectl=1.31.14-1.1
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# --- на master ---
kubectl uncordon workerN
```

## Результат после обновления

```
$ kubectl get nodes -o wide
<см. скриншоты>
```