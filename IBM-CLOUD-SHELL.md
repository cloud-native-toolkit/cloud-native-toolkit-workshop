## Setup Workshop

## Setup Workstation Shell

Use the IBM Cloud Shell

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
