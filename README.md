# Deploy & Register a full mainnet DAPP-DSP using K8S
This helm chart will install an full mainnet DSP cluster (Syncd Mainnet API Node, DAPP DSP Services, IPFS Cluster)

## Minimum cluster requirements

* CPU: 4x2.2GHz Cores
* Memory: 64GB memory
* Network: 1 GigE
* Disk: 1TB

## Getting started
### AWS
https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

### GCP - Untested
https://cloud.google.com/kubernetes-engine/docs/quickstart

## Deployment
### Make sure kubectl is installed and configured and nodes are running
```
kubectl get nodes
```
### Run boostrap container 
```bash
docker run --rm -it -v $HOME/.kube/config:/root/.kube/config \
    liquidapps/zeus-dsp-bootstrap 
```

Inside the container shell:
```bash
# install helm on cluster
helm init
helm repo update
# patch helm
kubectl create serviceaccount --namespace kube-system tiller 
kubectl create clusterrolebinding tiller-cluster-rule \
    --clusterrole=cluster-admin --serviceaccount=kube-system:tiller 
kubectl patch deploy --namespace kube-system tiller-deploy \
    -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
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

### Monitor restore and sync progress 
```bash
kubectl logs -f dsp-nodeos-0 --all-containers
```
*It takes a couple of hours to restore from the blockchain backups depending on internet connection and hardware performance*

## Register
### Prepare and host dsp.json 
```JSON
{
    "name": "acme DSP",
    "website": "https://acme-dsp.com",
    "code_of_conduct":"https://...",
    "ownership_disclosure" : "https://...",
    "email":"dsp@acme-dsp.com",
    "branding":{
      "logo_256":"https://....",
      "logo_1024":"https://....",
      "logo_svg":"https://...."
    },
    "location": {
      "name": "Atlantis",
      "country": "ATL",
      "latitude": 2.082652,
      "longitude": 1.781132
    },
    "social":{
      "steemit": "",
      "twitter": "",
      "youtube": "",
      "facebook": "",
      "github":"",
      "reddit": "",
      "keybase": "",
      "telegram": "",
      "wechat":""      
    }
    
}

```
### Prepare and host dsp-package.json 
```JSON
{
    "name": "Package 1",
    "description": "Best for low vgrabs",
    "dsp_json_uri": "https://acme-dsp.com/dsp.json",
    "logo":{
      "logo_256":"https://....",
      "logo_1024":"https://....",
      "logo_svg":"https://...."
    },
    "service_level_agreement": {
        "availability":{
            "uptime_9s": 5
        },
        "performance":{
            "95": 500,
        },
    },
    "pinning":{
        "ttl": 2400,
        "public": false
    },
    "locations":[
        {
          "name": "Atlantis",
          "country": "ATL",
          "latitude": 2.082652,
          "longitude": 1.781132
        }
    ]
}
```

### Register Package
```bash
zeus register dapp-service-provider-package \
    ipfs dspaccount package1 \
    --key yourdspprivatekey \
    --min-stake-quantity "1.0000" \
    --package-period 3600 \
    --quota "0.1000" \
    --api-endpoint https://api.acme-dsp.com \
    --package-json-uri https://acme-dsp.com/package1.dsp-package.json
```

## Test your DSP
```bash
[TBD]
```

## Misc:
### Manually installing helm and zeus (boostrap container alternative)
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
