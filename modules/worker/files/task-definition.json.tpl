[
  {
    "name": "${container_name}",
    "image": "${image}",
    "essential": true,
    "entryPoint": ["/app/docker/entrypoint.sh"],
    "command": ["start-enterprise-worker"],
    "cpu": 512,
    "memory": 512,
    "environment": [
      {
        "name": "DATABASE_URL",
        "value": "${database_url}"
      },
      {
        "name": "SECRET_KEY",
        "value": "${secret_key}"
      },
      {
        "name": "LICENSE_URL",
        "value": "${license_url}"
      },
      {
        "name": "QUEUE_NAME_PREFIX",
        "value": "${cluster}-"
      }
    ]
  }
]
