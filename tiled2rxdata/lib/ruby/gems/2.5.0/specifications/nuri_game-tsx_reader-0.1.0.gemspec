# -*- encoding: utf-8 -*-
# stub: nuri_game-tsx_reader 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "nuri_game-tsx_reader".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nuri Yuri".freeze]
  s.bindir = "exe".freeze
  s.date = "2018-09-15"
  s.email = ["hostmaster@pokemonworkshop.com".freeze]
  s.homepage = "https://gitlab.com/NuriYuri/nuri_game-tsx_reader".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "2.7.3".freeze
  s.summary = "TSXReader that convert .tsx files to a ruby object".freeze

  s.installed_by_version = "2.7.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
