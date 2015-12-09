torque Cookbook
====================
[![Build Status](https://travis-ci.org/dmlb2000/torque-cookbook.svg?branch=master)](https://travis-ci.org/dmlb2000/torque-cookbook)
This cookbook is used to test torque on Fedora/EPEL systems.

Requirements
------------
#### Cookbooks
- `yum` - required to setup local testing repository
- `yum-epel` - required to get dependencies for torque
- `auto-update` - required to make sure the cluster is updated

Attributes
----------
#### torque::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['torque']['user']</tt></td>
    <td>String</td>
    <td>torque user to use</td>
    <td><tt>pbs</tt></td>
  </tr>
  <tr>
    <td><tt>['torque']['etc_dir']</tt></td>
    <td>String</td>
    <td>torque etc directory</td>
    <td><tt>/etc/torque</tt></td>
  </tr>
  <tr>
    <td><tt>['torque']['var_dir']</tt></td>
    <td>String</td>
    <td>torque var directory</td>
    <td><tt>/var/lib/torque</tt></td>
  </tr>
  <tr>
    <td><tt>['torque']['publickey']</tt></td>
    <td>String</td>
    <td>torque user public ssh key</td>
    <td><tt>not found</tt></td>
  </tr>
  <tr>
    <td><tt>['torque']['manager_host']</tt></td>
    <td>String</td>
    <td>torque </td>
    <td><tt>not found</tt></td>
  </tr>
</table>

Usage
-----
#### torque::server
Just include `torque::server` in your node's `run_list` to install
and enable the torque server daemons:

```json
{
  "name":"my_node",
  "run_list": [
    "role[torque-server],recipe[torque::server]"
  ]
}
```

#### torque::compute
Just include `torque::compute` in your node's `run_list` to install
and enable the torque compute daemons:

```json
{
  "name":"my_node",
  "run_list": [
    "role[torque-compute],recipe[torque::compute]"
  ]
}
```

#### torque::client
Just include `torque::client` in your node's `run_list` to install
the torque client and connect it to the cluster:

```json
{
  "name":"my_node",
  "run_list": [
    "role[torque-clients],recipe[torque::client]"
  ]
}
```

Testing
------------

There are two testing modes, all-in-one (aio) and a basic compute
cluster.

#### All-In-One (aio)

This is a simple `kitchen test aio` and it will install and configure
a test torque cluster on a single node and run some basic tests 
outlined in the administration documentation provided by torque 
administration manual.

#### Cluster Configuration

This test is more complicated as we have separated out the server,
compute and client parts of torque to separate systems. As this is
a unique testing framework there are very specific requirements for
setting things up.

- Fedora/RHEL system for running the tests (libvirt/kvm capable).
- vagrant-libvirt
- vagrant boxes for qemu generated from
  http://github.com/dmlb2000/bento
- chefdk
- local torque repository specified in `torque::setup`

The setup is done by running the `./start.sh` script in the root
of the cookbook directory. This script sets up the testing 
environment by doing the following:

- starts chef-zero on the host
- vendors torque and the required cookbooks to the playground
- uploads the cookbooks, roles, nodes, data bags and environments 
  from `test/integration/playground` to chef-zero
- uses kitchen create to launch 4 servers; server, client and two 
  compute
- runs `torque::setup` with associated required roles on the nodes
  to make sure basic requirements are met
 - hosts file entries are added to make sure name lookups work
 - repositories are added so the test version of torque packages can
   be downloaded
 - system is generally updated to make sure everything is current

The configuration of torque and testing is done by running the
`test.sh` script and it does the following:

- upload new cookbooks, roles, environments and data bags (exclude
  the nodes)
- run the appropriate `run_list` for the appropriate node
 - client => `role[torque-clients],recipe[torque::client]`
 - server => `role[torque-server],recipe[torque::server]`
 - compute => `role[torque-compute],recipe[torque::compute]`
- run this twice so that search picks up the other nodes

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors:
David ML Brown Jr.
