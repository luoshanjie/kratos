#!/usr/bin/env sh

echo "test kratos is connected"
if type http >/dev/null 2>&1; then
    http http://127.0.0.1:10086
else
    curl http://127.0.0.1:10086
fi
