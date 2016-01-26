# -*- encoding: utf-8 -*-

require "./lib/version"

Gem::Specification.new do |s|
  s.name = "collectd-uxsock"
  s.version = ::Newt::VERSION

  s.authors = ["Lukas Zapletal"]
  s.summary = "Ruby wrapper for collectd UNIX socket"
  s.description = "Ruby wrapper around collectd UNIX socket for IPC"
  s.homepage = "https://github.com/lzap/collectd-uxsock"
  s.licenses = ["MIT"]
  s.email = "lukas-x@zapletalovi.com"

  s.files = [
    "lib/uxsock/collectd_unix_socket.rb",
    "lib/uxsock.rb",
    "lib/version.rb",
    "README.md",
    "LICENSE"
  ]
  s.extra_rdoc_files = ['README.md']
  s.require_paths = ["lib"]
end
