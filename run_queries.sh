#!/bin/bash

QUERY_FILES_FOLDER=$1
if [ -z "$QUERY_FILES_FOLDER" ] ; then
  QUERY_FILES_FOLDER=queries
fi

PRINT_HEADERS="true"
if [ "$2" = false ]; then
  PRINT_HEADERS="false"
fi

if [[ -z "${CLICKHOUSE_SETTINGS}" ]]; then
  CLICKHOUSE_SETTINGS=""
else
  echo "using settings ${CLICKHOUSE_SETTINGS}"
  CLICKHOUSE_SETTINGS="SETTINGS ${CLICKHOUSE_SETTINGS}"
fi

echo "dropping file system cache"
clickhouse client --host "${CLICKHOUSE_HOST:=localhost}" --user "${CLICKHOUSE_USER:=default}" --password "${CLICKHOUSE_PASSWORD:=}" --secure --format=Null --query="SYSTEM DROP FILESYSTEM CACHE ON CLUSTER default"

TRIES=3
QUERY_NUM=1
for QUERY_FILE in "$QUERY_FILES_FOLDER"/*; do
    if [ "$PRINT_HEADERS" = true ]; then
      echo "-----------${QUERY_FILE}----------"
    fi
    if [ -f "$QUERY_FILE" ]; then
        cat ${QUERY_FILE} | while read query; do
        for i in $(seq 1 $TRIES); do
            RES=$(clickhouse client --host "${CLICKHOUSE_HOST:=localhost}" --user "${CLICKHOUSE_USER:=default}" --password "${CLICKHOUSE_PASSWORD:=}" --secure --time --format=Null --query="${query} ${CLICKHOUSE_SETTINGS};" 2>&1)
            if [ "$?" == "0" ] && [ "${#RES}" -lt "10" ]; then
                if [ $i == $TRIES ]; then
                  echo -n "${RES}"
                else
                  echo -n "${RES},"
                fi
            else
                echo "FAIL - ${QUERY_NUM}, ${i} - FAIL - ${RES}"
                exit 1
            fi
          done
          echo -n ";"
          QUERY_NUM=$((QUERY_NUM + 1))
      done
    fi
    echo ""
done
