## Problems

### CLI

`oc pipeline`
- It hardcodes `https` when it creates tekton trigger, instead of using `http` from `git remote -v`

Workaround:
Edit the secret `git-credentilas` and update `url` to use `http` instead of `https`

- It creates a tekton trigger for gitlab doesn't work for gogs

Workaround:
Edit or create new TriggerBinding

oc edit triggerbindings.triggers.tekton.dev template-go-gin
To update both `gitrevision` and `gitrepositoryurl`

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  labels:
    app: template-go-gin
  name: template-go-gin
spec:
  params:
  - name: gitrevision
    value: $(body.after)
  - name: gitrepositoryurl
    value: $(body.repository.clone_url)
```

Edit Eventlistener

To update the header match `filter: header.match('X-Gogs-Event', 'push') && body.ref == 'refs/heads/master'`

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  labels:
    app: template-go-gin
  name: template-go-gin
  namespace: user1-dev
spec:
  serviceAccountName: pipeline
  triggers:
  - name: template-go-gin
    bindings:
    - kind: TriggerBinding
      name: template-go-gin
    template:
      name: template-go-gin
    interceptors:
    - cel:
        filter: header.match('X-Gogs-Event', 'push') && body.ref == 'refs/heads/master'
```

### Argo

The Argoproject should create argo app different for every user, with a prefix using user id `${userid}-$(appname)`

A unique path needs to be specified for each app, a directory at the root for the git org/user see below for gitops task

### Tekton Tasks

The gitops task if the app is not already in the git repo, it should create a directory in the root with the git org/user id, if already present then use it, if the app name is at the root use it.

If the user defines a `path` or `root-path` in the configmap `gitops-repo` this will allow the full qualified path ignoring the app-name when using `path` or just the parent directory by using `root-path`

The tasks `setup` and `gitops` hardcodes `https` when git credentials are specified, instead of taking the protocol schem from the param `git-url`



