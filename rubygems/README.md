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
OK: All tests passed.
```

## HTTPS

### non-PQC

#### Direct HTTPS (WEBrick)

The HTTPS server uses `script/run_https_server.rb` (WEBrick) instead of
`openssl s_server` because `openssl s_server -WWW` does not handle HEAD
requests. RubyGems uses HEAD requests in `gem install`.

Set up the RubyGems server environment and generate SSL certificates.

```
$ script/setup.sh
```

Run the RubyGems HTTPS server.

Note that `run_https_server.rb` is a WEBrick-based HTTPS server that emulates a
RubyGems server.

```
$ script/run_https_server.rb
...
[2026-04-29 14:30:23] INFO  WEBrick::HTTPServer#start: pid=1502425 port=18443
```

Run the client in another terminal.

```
$ script/run_https_client.sh
...
OK: All tests passed.
```

##### Why not `openssl s_server`?

Running the SSL server with `openssl s_server -WWW`:

```
$ cd server/gem

$ openssl s_server \
  -accept 127.0.0.1:18443 \
  -cert ../ssl/rsa-2.crt \
  -key  ../ssl/rsa-2.key \
  -WWW
```

The client script gets stuck at the HEAD request:

```
$ script/run_https_client.sh
...
+ gem install hello-pqc --clear-sources -s https://localhost:18443/ -V
HEAD https://localhost:18443/versions
```

#### TLS Reverse Proxy (Ruby OpenSSL)

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
OK: All tests passed.
```

#### TLS Reverse Proxy (Nginx)

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
OK: All tests passed.
```

### PQC (single), non-PQC (single)

The PQC single cert mode runs two servers in one process: a PQC server
(ML-DSA-65 only) on port 18443 and a non-PQC server (RSA only) on port
18444. The client `-s` option tests both connections: first ML-DSA-65 to
port 18443, then RSA to port 18444.

#### Direct HTTPS (WEBrick)

Set up the RubyGems server environment and generate SSL certificates.

```
$ script/setup.sh
```

Run the RubyGems HTTPS server with PQC single cert mode.

```
$ script/run_https_server.rb -s
...
[2026-05-12 14:43:37] INFO  WEBrick::HTTPServer#start: pid=1928975 port=18443
[2026-05-12 14:43:37] INFO  WEBrick::HTTPServer#start: pid=1928975 port=18444
```

Run the client in another terminal.

```
$ script/run_https_client.sh -s
...
OK: All tests passed.
```

#### TLS Reverse Proxy (Ruby OpenSSL)

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

Run the TLS reverse proxy server with PQC single cert mode in another terminal.

```
$ script/run_https_reverse_proxy.rb -s
TLS proxy (PQC single): https://127.0.0.1:18443 -> http://127.0.0.1:18808
TLS proxy (non-PQC single): https://127.0.0.1:18444 -> http://127.0.0.1:18808
```

Run the client in another terminal.

```
$ script/run_https_client.sh -s
...
OK: All tests passed.
```

#### TLS Reverse Proxy (Nginx)

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

Run the Nginx TLS reverse proxy server with PQC single cert mode in another terminal.

```
$ script/run_https_reverse_proxy_nginx.sh -s
TLS proxy (nginx, PQC single): https://127.0.0.1:18443 -> http://127.0.0.1:18808
TLS proxy (nginx, non-PQC single): https://127.0.0.1:18444 -> http://127.0.0.1:18808
...
```

Run the client in another terminal.

```
$ script/run_https_client.sh -s
...
OK: All tests passed.
```

### PQC, non-PQC (dual)

The PQC dual certificate mode registers both ML-DSA-65 and RSA
certificates on a single server. The client `-d` option runs two test
passes, first with ML-DSA-65 signature algorithm and then with RSA, using
`OPENSSL_CONF` to set `SignatureAlgorithms` and `GEMRC` for the
CA cert per connection.

#### Direct HTTPS (WEBrick)

Set up the RubyGems server environment and generate SSL certificates.

```
$ script/setup.sh
```

Run the RubyGems HTTPS server with PQC dual certificates.

```
$ script/run_https_server.rb -d
...
[2026-05-04 17:13:39] INFO  WEBrick::HTTPServer#start: pid=1714984 port=18443
```

Run the client in another terminal.

```
$ script/run_https_client.sh -d
...
OK: All tests passed.
```

#### TLS Reverse Proxy (Ruby OpenSSL)

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

Run the TLS reverse proxy server with PQC dual certificates in another terminal.

```
$ script/run_https_reverse_proxy.rb -d
TLS proxy: https://127.0.0.1:18443 -> http://127.0.0.1:18808
```

Run the client in another terminal.

```
$ script/run_https_client.sh -d
...
OK: All tests passed.
```

#### TLS Reverse Proxy (Nginx)

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

Run the Nginx TLS reverse proxy server with PQC dual certificates in another terminal.

```
$ script/run_https_reverse_proxy_nginx.sh -d
TLS proxy (nginx): https://127.0.0.1:18443 -> http://127.0.0.1:18808
...
```

Run the client in another terminal.

```
$ script/run_https_client.sh -d
...
OK: All tests passed.
```

## Signed gem

Install expect package used in the following testing script.

Fedora Linux:

```
$ sudo dnf install expect
```

Ubuntu:

```
$ sudo apt install expect
```

Test gem signing and installation with ML-DSA (PQC) and RSA (non-PQC) certificates.

```
$ script/test_signed_gems.sh
...
OK: All tests passed.
```
