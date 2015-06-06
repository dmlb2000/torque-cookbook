torque Cookbook
====================
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
#### torque::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `torque` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[torque]"
  ]
}
```

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: TODO: List authors
