#!/bin/sh

#https://stackoverflow.com/questions/2870992/automatic-exit-from-bash-shell-script-on-error
abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
}

trap 'abort' 0

set -e

# Create deployment folder
mkdir -p deployment
rm -rf deployment
# Copy py libs
cp -r env/lib/**/site-packages deployment/
# Copy py files
cp *.py deployment/
## zip lambda
cd deployment
zip -r deployment.zip ./
cd -
cp -f deployment/deployment.zip ./

trap : 0

echo >&2 '
************
*** DONE ***
************
'