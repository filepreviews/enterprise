#cloud-config
coreos:
  units:
    - name: "filepreviews-worker.service"
      enable: true
      command: "start"
      content: |
        [Unit]
        Description=FilePreviews Worker
        After=docker.service

        [Service]
        Restart=always
        RestartSec=5s
        ExecStartPre=-/usr/bin/docker kill filepreviews-worker
        ExecStartPre=-/usr/bin/docker rm filepreviews-worker
        ExecStart=/usr/bin/docker run --name filepreviews-worker \
          --network=filepreviews \
          --env="DATABASE_URL=${database_url}" \
          --env="SECRET_KEY=${secret_key}" \
          --env="LICENSE_KEY=${license_key}" \
          --env="QUEUE_NAME_PREFIX=${queue_name_prefix}" \
          --env="FILEPREVIEWS_VERSION=${filepreviews_version}" \
          filepreviews/filepreviews:${filepreviews_version} \
          /app/docker/entrypoint.sh start-enterprise-worker
        ExecStop=/usr/bin/docker stop filepreviews-worker
