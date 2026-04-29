# RubyGems Server Test

## HTTP

1. Set up the RubyGems server environment.

   ```
   $ script/setup.sh
   ```

2. Run the RubyGems HTTP server.

   ```
   $ script/run_http_server.sh
   ```

3. Run the client in another terminal.

   ```
   $ script/run_http_client.sh
   ```

## HTTPS

### Direct HTTPS (WEBrick)

The HTTPS server uses `script/run_https_server.rb` (WEBrick) instead of
`openssl s_server` because `openssl s_server -WWW` does not handle HEAD
requests. RubyGems uses HEAD requests in `gem install`.

1. Set up the RubyGems server environment and generate SSL certificates.

   ```
   $ script/setup.sh
   ```

2. Run the RubyGems HTTPS server.

   ```
   $ script/run_https_server.rb
   ```

3. Run the client in another terminal.

   ```
   $ script/run_https_client.sh
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

### TLS Reverse Proxy

This setup uses a TLS reverse proxy in front of the HTTP RubyGems server.
The proxy terminates TLS and forwards requests to the backend HTTP server.

1. Set up the RubyGems server environment and generate SSL certificates.

   ```
   $ script/setup.sh
   ```

2. Run the RubyGems HTTP server.

   ```
   $ script/run_http_server.sh
   ```

3. Run the TLS reverse proxy server in another terminal.

   ```
   $ script/run_https_reverse_proxy.rb
   ```

4. Run the client in another terminal.

   ```
   $ script/run_https_client.sh
   ```
