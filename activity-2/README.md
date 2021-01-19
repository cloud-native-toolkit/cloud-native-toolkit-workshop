# Workshop:Activity-2: Promoting an Application

1. Prerequisites
    - Complete [activity-1](../activity1).

1. Set `TOOLKIT_USERNAME` environment variable replace `user1` with assigned usernames
    ```bash
    TOOLKIT_USERNAME=user1

    ```

1. Set `TOOLKIT_PROJECT` environment variable replace `project1` or `projectx` based on user id assigned
    ```bash
    TOOLKIT_PROJECT=project1

    ```

1. Verify Application is deployed in **QA**
    - Select ArgoCD from the Console Link and login using OpenShift login
    - Filter Applications by name `${TOOLKIT_PROJECT}-qa` (ie project1-qa)
    - Select the application `master-qa-${TOOLKIT_PROJECT}-app` (ie master-qa-project1-app)

1. Verify Application is running in the QA namespace correspondin to your username `${TOOLKIT_PROJECT}-qa`
    - Select `Developer` perspective, select project `${TOOLKIT_PROJECT}-qa` and then select Topology from the Console and see the application running

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

1. Promote the application from **QA** to **STAGING** by copying the app manifest files using git
    ```bash
    git config --global user.email "${TOOLKIT_USERNAME}@example.com"
    git config --global user.name "${TOOLKIT_USERNAME}"

    cp -a qa/${TOOLKIT_PROJECT}/ staging/${TOOLKIT_PROJECT}/

    git add .
    git commit -m "Promote Application from QA to STAGING environment for $TOOLKIT_PROJECT"
    git push -u origin master

    ```

1. Verify Application is deployed in **STAGING**
    - Select ArgoCD from the Console Link and login using OpenShift login
    - Filter Applications by namespace `${TOOLKIT_PROJECT}-staging` (ie project1-staging)
    - Select the application `master-staging-${TOOLKIT_PROJECT}-app` (ie master-staging-project1-app)
    - Click **Refresh**

1. Verify Application is running in the **STAGING** namespace correspondin to your username `${TOOLKIT_PROJECT}-qa`
    - Select `Developer` perspective, select project `${TOOLKIT_PROJECT}-staging` and then select Topology from the Console and see the application running

1. Propose a change for the Application in **STAGING**
    - Update the replica count and create a new git branch in remote repo
    ```bash
    cat > staging/${TOOLKIT_PROJECT}/app/values.yaml <<EOF
    global: {}
    app:
      replicaCount: 2
    EOF
    git diff

    git add .
    git checkout -b ${TOOLKIT_PROJECT}-pr1
    git commit -m "Update Application in ${TOOLKIT_PROJECT}-staging namespace"
    git push -u origin ${TOOLKIT_PROJECT}-pr1

    ```
    - Open Git Ops from Console Link
    - Select toolkit/gitops git repository
    - Create a Pull Request
    - Select Pull Request
    - Click **New Pull Request**
    - Select from `compare` dropdown the branch `${TOOLKIT_PROJECT}-pr1`
    - Enter a title like `Update replica count for app in namespace $TOOLKIT_PROJECT`
    - Enter a Comment like `We need more instances business is growing Yay!`
    - click **Create Pull Request**

1. Review the PR follow change management process established by your team.
    - Click Merge Pull Request
    - Clikc Delete Branch

1. Review that application is scales out
    - Review in ArgoCD UI, it takes about 4 minutes to sync, you can click **Refresh**
    - Review in OpenShift Console, click the Deployment circle details shows 2 Pods.

