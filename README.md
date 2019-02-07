# eosio-testnet - A Helm chart to bootstrap an EOSIO Testnet on Kubernetes

This is a Helm chart to create a EOSIO Testnet on Kubernetes.  It exposes a single HTTP endpoint for cleos to connect to. 


## Getting Started
If you are unfamilar with kubernetes and just want to to setup the Testnet on Google Kubernetes Engine with defaults, follow the steps on Google Cloud Shell 

```bash
$ CLUSTER_NAME=eosionet
$ gcloud container clusters create $CLUSTER_NAME --zone us-central1-b --num-nodes=4 --enable-autoupgrade
$ curl -L https://git.io/vAgz3 | bash  ### install Helm and Tiller
$ git clone https://github.com/huangminghuang/eosio-testnet.git
$ cd eosio-testnet
$ helm install . --name eosio
NAME:   eosio
LAST DEPLOYED: Wed Oct  3 16:34:00 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                 DATA  AGE
eosio-eosio-testnet  4     0s

==> v1/Service
NAME           TYPE          CLUSTER-IP    EXTERNAL-IP  PORT(S)            AGE
eosio-bios     ClusterIP     10.7.244.201  <none>       8888/TCP,9876/TCP  0s
eosio-nodeos   LoadBalancer  10.7.253.91   <pending>    8888:31051/TCP     0s
eosio-service  ClusterIP     None          <none>       8888/TCP,9876/TCP  0s

==> v1beta2/Deployment
NAME        DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
eosio-bios  1        1        1           0          0s

==> v1/StatefulSet
NAME          DESIRED  CURRENT  AGE
eosio-nodeos  4        1        0s

==> v1/Pod(related)
NAME                         READY  STATUS             RESTARTS  AGE
eosio-bios-56b5fb5fd7-ngt9z  0/1    ContainerCreating  0         0s
eosio-nodeos-0               0/1    ContainerCreating  0         0s


NOTES:
1. Get the application URL by running these commands:

NOTE: It may take a few minutes for the LoadBalancer IP to be available.
     You can watch the status of by running 'kubectl get svc -w eosio-nodeos'
export SERVICE_IP=$(kubectl get svc --namespace default eosio-nodeos -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo http://$SERVICE_IP:8888
```

The bootstraping process may take a few minutes to be ready. You can examine whether all the pods are ready
```bash
$ kubectl get pods
NAME                          READY     STATUS    RESTARTS   AGE
eosio-bios-644df44b65-g6dg8   1/1       Running   0          3m
eosio-nodeos-0                1/1       Running   0          3m
eosio-nodeos-1                1/1       Running   0          48s
eosio-nodeos-2                1/1       Running   0          30s
eosio-nodeos-3                1/1       Running   0          17s
```

To get the IP address for cleos to connect to
```bash
kubectl get svc --namespace default eosio-nodeos -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Chart Configuration

The following table lists the configurable parameters of the chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
replicaCount | total number of nodeos pods (excluding the BIOS node) on the cluster  | 4
producerCount | number of producer nodeos pods on the cluster  | 4
service.port | the TCP port for the exposed HTTP endpoint | 8888
args | the argumenets passed to all nodeos processes | ["--max-transaction-time", "30", "--abi-serializer-max-time-ms", "15000"]
genesis.initial_timestamp | initial timestamp for genesis node | "2018-09-12T16:21:19.132"
genesis.signatureProvider |  the public and private key pair for genesis node | EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
genesis.initial_configuration | genesis initial configuration | 
persistence.enabled | whether to enable persistence for nodeos states | false
persistence.size | the size of persistence disk if enabled | 100Gi
producerKeys | the list of private keys for producers separated by comma | "" 