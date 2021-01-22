# IBM Cloud Native Toolkit Workshop
This repository contains the assets to assist individuals giving workshops using the [IBM Cloud Native Toolkit](https://cloudnativetoolkit.dev/). The IBM Cloud Native Toolkit is an open-source collection of assets that provide an environment for developing cloud-native applications for deployment within Red Hat OpenShift and Kubernetes.

- [Setup the Workshop Environment](#setup-the-workshop-environment)
    * [1. Create OpenShift Cluster](#1-create-openshift-cluster)
    * [2. Install IBM Cloud Native Toolkit](#2-install-ibm-cloud-native-toolkit)
    * [3. Setup IBM Cloud Native Toolkit Workshop](#3-setup-ibm-cloud-native-toolkit-workshop)
    * [4. Setup CLI and Terminal Shell](#4-setup-cli-and-terminal-shell)
- [Activities and Labs](#activities-and-labs)

## Setup the Workshop Environment

This is the base for most of the activities, some activities might have extra setup steps specific to the activity, the activity instructions should have this instructions.
### 1. Create OpenShift Cluster

- Create an OpenShift Cluster for example:
  - Using 8 hrs free Cluster on [IBM Open Labs](https://developer.ibm.com/openlabs/openshift) select lab 6 `Bring Your Own Application`
  - Using docs from [cloudnativetoolkit.dev/multi-cloud](https://cloudnativetoolkit.dev/getting-started-day-0/plan-installation/multi-cloud)
  - Internal DTE Infrastructure access via [IBM VPN](https://ccp-ui.csplab.intranet.ibm.com/ ) or [IBM CSPLAB](https://ccp-ui.apps.labprod.ocp.csplab.local/)
### 2. Install IBM Cloud Native Toolkit

- Use one of the install options for example the [Quick Install](https://cloudnativetoolkit.dev/getting-started-day-0/install-toolkit/quick-install)
    ```bash
    curl -sfL get.cloudnativetoolkit.dev | sh -
    ```

### 3. Setup IBM Cloud Native Toolkit Workshop

- Install the foundation for the workshops
    ```bash
    curl -sfL workshop.cloudnativetoolkit.dev | sh -
    ```
The username and password for Git Admin is `toolkit` `toolkit`

### 4. Setup CLI and Terminal Shell

- You can use [IBM Cloud Shell](https://cloud.ibm.com/shell), the [OpenLabs Shell](https://developer.ibm.com/openlabs/openshift) or your local workstation. More details in [Toolkit Dev Setup](https://cloudnativetoolkit.dev/getting-started/dev-env-setup) and [Toolkit CLI](https://cloudnativetoolkit.dev/getting-started/cli). Run the following command on Cloud, Linux or MacOS shel:
    ```
    curl -sL shell.cloudnativetoolkit.dev | sh - && . ~/.bashrc
    ```

## Activities and Labs

| Activities                   | Description                                                    | Status                                                                   |
| ---------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------ |
| [activity-1](./activity-1/)  | Deploy an Application using CI Pipelines with Tekton           | [Stable](https://github.com/ibm-garage-cloud/planning/issues/656)        |
| [activity-2](./activity-2/)  | Promote an Application using CD with GitOps                    | [Stable](https://github.com/ibm-garage-cloud/planning/issues/657)        |
| [activity-3](./activity-3/)  | Deploy a 3 tier Microservice using React, Node.js, and Java    | [Stable](https://github.com/ibm-garage-cloud/planning/issues/658)   |
| activity-4                   | Deploy Operators using CICD and GitOps                         | [In Progress](https://github.com/ibm-garage-cloud/planning/issues/659)       |
| activity-5                   | Application Modernization DevOps, Monolith to Container        | [In Progress](https://github.com/ibm-garage-cloud/planning/issues/660)       |
| activity-6                   | DevOps for Cloud Pak for Integration (CP4I)                    | [Backlog](https://github.com/ibm-garage-cloud/planning/issues/661)       |
| activity-7                   | ODO and CodeReadyWorkSpaces Developer Workflows                | [Backlog](https://github.com/ibm-garage-cloud/planning/issues/662)       |
| activity-8                   | Observability and Security with OpenShift ServiceMesh (Istio)  | [Backlog](https://github.com/ibm-garage-cloud/planning/issues/663)       |
| activity-9                   | Event Driven Application using OpenShift Serverles (Knative)   | [Backlog](https://github.com/ibm-garage-cloud/planning/issues/664)       |

