# Deploying a full DSP using K8S

## Getting started
### AWS
https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

### GCP
https://cloud.google.com/kubernetes-engine/docs/quickstart

## Deployment using helm
### Install helm

Download client from: https://docs.helm.sh/using_helm/#installing-helm
#### Ubuntu
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
### Run boostrap
#### By install zeus and unboxing the release:
https://github.com/liquidapps-io/zeus-cmd
```bash
zeus unbox dapp-cluster-k8s
cd dapp-cluster-k8s
```
#### or by using container
docker run --entrypoint /bin/sh --rm -it -v `which aws-iam-authenticator`:/bin/aws-iam-authenticator -v $HOME/.kube/config:/root/.kube/config liquidapps/zeus-dsp-bootstrap 


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