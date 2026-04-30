# ruby-pqc-test

Manage files to implment PQC features to ruby/* repositories.

* ruby/openssl: done. The testing repository is [here][ruby-openssl-pqc-test].
* ruby/rubygems: in progress. The testing directory is [here](./rubygems).

## Analyzing bundled gems for OpenSSL usage

The `script/analyze_bundled_gems.sh` script checks each Ruby bundled gem's repository to find files that use Ruby OpenSSL.

### Prerequisites

* `~/git/ruby/ruby` repository must exist (contains `gems/bundled_gems` file)
* `rg` (ripgrep) command must be installed

### Usage

```
$ script/analyze_bundled_gems.sh
Reading bundled gems from: /home/jaruga/git/ruby/ruby/gems/bundled_gems
Output directory: /home/jaruga/git/ruby-pqc-test/analysis/openssl_usage/bundled_gems

=== Processing: minitest ===
Updating existing repository: /home/jaruga/git/minitest
From https://github.com/minitest/minitest
 * branch            master     -> FETCH_HEAD
Already up to date.
Analyzing OpenSSL usage in minitest...
  Found 0 file(s) with OpenSSL references

=== Processing: power_assert ===
Updating existing repository: /home/jaruga/git/ruby/power_assert
From https://github.com/ruby/power_assert
 * branch            master     -> FETCH_HEAD
Already up to date.
Analyzing OpenSSL usage in power_assert...
  Found 0 file(s) with OpenSSL references
...
=== Summary ===
Output files saved to: /home/jaruga/git/ruby-pqc-test/analysis/openssl_usage/bundled_gems

Files with OpenSSL usage:
  drb: 6 file(s)
  net-imap: 10 file(s)
  net-smtp: 5 file(s)
  rbs: 2 file(s)
  rdoc: 1 file(s)
  reline: 1 file(s)

Done.
```

### Output

The script outputs files to `analysis/openssl_usage/bundled_gems/`:

* `<gem_name>_files.txt` - List of Ruby files with OpenSSL references
* `<gem_name>_detail.txt` - Detailed matches with line content

[ruby-openssl-pqc-test]: https://github.com/junaruga/ruby-openssl-pqc-test
