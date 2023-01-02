# local email=$(((RANDOM << 22)))
# tls ${email}@gmail.com
if [[ $proxy_site ]]; then
	proxy_is=$(echo $proxy_site | sed 's#/$##')
fi
case $v2ray_transport in
4|33)
	if [[ $is_path ]]; then
		cat >/etc/caddy/Caddyfile <<-EOF
{
    http_port 1180
    https_port 443
}
(log) {
    log {
        output file /var/log/caddy/{args.0}/access.log {
            roll_size 100MiB
            roll_local_time
            roll_keep 10
            roll_keep_for 2160h
        }
    }
}
$domain {
    import log $domain

    reverse_proxy $proxy_is {
        header_up Host {upstream_hostport}
        header_up X-Forwarded-Host {host}
    }
    handle_path /${path} {
        reverse_proxy 127.0.0.1:${v2ray_port}
    }
}
import sites/*
		EOF
	else
		cat >/etc/caddy/Caddyfile <<-EOF
{
    http_port 1180
    https_port 2443
}
(log) {
    log {
        output file /var/log/caddy/{args.0}/access.log {
            roll_size 100MiB
            roll_local_time
            roll_keep 10
            roll_keep_for 2160h
        }
    }
}
$domain {
	reverse_proxy 127.0.0.1:${v2ray_port}
}
import sites/*
		EOF
	fi
	;;
5)
	if [[ $is_path ]]; then
		cat >/etc/caddy/Caddyfile <<-EOF
$domain {
    reverse_proxy $proxy_is {
        header_up Host {upstream_hostport}
        header_up X-Forwarded-Host {host}
    }
	reverse_proxy /${path} h2c://127.0.0.1:${v2ray_port}
}
import sites/*
		EOF
	else
		cat >/etc/caddy/Caddyfile <<-EOF
$domain {
	reverse_proxy h2c://127.0.0.1:${v2ray_port}
}
import sites/*
		EOF
	fi
	;;

esac
