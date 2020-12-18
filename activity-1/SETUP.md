## Setup the Workshop Environment

### 1. Create OpenShift Cluster

- Create an OpenShift Cluster for example:
  - Using docs from [cloudnativetoolkit.dev](https://cloudnativetoolkit.dev/getting-started-day-0/plan-installation/multi-cloud)
  - Using 8 hrs free Cluster on [IBM Open Labs](https://developer.ibm.com/openlabs/openshift) select lab 6 `Bring Your Own Application`

### 2. Install IBM Cloud Native Toolkit

- Use one of the install options for example the [Quick Install](https://cloudnativetoolkit.dev/getting-started-day-0/install-toolkit/quick-install)
    ```bash
    curl -sfL get.cloudnativetoolkit.dev | sh -
    ```

### 3. Install IBM Cloud Native Toolkit Workshop

- Install the foundation for the workshops
    ```bash
    curl -sfL workshop.cloudnativetoolkit.dev | sh -
    ```
The username and password for Git Admin is `toolkit` `toolkit`