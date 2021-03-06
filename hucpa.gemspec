lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = "hucpa"
  spec.version = "0.2.5"
  spec.authors = ["Tomek Wałkuski"]
  spec.email = "ja@jestem.tw"

  spec.summary = "JRuby wrapper to HikariCP - JDBC connection pool"
  spec.homepage = "https://github.com/tomekw/hucpa"
  spec.license = "MIT"

  spec.platform = "java"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = %w[lib]

  spec.add_dependency "dry-validation", "~> 0.10"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "jdbc-postgres", "~> 9.4"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "~> 0"
  spec.add_development_dependency "simplecov", "~> 0"
end
