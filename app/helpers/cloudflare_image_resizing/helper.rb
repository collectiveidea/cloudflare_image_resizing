# frozen_string_literal: true

module CloudflareImageResizing
  module Helper
    RESIZABLE_CONTENT_TYPES = %w[image/jpeg image/gif image/png image/webp].freeze

    # Helper to use resized_image and also build an image_tag
    # Automatically adds a srcset with the same image in 2x and 3x (unless a srcset is provided.)
    # See: https://developers.cloudflare.com/images/image-resizing/responsive-images/#srcset-for-high-dpi-displays
    # Example usage:
    # <%= resized_image_tag @user.avatar, resize: {width: 100, fit: "crop"}, alt: "Cropped avatar" %>
    def resized_image_tag(image, options = {})
      resize_options = options.delete(:resize) || {}
      image_tag(
        resized_image(image, resize_options),
        options.reverse_merge(srcset: "#{resized_image(image, resize_options.merge(dpr: 1))},
        #{resized_image(image, resize_options.merge(dpr: 2))} 2x,
        #{resized_image(image, resize_options.merge(dpr: 3))} 3x".gsub(/\s+/, " "))
      )
    end

    # Helper to use Cloudflare Image Resizing
    # https://developers.cloudflare.com/images/image-resizing/url-format/
    # Example usage:
    # <%= image_tag resized_image(@user.avatar, width: 100, fit: "crop"), alt: "Cropped avatar" %>
    def resized_image(image, options)
      preload = options.delete(:preload)

      path = if image.is_a?(ActiveStorage::Attachment) || image.is_a?(ActiveStorage::Attached) || image.is_a?(ActionText::Attachment)
        rails_public_blob_url(image)
      else
        image_path(image)
      end

      if ::Rails.application.config.cloudflare_image_resizing.enabled && resizable?(image)
        path = "/" + path unless path.starts_with?("/") # Direct R2 URLs don't have a leading /
        path = "/cdn-cgi/image/" + options.to_param.tr("&", ",") + path
      end

      if preload
        # Allow us to add a <link rel="preload"> to the head
        # to speed up loading resized images.
        content_for(:cloudflare_image_resizing_preload) do
          preload_link_tag(path, as: :image)
        end
      end

      path
    end

    # Is the image resizable with Cloudflare Image Resizing?
    # https://developers.cloudflare.com/images/image-resizing/format-limitations/
    # If we try and it isn't, we get a 415
    # Someday (supposedly) setting onerror=redirect will make this unnecessary.
    def resizable?(image)
      if image.is_a?(ActiveStorage::Attachment) || image.is_a?(ActiveStorage::Attached)
        image.content_type.in?(RESIZABLE_CONTENT_TYPES)
      elsif image.is_a?(String)
        extension = File.extname(image)[1..]
        Mime::Type.lookup_by_extension(extension).to_s.in?(RESIZABLE_CONTENT_TYPES)
      else
        false
      end
    end
  end
end
