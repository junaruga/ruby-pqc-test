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
server: Key: #<OpenSSL::PKey::RSA:0x00007f7d61aaf380 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client.rb
client: 2026-07-22 14:07:00 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm:
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
server: Key: #<OpenSSL::PKey::RSA:0x00007facbbc3f8b0 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_rsa.rb
client: 2026-07-22 16:17:38 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_rsa.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm:
```

## drbssl ML-DSA-65 (SSL with pre-generated key/cert)

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl ML-DSA-65 server.

```
$ script/run_drbssl_server_mldsa65.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007fdf2dbbf8c8 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
```

Run the client in another terminal.

```
$ script/run_drbssl_client_mldsa65.rb
client: 2026-07-22 16:19:55 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: mldsa65
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_mldsa65.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm:
```
