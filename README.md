# Deploying a full mainnet DAPP-DSP using K8S
This helm chart will install an full mainnet DSP cluster (Syncd Mainnet API Node, DAPP DSP Services, IPFS Cluster)
## Getting started
### AWS
https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

### GCP
https://cloud.google.com/kubernetes-engine/docs/quickstart

## Deployment
### Run boostrap
```bash
docker run --rm -it -v $HOME/.kube/config:/root/.kube/config liquidapps/zeus-dsp-bootstrap 

# inside the container shell:
helm init
helm repo update

kubectl create serviceaccount --namespace kube-system tiller 
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller 
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

### Edit values.yaml (optional)
### Deploy
Restore from snapshot:
```bash
zeus deploy dapp-cluster dspaccount --key yourdspprivatekey
```
Or restore from full backup and replay:
```bash
zeus deploy dapp-cluster dspaccount --key yourdspprivatekey --full-replay=true 
```
Or resume after first restore:
```bash
zeus deploy dapp-cluster dspaccount --key yourdspprivatekey --snapshot=false
```

### Manually installing helm and zeus (alternative method)
#### Install helm
Download client from: https://docs.helm.sh/using_helm/#installing-helm
##### Ubuntu
```bash
sudo snap install helm --classic
```
Run:
```bash
helm init
helm update repo

kubectl create serviceaccount --namespace kube-system tiller 
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller 
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

```

#### Install zeus

https://github.com/liquidapps-io/zeus-cmd


#### Unpack release box
```bash
zeus unbox dapp-cluster-k8s
cd dapp-cluster-k8s
```

## Monitor restore and sync progress
```bash
kubectl logs -f dsp-nodeos-0 --all-containers
```

## Register a service package:
https://github.com/liquidapps-io/zeus-dapp-network/blob/master/README-DSP.md#register

