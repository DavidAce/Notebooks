import os, sys
from jinja2 import Environment, FileSystemLoader
import salt
import salt.modules.file

salt.file = salt.modules.file
file_loader = FileSystemLoader(os.path.dirname(__file__))
env = Environment(loader=file_loader, extensions=['jinja2.ext.do'])
template = env.get_template(sys.argv[1])
template.globals['salt'] = salt
print (template.render()) 
