#!/bin/bash

echo "Please be sure you have the following packets installed: python-setuptools, cython, python-dev, libgeos-dev."
echo  "Press ENTER if yes, CTRL + C if no (and install them!)"
read

python setup.py build sdist && sudo python setup.py install

