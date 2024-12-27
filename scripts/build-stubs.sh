#!/usr/bin/env bash
(
    set -euo pipefail
    # set -x

    VS_CODE_CIRCUITPYTHON_DIR="$(cd -- "$(dirname "${BASH_SOURCE}")" ; cd .. > /dev/null 2>&1 && pwd -P)"
    cd $VS_CODE_CIRCUITPYTHON_DIR
    
    # clean up 
    rm -rf stubs
    rm -rf circuitpython


    git config --global core.longpaths true
    git clone --depth 1 --branch 9.2.1 https://github.com/adafruit/circuitpython.git

    cd circuitpython

    # use the make commands instead of the git commands
    make fetch-all-submodules

    # Use a venv for these
    # Using this name so circuitpython repo already gitignores it
    python3 -m venv .venv/
    ls -l .venv
    ls -l .venv/bin || true
    . .venv/bin/activate

    # `make stubs` in circuitpython
    pip3 install wheel  # required on debian buster for some reason
    pip3 install -r requirements-doc.txt
    make stubs

    mv circuitpython-stubs/ ../stubs

    cd $VS_CODE_CIRCUITPYTHON_DIR

    # scripts/build_stubs.py in this repo for board stubs
    python3 ./scripts/build_stubs.py
    rm -rf stubs/board

    # was crashing on `deactivate`, but guess what?! We're in parenthesis, so
    # it's a subshell. venv will go away when that subshell exits, which is,
    # wait for it.... now!
)
