#cloud-config
write_files:
  - path: /etc/filepreviews/config
    permissions: 0644
    content: |
      DATABASE_URL=${database_url}
      REDIS_URL=${redis_url}
      SECRET_KEY=${secret_key}
      LICENSE_KEY=${license_key}
      SITE_DOMAIN=${domain_name}
coreos:
  units:
    - name: "filepreviews-enterprise-web.service"
      command: "start"
