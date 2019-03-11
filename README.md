# Deploy & Register a full mainnet DAPP-DSP using K8S
This helm chart will install an full mainnet DSP cluster (Syncd Mainnet API Node, DAPP DSP Services, IPFS Cluster)

This chart is using:
- https://github.com/helm/charts/tree/master/stable/ipfs
- https://github.com/liquidapps-io/eosio-node-k8s-helm

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
For GCP:
```bash
docker run -v /google/google-cloud-sdk:/google/google-cloud-sdk \
    --entrypoint /bin/bash --rm -it -v $HOME/.kube/config:/root/.kube/config \
    liquidapps/zeus-dsp-bootstrap 
```

Others:
```bash
docker run --entrypoint /bin/bash --rm -it -v $HOME/.kube/config:/root/.kube/config \
    liquidapps/zeus-dsp-bootstrap 
```

Inside the container shell:
```bash

# create tiller service account
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# install helm on cluster
helm init --service-account tiller
helm repo update
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


### Get your API endpoint 
AWS:
```bash
MYAPI=$(kubectl get service dsp-dspnode -o jsonpath="{.status.loadBalancer.ingress[?(@.hostname)].hostname}"):3115
echo $MYAPI
```

GCP:
```bash
MYAPI=$(kubectl get service dsp-dspnode -o jsonpath="{.status.loadBalancer.ingress[0].ip}"):3115
echo $MYAPI
```




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
        }
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

**Warning: packages are read only and can't be removed yet.**

```bash

zeus register dapp-service-provider-package \
    ipfs dspaccount package1 \
    --key yourdspprivatekey \
    --min-stake-quantity "10.0000" \
    --package-period 86400 \
    --quota "1.0000" \
    --network mainnet \
    --api-endpoint $MYAPI \
    --package-json-uri https://acme-dsp.com/package1.dsp-package.json
```

replace https://api.acme-dsp.com with the service endpoint from 

For more options:
```bash
zeus register dapp-service-provider-package --help 
```

#### Modify Package metadata:
Currently only package_json_uri & api_endpoint are modifiable.
To modify package metadata: use the "modifypkg" action of the dappservices contract. (https://bloks.io/account/dappservices)

## Test your DSP
### Upload a contract that uses vram 

(https://github.com/liquidapps-io/vgrab)

```bash
cleos set abi mycoldtoken1 vgrab.abi
cleos set code mycoldtoken1 vgrab.wasm
PKEY=mycoltoken1_active_public_key
PERMISSIONS=`echo "{\"threshold\":1,\"keys\":[{\"key\":\"$PKEY\",\"weight\":1}],\"accounts\":[{\"permission\":{\"actor\":\"mycoltoken1\",\"permission\":\"eosio.code\"},\"weight\":1}]}"`
cleos set account permission mycoldtoken1 active $PERMISSIONS owner -p mycoltoken1
cleos push action mycoldtoken1 create '["mycoltoken1","100000000.0000 VTST"]}' -p mycoltoken1
```

### Select your service package and stake towards you DSP

```bash
cleos push action dappservices selectpkg '["mycoltoken1","dspaccount","ipfsservice1","package1"]}' -p mycoltoken1
cleos push action dappservices stake '["mycoltoken1","dspaccount","ipfsservice1","1.0000 DAPP"]}' -p mycoltoken1
cleos set account permission mycoldtoken1 dsp '{"threshold":1,"keys":[],"accounts":[{"permission":{"actor":"dspaccount","permission":"active"},"weight":1}]}' owner -p mycoltoken1
```

### Test your contract and DSP
```bash
cleos -u $MYAPI push action mycoldtoken1 coldissue '["talmuskaleos","1.0000 VTST","hello world"]' -p mycoltoken1
```

### Check logs
```
kubectl logs dsp-dspnode-0 -c dspnode-ipfs-svc
```
### look for "xcommit" and "xcleanup" actions for your contract:

https://bloks.io/account/mycoltoken1

### Claim your DAPP daily rewards:
```bash
cleos push action dappservices claimrewards '["dspaccount"]' -p dspaccount
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
helm init --service-account tiller
helm update repo
```

#### Install zeus
https://github.com/liquidapps-io/zeus-cmd
#### Unpack release box
```bash
zeus unbox dapp-cluster-k8s
cd dapp-cluster-k8s
```
