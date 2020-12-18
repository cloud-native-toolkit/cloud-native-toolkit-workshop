## Setup Workstation Shell

### IBM Cloud Shell

1. Login into the [IBM Cloud Shell](https://cloud.ibm.com/shell)
1. Verify `oc` CLI
    ```bash
    oc version --client
    ```
1. Install nodejs with nvm
    ```bash
    rm -rf ~/.npm
    mkdir ~/.npm
    export PATH=~/.npm/bin:$PATH
    npm config set prefix ~/.npm
    ```
1. Install the IBM Cloud Toolkit CLI
    ```bash
    npm i -g @ibmgaragecloud/cloud-native-toolkit-cli
    ```

### IBM Cloud OpenLabs

This setup is if your using an OpenShift cluster from https://developer.ibm.com/openlabs/openshift

1. Install nvm
    ```bash
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
    source ~/.bashrc
    ```
1. Install nodejs
    ```bash
    nvm install stable
    ```
1. Install the IBM Cloud Toolkit CLI
    ```bash
    npm i -g @ibmgaragecloud/cloud-native-toolkit-cli
    ```