#!/bin/bash

CURRENT_IP=$(hostname -I | awk '{print $2}')

if [ "$CURRENT_IP" == "172.16.0.121" ]; then
    ANOTHER_IP="172.16.0.122"
elif [ "$CURRENT_IP" == "172.16.0.122" ]; then
    ANOTHER_IP="172.16.0.121"
fi

## Install haproxy & keepalived
echo "[TASK 1] Install haproxy & keepalived"
apt-get update -qq
apt-get install -y -qq keepalived haproxy

cat >/etc/haproxy/haproxy.cfg<<EOF
global
    log /dev/log  local0 warning
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
   stats socket /var/lib/haproxy/stats

defaults
  log global
  option  httplog
  option  dontlognull
        timeout connect 5000
        timeout client 50000
        timeout server 50000

frontend kube-apiserver
  bind *:6443
  mode tcp
  option tcplog
  default_backend kube-apiserver

backend kube-apiserver
    mode tcp
    option tcplog
    option tcp-check
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server kube-apiserver-1 172.16.0.101:6443 check
    server kube-apiserver-2 172.16.0.102:6443 check
    server kube-apiserver-3 172.16.0.103:6443 check
EOF

systemctl restart haproxy >/dev/null 2>&1
systemctl enable haproxy >/dev/null 2>&1

cat >/etc/keepalived/keepalived.conf<<EOF
global_defs {
  notification_email {
  }
  router_id LVS_DEVEL
  vrrp_skip_check_adv_addr
  vrrp_garp_interval 0
  vrrp_gna_interval 0
}

vrrp_script chk_haproxy {
  script "killall -0 haproxy"
  interval 2
  weight 2
}

vrrp_instance haproxy-vip {
  state BACKUP
  priority 100
  interface eth1                       # Network card
  virtual_router_id 60
  advert_int 1

  authentication {
    auth_type PASS
    auth_pass 1111
  }

  unicast_src_ip ${CURRENT_IP}      # The IP address of this machine
  unicast_peer {
    ${ANOTHER_IP}                   # The IP address of peer machines
  }

  virtual_ipaddress {
    172.16.0.120/24                  # The VIP address
  }

  track_script {
    chk_haproxy
  }
}
EOF

systemctl restart keepalived >/dev/null 2>&1
systemctl enable keepalived >/dev/null 2>&1


