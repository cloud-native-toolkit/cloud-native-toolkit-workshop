# Workshop: Deploying an Application

- Prerequisites (see [Setup Workstation Shell](../CLI.md))
    - OpenShift [oc](https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/) CLI 4.5+
    - [Cloud Native Toolkit](https://www.npmjs.com/package/@ibmgaragecloud/cloud-native-toolkit-cli) CLI

- Instructor will provide the following info:
    - OpenShift Console URL (OCP_CONSOLE_URL)
    - The username and password for OpenShift and Git Server (default values are user1, user2, etc.. for users and `password` for password)

- Fork application template git repo
    - Open IBM Cloud Native Toolkit Developer Dashboard from the OpenShift Console
    - Select Starter Kits
    - Select Workshop App Template
    - Login into GIT Sever using the provided username and password
    - Fork the repository `app` from the user `toolkit`
    - Copy the HTTP url to the new git repository

- Setup environment variables for the user
    ```bash
    USERNAME=<REPLACE ME WITH USERNAME PROVIDED>
    SUBDOMAIN=<REPLACE ME WITH SUBDOMAIN PROVIDED>
    GIT_URL=http://gogs-tools.$SUBDOMAIN/$USERNAME/app
    ```

- Clone the git repository and change directory
    ```bash
    git clone $GIT_URL
    cd app
    ```

- Login using OpenShift CLI.
    ```
    oc login $OCP_URL -u $USERNAME -p password
    ```

- Create a project/namespace using your username as prefix, and `-dev` and suffix
    ```
    oc sync $USERNAME-dev --dev
    ```

- Create a pipeline for the application
    ```
    oc pipeline
    ```
    - Select `Tekton`
    - Enter `userx` as username
    - Enter `password` as token/password
    - Hit Enter to select branch `master`
    - Use down arrow and select `ibm-golang`
    - Hit Enter to select  Y for image scanning

- Open the OpenShift console and login
    ```
    oc console
    ```

- Select the project `$USERNAME-dev`

- Select Pipeline from the Console and see the status of the Pipeline

- Select Pipeline Run

- Verify that Pipeline Run completeled succesfully

- Review the Pipeline Tasks/Stages
    - Test
    - Open SonarQube from Console Link
    - Open PACT from Console Link
    - Open Artifactory from Console Link
    - Open Registry from Console Link

- Select Topoly from the Console and see the application running

- Open the application route url and try the application

- Make a change to the application in the git repository and run the Pipeline again from the Console.

- Check the new pipeline running again.

- Verify that App manifests are being updated in the `gitops` repo in the git account `toolkit` under the `qa` branch.

- Promote the application to QA using gitops
    ```bash
    oc new-project $USERNAME-qa
    ```

- Select ArgoCD from the Console menu and login

- Filter by namespace `$USERNAME-qa`

- In ArgoCD UI select the application `qa-$USERNAME-app` in Argo and verify is OK

- In OpenShift Console switch to project `$USERNAME-qa` and open the application.




