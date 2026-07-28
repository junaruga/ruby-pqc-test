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

## drbssl (SSL) auto-generated RSA cert

Run the drbssl server.

```
$ script/run_drbssl_server_rsa_auto_generated.rb
server: Key: #<OpenSSL::PKey::RSA:0x00007f7d61aaf380 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_rsa_auto_generated.rb
client: 2026-07-22 14:07:00 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_rsa_auto_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm:
```

## drbssl (SSL) pre-generated RSA cert

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl RSA server.

```
$ script/run_drbssl_server_rsa_pre_generated.rb
server: Key: #<OpenSSL::PKey::RSA:0x00007facbbc3f8b0 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_rsa_pre_generated.rb
client: 2026-07-22 16:17:38 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_rsa_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm:
```

## drbssl (SSL) pre-generated ML-DSA-65 cert

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl ML-DSA-65 server.

```
$ script/run_drbssl_server_mldsa65_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007fdf2dbbf8c8 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
```

Run the client in another terminal.

```
$ script/run_drbssl_client_mldsa65_pre_generated.rb
client: 2026-07-22 16:19:55 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: mldsa65
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_mldsa65_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm:
```

## drbssl (SSL) pre-generated RSA cert with client cert

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl RSA client cert server.

```
$ script/run_drbssl_server_rsa_client_cert_pre_generated.rb
server: Key: #<OpenSSL::PKey::RSA:0x00007f3a2c49f800 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_rsa_client_cert_pre_generated.rb
client: 2026-07-23 11:50:49 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm: rsa_pss_rsae_sha256
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_rsa_client_cert_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

## drbssl (SSL) pre-generated ML-DSA-65 cert with client cert

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl ML-DSA-65 client cert server.

```
$ script/run_drbssl_server_mldsa65_client_cert_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007efbe925f828 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
```

Run the client in another terminal.

```
$ script/run_drbssl_client_mldsa65_client_cert_pre_generated.rb
client: 2026-07-23 11:59:09 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm: mldsa65
client: Peer Signature Algorithm: mldsa65
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_mldsa65_client_cert_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm: mldsa65
```

## drbssl (SSL) auto-generated ML-DSA-65 cert (development)

Run the drbssl server.

```
$ script/run_drbssl_server_mldsa65_auto_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007fc8247c6188 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
```

Run the client in another terminal.

```
$ script/run_drbssl_client_mldsa65_auto_generated.rb
client: 2026-07-27 19:28:22 +0100
client: Group: SecP256r1MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: mldsa65
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_mldsa65_auto_generated.rb
...
server: Group: SecP256r1MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm:
```

## drbssl (SSL) auto-generated ML-DSA-65/RSA multi cert (development)

Run the drbssl server.

```
$ script/run_drbssl_server_multi_cert_auto_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007f84723e6180 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
server: Key: #<OpenSSL::PKey::RSA:0x00007f84723e57f8 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_multi_cert_auto_generated.rb
--- Client 1: ML-DSA-65 ---
client: 2026-07-27 19:03:18 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: mldsa65
--- Client 2: RSA ---
client: 2026-07-27 19:03:19 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_multi_cert_auto_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm:
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm:
```

## drbssl (SSL) pre-generated ML-DSA-65/RSA multi cert (development)

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl server.

```
$ script/run_drbssl_server_multi_cert_mldsa65_rsa_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007f267ea56760 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
server: Key: #<OpenSSL::PKey::RSA:0x00007f267ea56620 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_multi_cert_mldsa65_rsa_pre_generated.rb
--- Client 1: ML-DSA-65 ---
client: 2026-07-28 13:19:31 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: mldsa65
--- Client 2: RSA ---
client: 2026-07-28 13:19:31 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_multi_cert_mldsa65_rsa_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm:
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm:
```

## drbssl (SSL) pre-generated ML-DSA-65/RSA multi cert with client cert (development)

Set up SSL certificates.

```
$ script/setup.sh
...
OK
```

Run the drbssl server.

```
$ script/run_drbssl_server_multi_cert_mldsa65_rsa_client_cert_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007f9111d46468 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
server: Key: #<OpenSSL::PKey::RSA:0x00007f9111d46328 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_drbssl_client_multi_cert_mldsa65_rsa_client_cert_pre_generated.rb
--- Client 1: ML-DSA-65 ---
client: 2026-07-28 14:47:32 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm: mldsa65
client: Peer Signature Algorithm: mldsa65
--- Client 2: RSA ---
client: 2026-07-28 14:47:32 +0100
client: Group: X25519MLKEM768
client: Signature Algorithm: rsa_pss_rsae_sha256
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_drbssl_server_multi_cert_mldsa65_rsa_client_cert_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm: mldsa65
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm: rsa_pss_rsae_sha256
```
