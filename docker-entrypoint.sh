#!/bin/bash
# entrypoint
if [ "$1" = 'allegrograph_startup' ]; then
    echo "[Run] Starting AllegroGraph Database Server"
    cat /app/allegrograph/etc/agraph.cfg
    /app/allegrograph/bin/agraph-control --config /app/allegrograph/etc/agraph.cfg  start
    while true; do
        sleep 5
    done
    exit $?
fi


echo "[RUN]: Builtin command not provided [allegro_startup]"
echo "[RUN]: $@"

exec "$@"
