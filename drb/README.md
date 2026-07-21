# DRb Test

## druby (non-SSL)

Run the server and client code in different terminals, starting the server
code first.

Run the druby server.

```
$ script/run_druby_server.rb
```

Run the client in another terminal.

```
$ script/run_druby_client.rb
2026-07-21 15:54:18 +0100
```

## drbssl (SSL)

Run the drbssl server.

```
$ script/run_drbssl_server.rb
Key: #<OpenSSL::PKey::RSA:0x00007f7d61aaf380 oid=rsaEncryption type_name=RSA provider=default>
Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client.rb
2026-07-21 15:54:18 +0100
```

## drbssl RSA (SSL with pre-generated key/cert)

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl RSA server.

```
$ script/run_drbssl_server_rsa.rb
Key: #<OpenSSL::PKey::RSA:0x00007f5175d3f978 oid=rsaEncryption type_name=RSA provider=default>
Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_rsa.rb
2026-07-21 18:12:04 +0100
```
