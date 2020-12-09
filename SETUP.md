## Setup the Workshop Environment

### Setup OpenShift Cluster

Create a cluster using cloudnativetoolit
https://cloudnativetoolkit.dev/getting-started-day-0/plan-installation/multi-cloud

Get a free cluster for a couple or hours.
https://developer.ibm.com/openlabs/openshift

Setup user accounts for the openshift cluster using name name and password (ie user1:user1, user2:user2, etc..)

```bash
docker run --rm -it -v $PWD:/tmp/toolkit fedora bash -c 'yum install httpd-tools -y; /tmp/toolkit/scripts/03-ocp-users.sh'
oc delete secret ibm-toolkit-htpasswd -n openshift-config || true
oc create secret generic ibm-toolkit-htpasswd -n openshift-config --from-file=htpasswd=local/users.htpasswd
oc get secret ibm-toolkit-htpasswd -ojsonpath={.data.htpasswd} -n openshift-config | base64 -d

```
Edit the OAuth CR
```bash
oc edit OAuth cluster
```
```yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: my_htpasswd_provider
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: ibm-toolkit-htpasswd
```



### Install the Cloud Native Toolkit

https://cloudnativetoolkit.dev/getting-started-day-0/install-toolkit/quick-install


### Configure Git Server

1. Install Git server, setup admin user toolkit with password toolkit
    ```bash
    ./00-git-install.sh
    ```
1. Run the following scripts to create the branches `master`, `qa ` and `staging`
    ```
    GIT_HOST=$(oc get route -n tools gogs --template='{{.spec.host}}') \
    ./scripts/01-git-gitops.sh
    ```
1. Create new migration repo using one of the templates below, and  name the repository `app`, leave it public.
    - https://github.com/IBM/template-go-gin
    - https://github.com/IBM/template-node-typescript
    - https://github.com/IBM/template-java-spring

1. Create user accounts (ie user1:user1, user2:user2) or allow users to register in git server.
    ```
    GIT_HOST=$(oc get route -n tools gogs --template='{{.spec.host}}') ./scripts/02-git-users.sh
    ```

### Configure Toolkit

1. Add users to ArgoCD Group
    ```bash
    ./scripts/04-ocp-group-argocd.sh
    ```
1. Add users to Toolkit Group
    ```bash
    ./scripts/05-ocp-group-toolkit.sh
    ```
1. Allow users to list and get CRDs
    ```bash
    ./scripts/06-ocp-crds.sh
    ```
1. Allow users to copy configmaps, secrets, and tekton resources from `tools` namespace
   ```bash
   ./scripts/07-ocp-tools-view.sh
   ```
1. Allow namespaces in `userxx-qa` to be able to pull images from any namespace
    ```bash
    ./scripts/08-ocp-system-puller.sh
    ```
1. Update the Developer Dashboard to point to Git Server for code patterns
    ```bash
    ./scripts/09-toolkit-dashboard.sh
    ```
1. Configure tools namespace with gitops-cd-secret in the tools namespace
    ```bash
    ./scripts/10-toolkit-gitops-secret.sh
    ```
1. Configure `tools` namespace with `gitops-repo` configMap
    ```bash
    ./scripts/11-toolkit-gitops-secret.sh
    ```
1. Create the top level ArgoCD Application for all Toolkit Applications
    ```bash
    ./scripts/12-toolkit-console-git.sh
    ```
1. Update Console Link for Git to point to gogs url
    ```bash
    ./scripts/13-toolkit-console-git.sh
    ```
1. TODO: This should not be need it. For now make all users cluster-admin
   ```bash
   oc apply -f rbac/cluster-admins.yaml
   ```
