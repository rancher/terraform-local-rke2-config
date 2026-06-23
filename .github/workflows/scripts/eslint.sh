#!/usr/bin/env bash
set -e

npm install --save-dev eslint @eslint/js
npm install --save-dev @eslint/js globals
eslint .
