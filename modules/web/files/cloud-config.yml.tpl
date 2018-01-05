#cloud-config
coreos:
  units:
    - name: "filepreviews-web.service"
      enable: true
      command: "start"
      content: |
        [Unit]
        Description=FilePreviews Web
        After=docker.service

        [Service]
        Restart=always
        RestartSec=5s
        ExecStartPre=-/usr/bin/docker kill filepreviews-web
        ExecStartPre=-/usr/bin/docker rm filepreviews-web
        ExecStart=/usr/bin/docker run --name filepreviews-web \
          --network=filepreviews \
          --publish=8000:8000 \
          --env="DATABASE_URL=${database_url}" \
          --env="SECRET_KEY=${secret_key}" \
          --env="LICENSE_KEY=${license_key}" \
          --env="QUEUE_NAME_PREFIX=${queue_name_prefix}" \
          --env="FILEPREVIEWS_VERSION=${filepreviews_version}" \
          filepreviews/filepreviews:${filepreviews_version} \
          /app/docker/entrypoint.sh start-enterprise-server
        ExecStop=/usr/bin/docker stop filepreviews-web
