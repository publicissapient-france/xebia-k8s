#!/usr/bin/env python
import errno
import getopt
import os
import sys
from pathlib import Path

import yaml


def force_symlink(file1, file2):
    try:
        os.symlink(file1, file2)
    except OSError as e:
        if e.errno == errno.EEXIST:
            os.remove(file2)
            os.symlink(file1, file2)


def syncCluster(cluster, data):
    if not os.path.exists(cluster):
        os.mkdir(cluster)

    syncFolder(cluster, 'properties', data)
    syncFolder(cluster, 'provisioning', data)
    syncFolder(cluster, 'kubespray', data)


def syncFolder(cluster, folder, data):
    print(cluster + ", syncing " + folder)
    cache_dir = Path('.cache/' + cluster + '_' + folder)
    target = '{}/{}'.format(cache_dir.absolute(), data[folder]['path'] if 'path' in data[folder] else "")
    print(cache_dir)
    if cache_dir.exists():
        with cache_dir:
            os.system('git pull -f')
    else:
        os.system(f'git clone -b {data[folder]["ref"]} --single-branch {data[folder]["git"]} {cache_dir}')

    force_symlink(target, f"{cluster}/{folder}")


def main(argv):
    configfile = 'clusters.yml'
    try:
        opts, args = getopt.getopt(argv, "hc:", ["config="])
    except getopt.GetoptError:
        print('test.py -i <inputfile> -o <outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('clusterctl.py -c configFile <cluster>')
            sys.exit()
        elif opt in ("-c", "--config"):
            configfile = arg
    action = argv[len(argv) - 2]
    cluster = argv[len(argv) - 1]
    print('cluster: ', cluster)
    with open(configfile, 'r') as stream:
        try:
            conf = yaml.load(stream)
            if action == 'sync':
                syncCluster(cluster, conf['clusters'][cluster])
        except yaml.YAMLError as exc:
            print(exc)


if __name__ == "__main__":
    main(sys.argv[1:])
