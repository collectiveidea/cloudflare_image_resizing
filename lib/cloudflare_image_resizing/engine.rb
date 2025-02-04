module CloudflareImageResizing
  class Engine < ::Rails::Engine
    config.cloudflare_image_resizing = Configuration.new
  end
end
