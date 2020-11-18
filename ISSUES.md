## Problems

When using an OCP that have self-sign, when access Gogs Git server programatically needs to be `http` using internal kubernetes DNS like `http://gogs.tools:3000` or external Route, but using internal is better just in case user wants to store something private in git server.

1. `oc pipeline`
- It hardcodes `https` when it creates tekton trigger, instead of using `http` from `git remote -v`. When using an OCP with self-sign ssl certificate first pipeline run will fail. If you configure webhook and gogs to use internal url `http://gogs.tools:3000` then the tekton tasks will use this URL. See below issue needs to be fix before this works.

### CLI

- It creates a tekton trigger for gitlab doesn't work for gogs see issue here: https://github.com/ibm-garage-cloud/ibm-garage-cloud-cli




