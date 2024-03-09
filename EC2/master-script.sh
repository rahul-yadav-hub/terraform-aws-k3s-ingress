#!/bin/bash

apt-get update -y
apt-get upgrade -y

local_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
provider_id="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

CUR_HOSTNAME=$(cat /etc/hostname)
NEW_HOSTNAME=$instance_id

hostnamectl set-hostname $NEW_HOSTNAME
hostname $NEW_HOSTNAME
sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.24.17+k3s1 K3S_TOKEN=coIeS98V5UxzKYTLX0Uzzd4pkxfPSwBxiCUFtUm1sURd66mnZlT3uhk sh -s - --cluster-init --node-ip $local_ip --advertise-address $local_ip  --kubelet-arg="cloud-provider=external" --flannel-backend=none  --disable-cloud-controller --disable=servicelb --disable=traefik --write-kubeconfig-mode 644 --kubelet-arg="provider-id=aws:///$provider_id"

sleep 15s

kubectl apply -f https://github.com/aws/aws-node-termination-handler/releases/download/v1.13.3/all-resources.yaml
kubectl apply -f https://raw.githubusercontent.com/rahul-yadav-hub/K3s-aws/main/aws/rbac.yml
kubectl apply -f https://raw.githubusercontent.com/rahul-yadav-hub/K3s-aws/main/aws/aws-cloud-controller-manager-daemonset.yml

sleep 10s

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sleep 10s

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

sleep 10s

git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v3.4.0
cd kubernetes-ingress

sed -i '/aws-load-balancer-type/c\    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"' /kubernetes-ingress/deployments/service/loadbalancer-aws-elb.yaml
sed -i '/aws-load-balancer-nlb-target-type/c\    service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"' /kubernetes-ingress/deployments/service/loadbalancer-aws-elb.yaml

kubectl apply -f deployments/common/ns-and-sa.yaml
kubectl apply -f deployments/rbac/rbac.yaml
kubectl apply -f examples/shared-examples/default-server-secret/default-server-secret.yaml
kubectl apply -f deployments/common/nginx-config.yaml
kubectl apply -f deployments/common/ingress-class.yaml
kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v3.4.0/deploy/crds.yaml
kubectl apply -f deployments/deployment/nginx-ingress.yaml
kubectl apply -f deployments/service/loadbalancer-aws-elb.yaml
echo 'kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-config
  namespace: nginx-ingress
data:
  proxy-protocol: "True"
  real-ip-header: "proxy_protocol"
  set-real-ip-from: "0.0.0.0/0"' > deployments/common/nginx-config.yaml

kubectl apply -f deployments/common/nginx-config.yaml

sleep 30s

sync; echo 3 > /proc/sys/vm/drop_caches