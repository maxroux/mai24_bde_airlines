#!/usr/bin/env bash
set -e

host="$1"
shift
port="$1"
shift
cmd="$@"

until nc -z "$host" "$port"; do
  echo "Waiting for $host:$port to be available..."
  sleep 1
done

exec $cmd
