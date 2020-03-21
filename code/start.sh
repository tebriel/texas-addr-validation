#!/usr/bin/env bash

set -euo pipefail

env

gunicorn -w 4 -b 0.0.0.0:3000 "validator:create_app()"
