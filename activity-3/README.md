# Workshop:Activity-3: Deploy a 3 tier Microservice using React, Node.js, and Java

1. Prerequisites
    - The instructor should setup activity using [SETUP.md](../activity-1/SETUP.md)
    - [Setup Terminal](../CLI.md))
    - Cloud Native Toolkit [igc](https://www.npmjs.com/package/@ibmgaragecloud/cloud-native-toolkit-cli) CLI
    - OpenShift [oc](https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/) CLI 4.5+

1. Instructor will provide the following info:
    - OpenShift Console URL (OCP_CONSOLE_URL)
    - The username and password for OpenShift and Git Server (default values are user1, user2, etc.. for users and `password` for password)


1. Set `TOOLKIT_USERNAME` environment variable replace `user1` with assigned usernames
    ```bash
    TOOLKIT_USERNAME=user1

    ```

1. Set `TOOLKIT_PROJECT` environment variable replace `project1` or `projectx` based on user id assigned
    ```bash
    TOOLKIT_PROJECT=project1

    ```

1. Create a project/namespace using your project prefix, and `-dev` and suffix
    ```
    oc sync $TOOLKIT_PROJECT-dev

    ```

1. Fork Inventory Sample Application Java
    - Open Developer Dashboard from the OpenShift Console
    - Select Starter Kits
    - Select Inventory Service (Java)
    - Click Fork
    - Login into GIT Sever using the provided username and password (ie `user1` and `password`)
    - Click **Fork Repository**

1. Setup environment variable `GIT_URL` for the git url using the value from previous step or as following
    ```bash
    GIT_URL=http://${TOOLKIT_USERNAME}:password@$(oc get route -n tools gogs --template='{{.spec.host}}')/$TOOLKIT_USERNAME/inventory-management-svc-solution
    echo GIT_URL=${GIT_URL}

    ```

1. Create a pipeline for the application
    ```
    oc pipeline --tekton ${GIT_URL}#master -p scan-image=false
    ```
    - Use down arrow and select `ibm-java-gradle`
    - Open the url to see the pipeline running in the OpenShift Console


1. Fork Inventory Sample Application TypeScript
    - Open Developer Dashboard from the OpenShift Console
    - Select Starter Kits
    - Select Inventory BFF (TypeScript)
    - Click Fork
    - Click **Fork Repository**


1. Setup environment variable `GIT_URL` for the git url using the value from previous step or as following
    ```bash
    GIT_URL=http://${TOOLKIT_USERNAME}:password@$(oc get route -n tools gogs --template='{{.spec.host}}')/$TOOLKIT_USERNAME/inventory-management-bff-solution
    echo GIT_URL=${GIT_URL}

    ```

1. Create a pipeline for the application
    ```
    oc pipeline --tekton ${GIT_URL}#master -p scan-image=false
    ```
    - Use down arrow and select `ibm-nodejs`
    - Open the url to see the pipeline running in the OpenShift Console

1. Fork Inventory Sample Application React
    - Open Developer Dashboard from the OpenShift Console
    - Select Starter Kits
    - Select Inventory UI (React)
    - Click Fork
    - Click **Fork Repository**

1. Setup environment variable `GIT_URL` for the git url using the value from previous step or as following
    ```bash
    GIT_URL=http://${TOOLKIT_USERNAME}:password@$(oc get route -n tools gogs --template='{{.spec.host}}')/$TOOLKIT_USERNAME/inventory-management-ui-solution
    echo GIT_URL=${GIT_URL}

    ```

1. Create a pipeline for the application
    ```
    oc pipeline --tekton ${GIT_URL}#master -p scan-image=false
    ```
    - Use down arrow and select `ibm-nodejs`
    - Open the url to see the pipeline running in the OpenShift Console


1. Setup environment variable `GIT_OPS_URL` for the git url using the value from previous step or as following
    ```bash
    GIT_OPS_URL=http://${TOOLKIT_USERNAME}:password@$(oc get route -n tools gogs --template='{{.spec.host}}')/toolkit/gitops
    echo GIT_OPS_URL=${GIT_OPS_URL}

    ```

1. Clone the git repository and change directory
    ```bash
    cd $HOME
    git clone $GIT_OPS_URL
    cd gitops

    ```

1. Review the `qa` and `staging` directory in the git repository
    ```bash
    tree qa/${TOOLKIT_PROJECT}/
    ```

1. Promote the application from **QA** to **STAGING** by copying the app manifest files using git
    ```bash
    git config --local user.email "${TOOLKIT_USERNAME}@example.com"
    git config --local user.name "${TOOLKIT_USERNAME}"

    cat > qa/${TOOLKIT_PROJECT}/Chart.yaml <<EOF
    apiVersion: v2
    version: 1.0.0
    name: project-config-helm
    description: Chart to configure ArgoCD with the inventory application

    dependencies:
    - name: argocd-config
      version: 0.16.0
      repository: https://ibm-garage-cloud.github.io/toolkit-charts
    EOF

    cat > qa/${TOOLKIT_PROJECT}/values.yaml <<EOF
    global: {}
    argocd-config:
      repoUrl: "http://gogs.tools:3000/toolkit/gitops.git"
      project: inventory-qa
      applicationTargets:
      - targetRevision: master
        createNamespace: true
        targetNamespace: ${TOOLKIT_PROJECT}-qa
        applications:
        - name: qa-${TOOLKIT_PROJECT}-inventory-svc
          path: qa/${TOOLKIT_PROJECT}/inventory-management-svc-solution
          type: helm
        - name: qa-${TOOLKIT_PROJECT}-inventory-bff
          path: qa/${TOOLKIT_PROJECT}/inventory-management-bff-solution
          type: helm
        - name: qa-${TOOLKIT_PROJECT}-inventory-ui
          path: qa/${TOOLKIT_PROJECT}/inventory-management-ui-solution
          type: helm
    EOF

    cat qa/${TOOLKIT_PROJECT}/values.yaml

    git add .
    git commit -m "Add inventory application to gitops for project ${TOOLKIT_PROJECT}"
    git push -u origin master

    ```

1. Register the Application in ArgoCD to deploy using GitOps
    - Select ArgoCD from the Console Link and login using OpenShift login
    - Click **NEW APP**
    - Application Name: ${TOOLKIT_PROJECT}-inventory (ie project1-inventory)
    - Project: `default`
    - Sync Policy: `Automatic` (Check prune resources, self heal)
    - Repository URL: `http://gogs.tools:3000/toolkit/gitops.git`
    - Revision: `HEAD`
    - Path: `qa/${TOOLKIT_PROJECT}` (ie qa/project1)
    - Cluster: `in-cluster`
    - Namespace: `tools`
    - Click **CREATE**

1. Review the Applications in ArgoCD
    - Filter by Namespace `${TOOLKIT_PROJECT}-qa` (ie project1-qa)
    - Review Application: inventory-management-svc-solution
    - Review Application: inventory-management-bff-solution
    - Review Application: inventory-management-ui-solution

1. Review the Application in OpenShift
    - Switch to Developer perpective
    - Switch to project `${TOOLKIT_PROJECT}-qa` (ie project1-qa)
    - Open the Application from the JavaScript UI and make sure the stocks show up in the browser




