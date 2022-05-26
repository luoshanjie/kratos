#!/usr/bin/env sh

# echo "test kratos is connected"
if type http >/dev/null 2>&1; then
    http http://127.0.0.1:10086
else
    curl http://127.0.0.1:10086
fi

# curl --request POST 'localhost/api/test' \
# --header 'Content-Type: application/json' \
# --data-raw '{ "example" : "true" }' \
# http://127.0.0.1:10086
curl -d '{"example":"true"}' -H "Content-Type: application/json" -X POST http://127.0.0.1:10086/api/test
