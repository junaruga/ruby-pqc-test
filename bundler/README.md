# Bundler Test

## PQC (single), non-PQC (single)

The PQC single cert mode runs two servers in one process: a PQC server
(ML-DSA-65 only) on port 18443 and a non-PQC server (RSA only) on port
18444. The client tests both connections: first ML-DSA-65 to port 18443
(via mirror), then RSA to port 18444.

### TLS Reverse Proxy (Ruby OpenSSL)

Set up the RubyGems server environment and generate SSL certificates.

```
$ ../rubygems/script/setup.sh
```

Run the RubyGems HTTP server.

```
$ ../rubygems/script/run_http_server.sh
gem_dir: /home/jaruga/var/git/ruby-pqc-test/rubygems/server/gem
Server started at http://0.0.0.0:18808
Server started at http://[::]:18808
```

Run the TLS reverse proxy server with PQC single cert mode in another terminal.

```
$ ../rubygems/script/run_https_reverse_proxy.rb -s
TLS proxy (PQC single): https://127.0.0.1:18443 -> http://127.0.0.1:18808
TLS proxy (non-PQC single): https://127.0.0.1:18444 -> http://127.0.0.1:18808
```

Run the client in another terminal.

```
$ script/run_client.sh
...
OK: All tests passed.
```

### TLS Reverse Proxy (Nginx)

Set up the RubyGems server environment, generate SSL certificates, and test nginx configuration.

```
$ ../rubygems/script/setup_nginx.sh
```

Run the RubyGems HTTP server.

```
$ ../rubygems/script/run_http_server.sh
gem_dir: /home/jaruga/var/git/ruby-pqc-test/rubygems/server/gem
Server started at http://0.0.0.0:18808
Server started at http://[::]:18808
```

Run the Nginx TLS reverse proxy server with PQC single cert mode in another terminal.

```
$ ../rubygems/script/run_https_reverse_proxy_nginx.sh -s
TLS proxy (nginx, PQC single): https://127.0.0.1:18443 -> http://127.0.0.1:18808
TLS proxy (nginx, non-PQC single): https://127.0.0.1:18444 -> http://127.0.0.1:18808
...
```

Run the client in another terminal.

```
$ script/run_client.sh
...
OK: All tests passed.
```
