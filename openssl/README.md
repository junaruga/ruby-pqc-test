# OpenSSL Test

These scripts test Ruby OpenSSL (`OpenSSL::SSL::SSLSocket`) TLS connections
with PQC (post-quantum cryptography) certificates directly, without DRb.

## Setup

Set up SSL certificates (CA, server, and client certs for both RSA and
ML-DSA-65).

```
$ script/setup.sh
...
OK
```

## ssl pre-generated ML-DSA-65 cert

Run the SSL ML-DSA-65 server.

```
$ script/run_ssl_server_mldsa65_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007f25593a4500 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
```

Run the client in another terminal.

```
$ script/run_ssl_client_mldsa65_pre_generated.rb
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: mldsa65
client: 2026-10-01 17:19:00 +0100
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_ssl_server_mldsa65_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm:
```

## ssl pre-generated ML-DSA-65 cert with client cert

Run the SSL ML-DSA-65 client cert server.

```
$ script/run_ssl_server_mldsa65_client_cert_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007f56ca884460 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
```

Run the client in another terminal.

```
$ script/run_ssl_client_mldsa65_client_cert_pre_generated.rb
client: Group: X25519MLKEM768
client: Signature Algorithm: mldsa65
client: Peer Signature Algorithm: mldsa65
client: 2026-10-01 17:24:51 +0100
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_ssl_server_mldsa65_client_cert_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm: mldsa65
```

## ssl pre-generated ML-DSA-65/RSA multi cert

Run the SSL server.

```
$ script/run_ssl_server_multi_cert_mldsa65_rsa_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007f3f33bd4380 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
server: Key: #<OpenSSL::PKey::RSA:0x00007f3f33bd4268 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_ssl_client_multi_cert_mldsa65_rsa_pre_generated.rb
--- Client 1: ML-DSA-65 ---
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: mldsa65
client: 2026-10-01 17:26:48 +0100
--- Client 2: RSA ---
client: Group: X25519MLKEM768
client: Signature Algorithm:
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
client: 2026-10-01 17:26:48 +0100
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_ssl_server_multi_cert_mldsa65_rsa_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm:
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm:
```

## ssl pre-generated ML-DSA-65/RSA multi cert with client cert

Run the SSL server.

```
$ script/run_ssl_server_multi_cert_mldsa65_rsa_client_cert_pre_generated.rb
server: Key: #<OpenSSL::PKey::PKey:0x00007f8ac5cc41b8 type_name=ML-DSA-65 provider=default>
server: Signature algorithm: ML-DSA-65
server: Key: #<OpenSSL::PKey::RSA:0x00007f8ac5cc40a0 oid=rsaEncryption type_name=RSA provider=default>
server: Signature algorithm: sha256WithRSAEncryption
```

Run the client in another terminal.

```
$ script/run_ssl_client_multi_cert_mldsa65_rsa_client_cert_pre_generated.rb
--- Client 1: ML-DSA-65 ---
client: Group: X25519MLKEM768
client: Signature Algorithm: mldsa65
client: Peer Signature Algorithm: mldsa65
client: 2026-10-01 17:28:45 +0100
--- Client 2: RSA ---
client: Group: X25519MLKEM768
client: Signature Algorithm: rsa_pss_rsae_sha256
client: Peer Signature Algorithm: rsa_pss_rsae_sha256
client: 2026-10-01 17:28:45 +0100
```

The server shows additional SSL socket info after the client connects.

```
$ script/run_ssl_server_multi_cert_mldsa65_rsa_client_cert_pre_generated.rb
...
server: Group: X25519MLKEM768
server: Signature Algorithm: mldsa65
server: Peer Signature Algorithm: mldsa65
server: Group: X25519MLKEM768
server: Signature Algorithm: rsa_pss_rsae_sha256
server: Peer Signature Algorithm: rsa_pss_rsae_sha256
```
