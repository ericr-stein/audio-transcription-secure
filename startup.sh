#!/bin/bash

# Start the worker and frontend processes in the background
python3 worker.py &
python3 main.py &

# Wait for any process to exit.  This keeps the container running.
wait -n

# Exit with the status code of the first process that exited.
exit $?