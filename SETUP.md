## Setup the Workshop Environment

### Create OpenShift Cluster

- Create a cluster for example using [cloudnativetoolkit.dev](https://cloudnativetoolkit.dev/getting-started-day-0/plan-installation/multi-cloud)

### Install IBM Cloud Native Toolkit

- Use one of the install options for example the [Quick Install](https://cloudnativetoolkit.dev/getting-started-day-0/install-toolkit/quick-install)

To run all the scripts below run this command:
TLDR:
```bash
curl -sL https://raw.githubusercontent.com/ibm-garage-cloud/cloud-native-toolkit-workshops/main/scripts/install.sh | bash
```

### Configure Git Server

1. Install Git server, setup admin user toolkit with password toolkit
    ```bash
    ./scripts/00-git-install.sh
    ```
1. Create all the git repositories for the org toolkit
    ```
    ./scripts/01-git-repos.sh
    ```
1. Create user accounts (ie user1,user2,...,user15) default password is `password`
    ```bash
    ./scripts/02-git-users.sh
    ```

### Configure OpenShift User accounts

1. Create User accounts (ie user1,user2,...,user15) default password is `password`
    ```bash
    ./scripts/10-ocp-users.sh
    ```
1. Add Users to the ArgoCD admin group
    ```bash
    ./scripts/11-ocp-group-argocd.sh
    ```
1. Add Users to the IBM Cloud Native Toolkit group
    ```bash
    ./scripts/12-ocp-group-toolkit.sh
    ```
### Configure Toolkit

1. Update the Developer Dashboard to point to Git Server for code patterns
    ```bash
    ./scripts/20-toolkit-dashboard.sh
    ```
1. Configure `tools` namespace with `gitops-cd-secret` in the tools namespace
    ```bash
    ./scripts/21-toolkit-gitops-secret.sh
    ```
1. Configure `tools` namespace with `gitops-repo` configMap
    ```bash
    ./scripts/22-toolkit-gitops-cm.sh
    ```
1. Create the top level ArgoCD Application for all Toolkit Applications
    ```bash
    ./scripts/23-toolkit-gitops-project.sh
    ```
1. Update Console Link for Git to point to gogs url
    ```bash
    ./scripts/24-toolkit-console-git.sh
    ```
1. TODO: This should not be need it until new version of igc CLI is released. For now make all users cluster-admin
   ```bash
   oc adm policy add-cluster-role-to-group cluster-admin ibm-toolkit-users
   ```
