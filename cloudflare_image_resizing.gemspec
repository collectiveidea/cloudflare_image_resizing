require_relative "lib/cloudflare_image_resizing/version"

Gem::Specification.new do |spec|
  spec.name = "cloudflare_image_resizing"
  spec.version = CloudflareImageResizing::VERSION
  spec.authors = ["Daniel Morrison"]
  spec.email = ["daniel@collectiveidea.com"]
  spec.homepage = "https://github.com/collectiveidea/cloudflare_image_resizing"
  spec.summary = "Easily resize images in Rails using Cloudflare's image resizing service."
  spec.description = "Easily resize images in Rails using Cloudflare's image resizing service."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/collectiveidea/cloudflare_image_resizing"
  spec.metadata["changelog_uri"] = "https://github.com/collectiveidea/cloudflare_image_resizing/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.0"
end
