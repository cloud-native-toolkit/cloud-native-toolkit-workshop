# IBM Cloud Native Toolkit Workshop

- Prerequisites (see [Setup#Workstation](./SETUP.md#setup-workstation-shell))
    - OpenShift [oc](https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/) CLI 4.5+
    - [Cloud Native Toolkit](https://www.npmjs.com/package/@ibmgaragecloud/cloud-native-toolkit-cli) CLI

- Instructor will provide the following info:
    - OpenShift Console URL (OCP_CONSOLE_URL)
    - OpenShift Server URL (OCP_URL)
    - Git Server URL
    - Assigned username and password for both OpenShift and Git Server

- Fork application template git repo
    1. Login into GIT Sever using the provided username and password
    1. Fork the repository `app` from the user `toolkit`
    1. Copy the HTTP url to the new git repository

- Setup environment variables for the user
    ```bash
    USERNAME=<REPLACE ME WITH USERNAME PROVIDED>
    GIT_URL=http://gogs-tools.<subdomain>/$USERNAME/app
    ```

- Clone the git repository and change directory
    ```
    git clone $GIT_URL
    cd $GIT_URL
    ```

- Login using provided username and password into OpenShift server using the CLI
    ```
    oc login $OCP_URL
    ```

- Create a project/namespace using your username as prefix, and `-dev` and suffix
    ```
    oc sync $USERNAME-dev --dev
    ```

- Create a pipeline for the application, select `Tekton`, and select `go`, ignore the warning but copy the printed url to be use later.
    ```
    oc pipeline
    ```

- Open the OpenShift console and login
    ```
    oc console
    ```

- Select the project `$USERNAME-dev`

- Select Pipeline from the Console and see the status of the Pipeline

- Select Topoly from the Console and see the application running

- Open the application route url and try the application

- In the Git Server open the Settings for the repository, select Webhooks, create a new webhook and use the url from the step `oc pipeline` select defaults.

- Make a change to the application in the git repository and push the changes.

- Check the new pipeline running deploying the change.

- Promote the application to QA using gitops
    ```
    oc sync $USERNAME-qa
    ```

- Select ArgoCD from the Console menu and login

- In ArgoCD UI select the application `qa-$USERNAME-app` in Argo and verify is OK

- In OpenShift Console switch to project `$USERNAME-qa` and open the application.




