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
oc new-app -f https://raw.githubusercontent.com/csantanapr/gogs/workshop/gogs-template.yaml --param=PROTOCOL=https --param=HOSTNAME=gogs-tools.$(oc get ingresses.config.openshift.io cluster -o template={{.spec.domain}}) -n tools
```

If using `https` above, then edit the Route in the `tools` namespace to configure the Route to use tls edge termination.
```yaml
spec:
  host: ${HOSTNAME}
  to:
    name: gogs
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Allow
```

Register a new user `toolkit` with password `toolkit`

### Configure Git Server

- Create new repo with name `gitops` under the account `toolkit` make it a public git repo. Then run the following scripts to create the branches `master`, `qa ` and `staging`
    ```
    GIT_PROTOCOL=https GIT_HOST=$(oc get route -n tools gogs --template='{{.spec.host}}') \
    ./scripts/01-git-gitops.sh
    ```
- Create new migration repo using one of the templates below, and  name the repository `app`, leave it public.
    - https://github.com/IBM/template-go-gin
    - https://github.com/IBM/template-node-typescript
    - https://github.com/IBM/template-java-spring

- Create user accounts (ie user1:user1, user2:user2) or allow users to register in git server.
    ```
    GIT_PROTOCOL=https GIT_HOST=$(oc get route -n tools gogs --template='{{.spec.host}}') ./scripts/02-git-users.sh
    ```

### Configure Toolkit

- Update Console Link for Git to point to gogs url
    ```
    GOGS_CONSOLE_URL=$(oc get route -n tools gogs --template='https://{{.spec.host}}')
    oc patch consolelink toolkit-sourcecontrol --type merge -p "{\"spec\": {\"href\": \"$GOGS_CONSOLE_URL\"}}"
    ```

- Configure tools namespace with gitops-cd-secret in the tools namespace
    ```bash
    NAMESPACE=tools

    oc delete secret gitops-cd-secret -n ${NAMESPACE} || true

    oc create secret -n tools generic gitops-cd-secret \
    --from-literal username=toolkit \
    --from-literal password=toolkit \
    -n ${NAMESPACE}


    oc label secret gitops-cd-secret group=catalyst-tools -n ${NAMESPACE}
    ```

- Configure `tools` namespace with `gitops-repo` configMap
    ```bash
    NAMESPACE=tools

    oc delete cm gitops-repo -n ${NAMESPACE} || true

    oc create cm gitops-repo \
    --from-literal parentdir="bash -c 'basename \${NAMESPACE} -dev'" \
    --from-literal host=$(oc get route -n tools gogs --template='{{.spec.host}}') \
    --from-literal branch=qa \
    --from-literal org=toolkit \
    --from-literal repo=gitops \
    -n ${NAMESPACE}

    oc label cm gitops-repo group=catalyst-tools -n ${NAMESPACE}
    ```

- Configure ArgoCD
Login into ArgoCD and create an application
```
name: toolkit
project: default
sync: Auto
git: http://gogs.tools:3000/toolkit/gitops.git
revision: master
path: /argoprojects
values: values.yaml
```


