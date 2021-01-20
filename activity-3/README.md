# Workshop:Activity-2: Promoting an Application

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

1. Setup environment variable `GIT_URL` for the git url using the value from previous step or as following
    ```bash
    GIT_URL=http://${TOOLKIT_USERNAME}:password@$(oc get route -n tools gogs --template='{{.spec.host}}')/$TOOLKIT_USERNAME/inventory-management-svc-solution
    echo GIT_URL=${GIT_URL}

    ```

1. Create a pipeline for the application
    ```
    oc pipeline --tekton ${GIT_URL}#master -p scan-image=false
    ```
    - Enter git username (ie user1, user2, etc..) and password `password` if prompted
    - Use down arrow and select `ibm-nodejs`
    - Open the url to see the pipeline running in the OpenShift Console


1. Fork Inventory Sample Application TypeScript
    - Open Developer Dashboard from the OpenShift Console
    - Select Starter Kits
    - Select Inventory BFF (TypeScript)
    - Click Fork


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