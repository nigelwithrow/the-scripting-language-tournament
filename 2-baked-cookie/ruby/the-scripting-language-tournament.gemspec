$:.unshift __dir__

Gem::Specification.new { |s|
	s.name = "the-scripting-language-tournament"
	s.files = Dir["lib/**/*"]
	s.add_dependency "mini_magick"
	s.authors = ["penguin-operator"]
	s.required_ruby_version = ">= 3.3"
}
