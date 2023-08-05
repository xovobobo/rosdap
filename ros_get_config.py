import os
import sys

import roslaunch
import rospy
import json
import roslaunch.xmlloader as xmlloader
import roslib




roslaunch_cfg = sys.argv[1]

with open(roslaunch_cfg, 'r') as f:
    cfg_file = json.load(f)['roslaunch']

f = open(os.devnull, 'w')
sys.stdout = f
rospy.init_node('rosdap_launcher', anonymous=True)

action = 'launch'

result = {}
result['python'] = []
result['cpp'] = []

if action == 'launch':
    loader = xmlloader.XmlLoader()
    ros_config = roslaunch.config.ROSLaunchConfig()
    loader.load(cfg_file, ros_config)
    for param in ros_config.clear_params:
        rospy.set_param(param, '')
        rospy.delete_param(param)

    for param in ros_config.params:
        rospy.set_param(ros_config.params[param].key, ros_config.params[param].value)

    for node in ros_config.nodes:
        cli_path = roslib.packages.find_node(node.package, node.type)[0]
        cli_args = []

        if node.args:
            for arg in node.args.split(' '):
                cli_args.append(arg)

        for remap in node.remap_args:
            cli_args.append(remap[0] + ":=" + remap[1])

        cli_args.append(f'__name:={node.name}')

        if node.type.endswith('py') or node.type.endswith('pyw'):
            result['python'].append({'roslaunchpy': {'adapter':'debugpy', 'configuration': {'name': node.name, 'type': 'python', 'request': 'launch', 'program': cli_path, 'args': cli_args}}})
        else:
            result['cpp'].append({"roslaunchcpp": {'adapter': 'vscode-cpptools', 'configuration': {'name': node.name, 'request':'launch', 'program': cli_path, 'args': cli_args, 'cwd': "${workspaceRoot}"}}})

sys.stdout = sys.__stdout__

print(result)
