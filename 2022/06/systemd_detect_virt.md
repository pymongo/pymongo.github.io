# [systemd-detect-virt](/2022/06/systemd_detect_virt.md)

systemd-detect-virt 如果在云主机则返回 kvm 如果是在物理机则返回 none

如果是 k8s_pod/docker 内则返回 docker
