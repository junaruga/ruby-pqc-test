# RubyGems Test

## HTTP

Set up the RubyGems server environment.

```
$ script/setup.sh
```

Run the RubyGems HTTP server.

```
$ script/run_http_server.sh
gem_dir: /home/jaruga/var/git/ruby-pqc-test/rubygems/server/gem
Server started at http://0.0.0.0:18808
Server started at http://[::]:18808
```

Run the client in another terminal.

```
$ script/run_http_client.sh
...
OK
```

## HTTPS

### Direct HTTPS (WEBrick)

The HTTPS server uses `script/run_https_server.rb` (WEBrick) instead of
`openssl s_server` because `openssl s_server -WWW` does not handle HEAD
requests. RubyGems uses HEAD requests in `gem install`.

Set up the RubyGems server environment and generate SSL certificates.

```
$ script/setup.sh
```

Run the RubyGems HTTPS server.

```
$ script/run_https_server.rb
...
[2026-04-29 14:30:23] INFO  WEBrick::HTTPServer#start: pid=1502425 port=18443
```

Run the client in another terminal.

```
$ script/run_https_client.sh
...
OK
```

#### Why not `openssl s_server`?

Running the SSL server with `openssl s_server -WWW`:

```
$ cd server/gem

$ openssl s_server \
  -accept 127.0.0.1:18443 \
  -cert ../ssl/rsa.crt \
  -key  ../ssl/rsa.key \
  -WWW
```

The client script gets stuck at the HEAD request:

```
$ script/run_https_client.sh
...
+ gem install hello-pqc --clear-sources -s https://localhost:18443/ -V
HEAD https://localhost:18443/versions
```

### TLS Reverse Proxy (Ruby OpenSSL)

This setup uses a TLS reverse proxy in front of the HTTP RubyGems server.
The proxy terminates TLS and forwards requests to the backend HTTP server.

Set up the RubyGems server environment and generate SSL certificates.

```
$ script/setup.sh
```

Run the RubyGems HTTP server.

```
$ script/run_http_server.sh
gem_dir: /home/jaruga/var/git/ruby-pqc-test/rubygems/server/gem
Server started at http://0.0.0.0:18808
Server started at http://[::]:18808
```

Run the TLS reverse proxy server in another terminal.

```
$ script/run_https_reverse_proxy.rb
TLS proxy: https://127.0.0.1:18443 -> http://127.0.0.1:18808
```

Run the client in another terminal.

```
$ script/run_https_client.sh
...
OK
```

### TLS Reverse Proxy (Nginx)

This setup uses Nginx as a TLS reverse proxy in front of the HTTP RubyGems server.

Set up the RubyGems server environment, generate SSL certificates, and test nginx configuration.

```
$ script/setup_nginx.sh
```

Run the RubyGems HTTP server.

```
$ script/run_http_server.sh
gem_dir: /home/jaruga/var/git/ruby-pqc-test/rubygems/server/gem
Server started at http://0.0.0.0:18808
Server started at http://[::]:18808
```

Run the Nginx TLS reverse proxy server in another terminal.

```
$ script/run_https_reverse_proxy_nginx.sh
TLS proxy (nginx): https://127.0.0.1:18443 -> http://127.0.0.1:18808
...
```

Run the client in another terminal.

```
$ script/run_https_client.sh
...
OK
```
