## Setup Workshop

## Setup Workstation Shell

Use the IBM Cloud Shell

1. Verify `oc` CLI is version 4.5+
    ```bash
    oc version --client
    ```
2. Install nodejs with nvm
    ```bash
    rm -rf ~/.npm
    mkdir ~/.npm
    export PATH=~/.npm/bin:$PATH
    npm config set prefix ~/.npm
    ```
3. Install the IBM Cloud Toolkit CLI
    ```bash
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

Deploy Gogs Git server

```bash
oc new-app -f https://raw.githubusercontent.com/csantanapr/gogs/workshop/gogs-template.yaml --param=PROTOCOL=https --param=HOSTNAME=gogs-tools.$(oc get ingresses.config.openshift.io cluster -o template={{.spec.domain}}) -n tools
```

### Configure Git Server

1. Login into Git Server and register as admin with username `toolkit` with password `toolkit`
1. Create new repo with name `gitops` under the account `toolkit` make it a public git repo. Then run the following scripts to create the branches `master`, `qa ` and `staging`
    ```
    GIT_PROTOCOL=https GIT_HOST=$(oc get route -n tools gogs --template='{{.spec.host}}') \
    ./scripts/01-git-gitops.sh
    ```
1. Create new migration repo using one of the templates below, and  name the repository `app`, leave it public.
    - https://github.com/IBM/template-go-gin
    - https://github.com/IBM/template-node-typescript
    - https://github.com/IBM/template-java-spring

1. Create user accounts (ie user1:user1, user2:user2) or allow users to register in git server.
    ```
    GIT_PROTOCOL=https GIT_HOST=$(oc get route -n tools gogs --template='{{.spec.host}}') ./scripts/02-git-users.sh
    ```

### Configure Toolkit

1. Update Console Link for Git to point to gogs url
    ```bash
    GOGS_CONSOLE_URL=$(oc get route -n tools gogs --template='https://{{.spec.host}}')
    oc patch consolelink toolkit-sourcecontrol --type merge -p "{\"spec\": {\"href\": \"$GOGS_CONSOLE_URL\"}}"
    ```
1. Configure tools namespace with gitops-cd-secret in the tools namespace
    ```bash
    NAMESPACE=tools

    oc delete secret gitops-cd-secret -n ${NAMESPACE} || true

    oc create secret -n tools generic gitops-cd-secret \
    --from-literal username=toolkit \
    --from-literal password=toolkit \
    -n ${NAMESPACE}


    oc label secret gitops-cd-secret group=catalyst-tools -n ${NAMESPACE}
    ```
1. Configure `tools` namespace with `gitops-repo` configMap
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
1. Login into ArgoCD and create an application with the following settings:
    ```
    name: toolkit
    project: default
    sync: Auto
    git: http://gogs.tools:3000/toolkit/gitops.git
    revision: master
    path: argoprojects
    cluster: internal
    values: values.yaml
    ```
1. Update starter Kits to point to Gogs, update [dashboard/lnks.json](dashboard/lnks.json)
    ```bash
    oc patch cm ibmcloud-config -n tools --type merge -p "{\"data\": {\"LINKS_URL\": \"https://raw.githubusercontent.com/ibm-garage-cloud/cloud-native-toolkit-workshops/main/dashboard/links.json\"}}"

    oc scale deployment dashboard-developer-dashboard --replicas 0 -n tools

    oc scale deployment dashboard-developer-dashboard --replicas 1 -n tools
    ```
1. Pre-create RBAC to allow namespaces in `userxx-qa` to be able to pull from `userxx-dev`
    ```bash
    oc apply -f rbac/system-image-puller.yaml
    ```