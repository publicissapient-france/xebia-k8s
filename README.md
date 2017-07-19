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

```
make infra
```

```
make gateway
```

```
make destroy
```
