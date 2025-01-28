module CloudflareImageResizing
  class Engine < ::Rails::Engine
    isolate_namespace CloudflareImageResizing

    config.cloudflare_image_resizing = Configuration.new

    config.to_prepare do
      ApplicationController.helper(CloudflareImageResizing::Helper)
    end
  end
end
