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
