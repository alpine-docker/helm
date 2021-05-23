#!/bin/sh

set -o errexit

if [[ "$*" = "run.sh" ]]; then
    run.sh
fi

echo ""
exec "$@"
