#!/usr/bin/env python
# coding=utf-8

import os
import argparse
import subprocess
import json
import nbformat

"""
Iterate over readdy_documentation/_tutorials/*.ipynb,
Convert them to basic html,
Read metadata from ipynb and prepend to the html as yaml front matter.

Metadata of the notebook should look like:

"metadata": {
    "readdy" : {
         "title": "Internal API",
         "category": "demonstration",
         "position": "1"
    },
    ...
}
"""

__license__ = "LGPL"
__author__ = "chrisfroe"

parser = argparse.ArgumentParser(description='Convert ipython notebooks to readdy_documentation - compatible html')
parser.add_argument('notebook_dir', type=str, help='path to directory where .ipynb files are located')

if __name__ == "__main__":
    args = parser.parse_args()
    notebook_dir = args.notebook_dir
    os.chdir(notebook_dir)

    for filename in os.listdir(os.getcwd()):
        if filename.endswith(".ipynb"):
            with open(filename, "r") as content_file:
                json_string = content_file.read()
            notebook = nbformat.reads(json_string, as_version=4)
            subprocess.run("jupyter-nbconvert --to html --template basic " + filename, shell=True)
            title = notebook.metadata.readdy.title
            category = notebook.metadata.readdy.category
            position = notebook.metadata.readdy.position
            front_matter = "---\ntitle: " + title + "\ncategory: " + category + "\nposition: " + position + "\n---\n"
            print("prepending the following front matter\n", front_matter)
            filename_as_html = os.path.splitext(filename)[0] + ".html"
            with open(filename_as_html, "r") as content_file:
                origin = content_file.read()

            with open(filename_as_html, "w") as content_file:
                content_file.write(front_matter + origin)
