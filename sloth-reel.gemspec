require_relative 'lib/sloth/reel/version'

Gem::Specification.new do |spec|
  spec.name          = "sloth-reel"
  spec.version       = Sloth::Reel::VERSION
  spec.authors       = ["arimay"]
  spec.email         = ["arima.yasuhiro@gmail.com"]

  spec.summary       = %q{ Httpd and WebSocket sloth framework. }
  spec.description   = %q{ Httpd and WebSocket sloth framwwork based on Celluloid, Reel, Rack and Sinatra. }
  spec.homepage      = "https://github.com/arimay/sloth-reel"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "celluloid", "0.18.0.pre2"
  spec.add_runtime_dependency "celluloid-io", "0.17.3"
  spec.add_runtime_dependency "celluloid-fsm", "0.20.5"
  spec.add_runtime_dependency "reel", "0.6.1"
  spec.add_runtime_dependency "reel-rack", "0.2.3"

  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "sinatra", "~> 2.0.8"
  spec.add_runtime_dependency "sinatra-contrib"
  spec.add_runtime_dependency "websocket"

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
