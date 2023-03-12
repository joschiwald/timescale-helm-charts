#!/bin/sh

set -eu

# Exit if required variable is not set externally
: "$TSTUNE_FILE"
: "$WAL_VOLUME_SIZE"
: "$DATA_VOLUME_SIZE"
: "$RESOURCES_CPU_REQUESTS"
: "$RESOURCES_MEMORY_REQUESTS"
: "$RESOURCES_CPU_LIMIT"
: "$RESOURCES_MEMORY_LIMIT"

# Figure out how many cores are available
CPUS="$RESOURCES_CPU_REQUESTS"
if [ "$RESOURCES_CPU_REQUESTS" -eq 0 ]; then
    CPUS="${RESOURCES_CPU_LIMIT}"
fi
# Figure out how much memory is available
MEMORY="$RESOURCES_MEMORY_REQUESTS"
if [ "$RESOURCES_MEMORY_REQUESTS" -eq 0 ]; then
    MEMORY="${RESOURCES_MEMORY_LIMIT}"
fi

# Ensure tstune config file exists
touch "${TSTUNE_FILE}"

# Ensure tstune-generated config is included in postgresql.conf
if [ -f "${PGDATA}/postgresql.base.conf" ] && ! grep "include_if_exists = '${TSTUNE_FILE}'" postgresql.base.conf -qxF; then
    echo "include_if_exists = '${TSTUNE_FILE}'" >> "${PGDATA}/postgresql.base.conf"
fi

WAL_VOLUME_SIZE=$(numfmt --from=auto "${WAL_VOLUME_SIZE}")

# Run tstune
timescaledb-tune --quiet --conf-path="${TSTUNE_FILE}" --cpus="${CPUS}" --memory="${MEMORY}MB" --wal-disk-size="${WAL_VOLUME_SIZE}" --yes "$@"
