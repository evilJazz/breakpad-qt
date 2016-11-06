#!/bin/bash
SCRIPT_FILENAME="`cd \`dirname \"$0\"\`; pwd`/`basename \"$0\"`"
SCRIPT_ROOT=$(dirname "$SCRIPT_FILENAME")
cd "$SCRIPT_ROOT"

set -e

if [ ! -d breakpad/src ]; then
   git clone https://github.com/google/breakpad.git breakpad
fi

cd breakpad
git checkout -f 1f574b52c6c34e457b16bc451a52874dde91e4b0
cd ..

# Copy missing LSS library...
cp -R lss breakpad/src/third_party/

exit 0
