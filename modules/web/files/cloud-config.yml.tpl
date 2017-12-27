#cloud-config
write_files:
  - path: "/etc/ecs/ecs.config"
    permissions: "0644"
    owner: "root"
    content: |
      ECS_CLUSTER=${name}
      ECS_ENABLE_TASK_IAM_ROLE=true
      ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
