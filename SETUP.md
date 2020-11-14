## Setup Workshop

## Setup Workstation Shell

Use the IBM Cloud Shell

- Verify `oc` CLI is version 4.5+
```
oc version --client
```

- Install nodejs with nvm
```
rm -rf ~/.npm
mkdir ~/.npm
export PATH=~/.npm/bin:$PATH
npm config set prefix ~/.npm
```

- Install the IBM Cloud Toolkit CLI
```
npm i -g @ibmgaragecloud/cloud-native-toolkit-cli
```

### Setup OpenShift Cluster

Create a cluster using cloudnativetoolit
https://cloudnativetoolkit.dev/getting-started-day-0/plan-installation/multi-cloud

Get a free cluster for a couple or hours.
https://developer.ibm.com/openlabs/openshift

TODO: script this step.
Setup user accounts for the openshift cluster using name name and password (ie user1:user1, user2:user2, etc..)


### Install the Cloud Native Toolkit

https://cloudnativetoolkit.dev/getting-started-day-0/install-toolkit/quick-install

### Install Git Server

TODO: script this step.
If you are using a cluster with valid ssl certs for apps, the use `--param=PROTOCOL=https` if using cluster that uses self-sign certs like crc then don't pass this parameter to use `http` for the git server.

```bash
oc new-app -f https://raw.githubusercontent.com/csantanapr/gogs/workshop/gogs-template-ephemeral.yaml --param=HOSTNAME=gogs-tools.$(oc get ingresses.config.openshift.io cluster -o template={{.spec.domain}}) -n tools
```

If using `https` above, then edit the Route in the `tools` namespace to configure the Route to use tls edge termination.

Register a new user `toolkit` with password `toolkit`

### Configure Git Server

TODO: script this step.
- Create new migration repo with name `gitops` from git url `TODO` provided url, under the account `toolkit` leave default public and no mirror.
- Create new migration repo with name `app` from git url `TODO` provided url, under the account `toolkit` leave default public and no mirror.
- Create user accounts (ie user1:user1, user2:user2) or allow users to register in git server.

### Configure Toolkit

- Configure tools namespace with gitops-cd-secret in the tools namespace
```bash
oc delete secret -n tools gitops-cd-secret || true

oc create secret -n tools generic gitops-cd-secret --from-literal username=toolkit --from-literal password=toolkit

oc label secret -n tools gitops-cd-secret group=catalyst-tools
```

- Configure ArgoCD
Login into ArgoCD and create an application
```
name: toolkit
project: default
sync: Auto
git: http://gogs.tools:3000/toolkit/gitops.git
revision: master
path: /
values: values.yaml
```


