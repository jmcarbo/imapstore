# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{imapstore}
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joan Marc Carbo Arnau"]
  s.date = %q{2009-01-11}
  s.default_executable = %q{imapstore}
  s.description = %q{ruby gem to use an imap server as a file storage device}
  s.email = ["jmcarbo@gmail.com"]
  s.executables = ["imapstore"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/imapstore", "lib/imapstore.rb", "lib/imapstore/imapstore.rb", "script/console", "script/destroy", "script/generate", "spec/imapstore_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://wiki.github.com/jmcarbo/imapstore}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{imapstore}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{ruby gem to use an imap server as a file storage device}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rdoc>, [">= 2.2.0"])
      s.add_runtime_dependency(%q<tmail>, [">= 1.2.3"])
      s.add_runtime_dependency(%q<getoptions>, [">= 0.1"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<rdoc>, [">= 2.2.0"])
      s.add_dependency(%q<tmail>, [">= 1.2.3"])
      s.add_dependency(%q<getoptions>, [">= 0.1"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<rdoc>, [">= 2.2.0"])
    s.add_dependency(%q<tmail>, [">= 1.2.3"])
    s.add_dependency(%q<getoptions>, [">= 0.1"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
