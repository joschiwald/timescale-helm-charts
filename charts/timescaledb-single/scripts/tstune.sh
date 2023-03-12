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

# Ensure tstune config file exists
touch "${TSTUNE_FILE}"

# Ensure tstune-generated config is included in postgresql.conf
if [ -f "${PGDATA}/postgresql.base.conf" ] && ! grep "include_if_exists = '${TSTUNE_FILE}'" postgresql.base.conf -qxF; then
    echo "include_if_exists = '${TSTUNE_FILE}'" >> "${PGDATA}/postgresql.base.conf"
fi

CPUS="$RESOURCES_CPU_LIMIT"
MEMORY="${RESOURCES_MEMORY_LIMIT}"
WAL_VOLUME_SIZE=$(numfmt --from=auto "${WAL_VOLUME_SIZE}")

# Run tstune
timescaledb-tune --quiet --conf-path="${TSTUNE_FILE}" --cpus="${CPUS}" --memory="${MEMORY}MB" --wal-disk-size="${WAL_VOLUME_SIZE}" --yes "$@"
