module CloudflareImageResizing
  class Engine < ::Rails::Engine
    config.cloudflare_image_resizing = Configuration.new

    config.to_prepare do
      ActiveSupport.on_load :action_controller do
        if respond_to?(:helper)
          helper CloudflareImageResizing::Helper
        end
      end
    end
  end
end
