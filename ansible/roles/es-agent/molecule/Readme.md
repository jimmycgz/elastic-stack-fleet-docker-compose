Render all viarables from .env

  echo $ES_URL
  set -a && source ../../../.env && set +a
  echo $ES_URL