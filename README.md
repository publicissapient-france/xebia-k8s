# How-to

```bash
# 1 - Clone repo
git clone ...

# 2 - Get submodules
git submodule init
git submodule update --remote

# 3 - Create a virtualenv 
virtualenv --python=python2 venv

# 4 - Enable it
source ./venv/bin/activate

# 5 - Install requirements (Ansible, actually)
pip install -r requirements.txt
```

# How-to OAuth

```
# 1 - Install k8s-oidc-helper (optional, but adviced)
go get github.com/micahhausler/k8s-oidc-helper

# 2 - Get the client_secret.json from someone in the #kubernetes channel on
  Slack
...

# 3 - Authenticate to Google to get qn OAuth token (this will open a tab in
  your browser !)
$(go env GOPATH)/bin/k8s-oidc-helper -c client_secret.json

# 4 - Write your ~/.kube/config based on the following template:

---
kind: Config
apiVersion: v1
preferences: {}
clusters:
- cluster:
    insecure-skip-tls-verify: true # Nécessaire tant que je n'ai pas réglé le pb de certificat
    server: https://master.k8s.techx.fr:6443
  name: xebia
contexts:
- context:
    cluster: xebia
    user: <YOUR_NAME>@xebia.fr
  name: xebia
current-context: xebia
<THE YAML PART GENERATED BY THE OIDC-HELPER WITH USERS PART>
```

# 5 - Initialize Terraform modules

```
terraform init
```

# 6 - Generate SSH key for your cluster

```
ssh-keygen -f ssh/rsakey
```

# 7 - Create the cluster
```
make gateway
```

```
make cluster
```

```
make destroy
```
