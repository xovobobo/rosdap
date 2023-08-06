import os
import sys
import roslaunch
import rospy
import json
import roslaunch.xmlloader as xmlloader
import roslib
import re

def is_py_file(filename: str) -> bool:
    """Determine if filename is a python file and return bool."""
    if not os.path.isfile(filename):
        return False
    extension = os.path.splitext(filename)[1]
    if extension == ".py" or extension == '.pyw':
        return True

    # Allow #!-specified files without ".py" extension                                                                                                                       
    try:
        with open(filename) as infile:
            first_line = infile.readline()
            if re.match(r"\s*#!\s*/usr/bin/env\s\s*python", first_line):
                return True
    except Exception as exc:
        print(f"Caught exception: {exc}")
        print(f"Assuming not a Python file: '{filename}'")

    return False

def create_vimspector_configs(cfg_file, action='launch'):
    rospy.init_node('rosdap_launcher', anonymous=True)
    result = {}
    result['nodes'] = []
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
            ns = node.namespace
            if node.args:
                for arg in node.args.split(' '):
                    cli_args.append(arg)

            for remap in node.remap_args:
                cli_args.append(remap[0] + ":=" + remap[1])

            cli_args.append(f'__name:={node.name}')
            cli_args.append(f'__ns:={ns}')
            
            is_python_node = is_py_file(cli_path)
            if is_python_node:
                result['nodes'].append({'rosdap': {'adapter':'debugpy', 'configuration': {'name': node.name, 'type': 'python', 'request': 'launch', 'program': cli_path, 'args': cli_args}}})
            else:
                result['nodes'].append({"rosdap": {'adapter': 'vscode-cpptools', 'configuration': {'name': node.name, 'request':'launch', 'program': cli_path, 'args': cli_args, 'cwd': "${workspaceRoot}"}}})
        
        return str(result).replace("'", '"')



if __name__ == '__main__':
    roslaunch_cfg = sys.argv[1]

    with open(roslaunch_cfg, 'r') as f:
        cfg_file = json.load(f)['roslaunch']

    f = open(os.devnull, 'w')
    sys.stdout = f
    
    vimspector_configs = create_vimspector_configs(cfg_file)
    sys.stdout = sys.__stdout__
    print(vimspector_configs)
