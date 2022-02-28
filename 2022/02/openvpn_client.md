# [OpenVPN client](/2022/02/openvpn_client.md)

/etc/openvpn/client/client.ovpn

```
client
dev tun
proto tcp
remote vpn.example.com 1195
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
#compress lzo
cipher AES-256-CBC
auth-user-pass /etc/openvpn/client/pass.txt
verb 3
key-direction 1
<ca>
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
</ca>
<tls-auth>
-----BEGIN OpenVPN Static key V1-----
...
-----END OpenVPN Static key V1-----
</tls-auth>
```

pass.txt

```
username
password
```

/etc/systemd/system/openvpn.service

```
[Unit]
Description=OpenVPN client

[Service]
ExecStart=/bin/openvpn /etc/openvpn/client/client.ovpn

[Install]
WantedBy=multi-user.target
```
