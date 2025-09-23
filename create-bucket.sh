#!/bin/sh

set -a; source .env; set +a

# (!!) Change default password
MINIO_NET="dsw-deployment-example_default"
MINIO_BUCKET="engine-wizard"
MINIO_USER="minio"
MINIO_PASS="minioPassword"

docker run --rm --net $MINIO_NET \
  -e MINIO_BUCKET=$MINIO_BUCKET \
  -e MINIO_USER=$MINIO_USER \
  -e MINIO_PASS=$MINIO_PASS \
  --entrypoint sh minio/mc:$MINIO_VERSION -c "\
  mc alias set dswminio http://minio:9000 minio minioPassword && \
  mc mb dswminio/\$MINIO_BUCKET
"
