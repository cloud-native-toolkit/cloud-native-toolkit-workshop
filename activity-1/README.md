# Workshop: Deploying an Application

1. Prerequisites
    - The instructor should setup activity using [SETUP.md](./SETUP.md)
    - [Setup Terminal](../CLI.md))
    - Cloud Native Toolkit [igc](https://www.npmjs.com/package/@ibmgaragecloud/cloud-native-toolkit-cli) CLI
    - OpenShift [oc](https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/) CLI 4.5+

1. Instructor will provide the following info:
    - OpenShift Console URL (OCP_CONSOLE_URL)
    - The username and password for OpenShift and Git Server (default values are user1, user2, etc.. for users and `password` for password)

1. Set `USERNAME` environment variable replace `user1` with assigned usernames
    ```bash
    USERNAME=user1
    ```

1. Login into OpenShift using `oc`
If using IBM Cloud cluster then login with your IBM account email and IAM API Key or Token, if using a cluster that was configure with the workshop scripts outside IBM Cloud then use `user1` or respective assigned username
    ```bash
    oc login $OCP_URL -u $USERNAME -p password
    ```

1. Fork application template git repo
    - Open IBM Cloud Native Toolkit Developer Dashboard from the OpenShift Console
    - Select Starter Kits
    - Select Workshop App Template
    - Login into GIT Sever using the provided username and password
    - Fork the repository `app` from the user `toolkit`
    - Copy the HTTP url to the new git repository

1. Setup environment variable `GIT_URL` for the git url using the value from previous step or as following
    ```bash
    GIT_URL=http://$(oc get route -n ${TOOLKIT_NAMESPACE} gogs --template='{{.spec.host}}')/$USERNAME/app
    ```

1. Clone the git repository and change directory
    ```bash
    git clone $GIT_URL
    cd app
    ```

1. Create a project/namespace using your username as prefix, and `-dev` and suffix
    ```
    oc sync $USERNAME-dev --dev
    ```

1. Create a pipeline for the application
    ```
    oc pipeline
    ```
    - Select `Tekton`
    - Enter `userx` as username
    - Enter `password` as token/password
    - Hit Enter to select branch `master`
    - Use down arrow and select `ibm-golang`
    - Hit Enter to select  Y for image scanning
    - Open the url to see the pipeline running in the OpenShift Console

1. Verify that Pipeline Run completeled succesfully

1. Review the Pipeline Tasks/Stages
    - Test
    - Open SonarQube from Console Link
    - Open PACT from Console Link
    - Open Artifactory from Console Link
    - Open Registry from Console Link

1. Select `Developer` perspective, select project `$USERNAME-dev` and then select Topoly from the Console and see the application running

1. Open the application route url and try out the application using the swagger UI

1. Make a change to the application in the git repository and see the pipeline running again from the Console.

1. Verify that the App manifests are being updated in the `gitops` repo in the git account `toolkit` under the `qa` branch.

1. Promote the application from DEV to QA using gitops
    ```bash
    oc sync $USERNAME-qa
    ```

1. Select ArgoCD from the Console Link and login using OpenShift login

1. Filter by namespace `$USERNAME-qa`

1. In ArgoCD UI select the application `qa-$USERNAME-app` in Argo and verify is OK

1. In OpenShift Console switch to project `$USERNAME-qa` and open the application.




