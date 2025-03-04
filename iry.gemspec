Gem::Specification.new do |spec|
  spec.name = "iry"
  spec.version = File.read(File.expand_path("VERSION", __dir__)).strip.freeze
  spec.authors = ["Francesco Belladonna"]
  spec.email = ["francesco@fc5.me"]
  spec.licenses = ["MIT"]

  spec.summary = "Transform database constraint errors into activerecord validation errors"
  spec.description = "Transform database constraint errors into activerecord validation errors"
  spec.homepage = "https://github.com/Fire-Dragon-DoL/iry"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(
          *%w[bin/ test/ spec/ features/ vendor/ scripts/ .git .circleci appveyor Gemfile Gemfile.lock]
        )
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("activerecord", ">= 3")

  spec.add_development_dependency("pg")
  spec.add_development_dependency("minitest")
  spec.add_development_dependency("minitest-power_assert")
  spec.add_development_dependency("rake", ">= 13")
  spec.add_development_dependency("sqlite3", ">= 2.1")
end
