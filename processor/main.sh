#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

echo "Event Processor placeholder"


delay=${READ_DELAY:-1}
endpoint='https://eohvjcb59i3mwsu.m.pipedream.net'

beanstalk_host=${BEANSTALK_HOST:-localhost}
beanstalk_port=${BEANSTALK_PORT:-11300}
processed_tube=${BEANSTALK_OUT_TUBE:-processed}

function process_message() {
    local event
    local subscriber
    local transformed
    local event_id

    event_id=$(uuidgen)
    subscriber=$((1 + $RANDOM % 1000000))
    event=$(./beanstalkd-cli pop --host "$beanstalk_host" --port "$beanstalk_port")

    if [[ -z "$event" ]] 
    then
        echo "No messages to process"
        return 1
    fi

    transformed=$(echo "$event" | jq --arg id "$event_id" --arg endpoint "$endpoint" --arg subscriber "$subscriber" '{subscriber: $subscriber|tonumber, endpoint: $endpoint, id: $id, params: .}')

    echo "processed message : $transformed"

    ./beanstalkd-cli put "$transformed" --host "$beanstalk_host" --port "$beanstalk_port" --tube "$processed_tube"
}

function main() {

    while true
    do
        process_message
        sleep $delay
    done
}

main