[![RubyGems](https://github.com/junaruga/ruby-pqc-test/actions/workflows/rubygems.yml/badge.svg?branch=main)](https://github.com/junaruga/ruby-pqc-test/actions/workflows/rubygems.yml)
[![Bundler](https://github.com/junaruga/ruby-pqc-test/actions/workflows/bundler.yml/badge.svg?branch=main)](https://github.com/junaruga/ruby-pqc-test/actions/workflows/bundler.yml)

# ruby-pqc-test

Manage files to implment PQC features to ruby/* repositories.

| Library | Type | Issue | Testing | Status | Note |
|---------|------|-------|---------|--------|------|
| [ruby/openssl](https://github.com/ruby/openssl) | default gem | [ruby/openssl#894](https://github.com/ruby/openssl/issues/894) | [ruby-openssl-pqc-test][ruby-openssl-pqc-test] | done | |
| [ruby/rubygems](https://github.com/ruby/rubygems) | | | [./rubygems](./rubygems) | in progress | Add PQC features |
| [ruby/rubygems bundler](https://github.com/ruby/rubygems/tree/master/bundler) | | | [./bundler](./bundler) | in progress | Add PQC features |
| [ruby/net-http](https://github.com/ruby/net-http) | default gem | | | not yet | Update the code comments and add PQC tests |
| [ruby/open-uri](https://github.com/ruby/open-uri) | default gem | | | not yet | Add PQC tests |
| [ruby/spec](https://github.com/ruby/spec) | spec/ directory | | | not yet | Add PQC tests |
| [ruby/drb](https://github.com/ruby/drb) | bundled gem | | | not yet | Add PQC features |
| [ruby/rbs](https://github.com/ruby/rbs) | bundled gem | | | not yet | Not sure. There is `stdlib/openssl/0/openssl.rbs`. |

[ruby-openssl-pqc-test]: https://github.com/junaruga/ruby-openssl-pqc-test
