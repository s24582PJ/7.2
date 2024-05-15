#!/bin/bash

exit_status=0

check_connection() {
  local source=$1
  local target=$2
  local target_ip

  target_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$target" | awk '{print $1; exit}')
  if [[ -z "$target_ip" ]]; then
    echo "Nie udało się znaleźć adresu IP dla $target"
    exit_status=1
    return
  fi

  if docker exec "$source" ping -c 1 "$target_ip" > /dev/null; then
    echo "Połączenie z $source do $target ($target_ip) jest poprawne."
  else
    echo "Połączenie z $source do $target ($target_ip) NIE jest poprawne."
    exit_status=1
  fi
}

frontend_id=$(docker ps -qf "name=frontend")
backend_id=$(docker ps -qf "name=backend")
database_id=$(docker ps -qf "name=database")

check_connection "$frontend_id" "$backend_id"

check_connection "$backend_id" "$database_id"

exit $exit_status
