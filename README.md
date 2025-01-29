[![Gem Version](https://img.shields.io/gem/v/cloudflare_image_resizing.svg)](https://rubygems.org/gems/cloudflare_image_resizing)
[![CI](https://github.com/collectiveidea/cloudflare_image_resizing/actions/workflows/ci.yml/badge.svg)](https://github.com/collectiveidea/cloudflare_image_resizing/actions/workflows/ci.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

# CloudflareImageResizing

[Cloudflare's Image Resizing](https://developers.cloudflare.com/images/image-resizing) is a great alternative to resizing images in your Rails app. You get to resize images on-the-fly without adding any load to your server. 

This gem make it easy to pass cloudflare's [resizing settings](https://developers.cloudflare.com/images/image-resizing/url-format/) via a pair of helpers: 


### `resized_image_tag`

Helper to use `resized_image` and also build an `image_tag`.

Automatically adds a `srcset` with the same image in 2x and 3x (unless you provide a `srcset`.) See: https://developers.cloudflare.com/images/image-resizing/responsive-images/#srcset-for-high-dpi-displays

Example usage:

```ruby
<%= resized_image_tag(@user.avatar, {width: 100, fit: "crop"}, alt: "Cropped avatar" %>
```

### `resized_image`

Helper return a URL with the applied [resizing settings](https://developers.cloudflare.com/images/image-resizing/url-format/)

Example usage:

```ruby
<%= image_tag resized_image(@user.avatar, width: 100, fit: "crop"), alt: "Cropped avatar" %>
```

### Extra option: Preload 

If you pass `preload: true` with the resize options, then add `<%= yield(:cloudflare_image_resizing_preload) %>` to your `<head>`, you will get `<link rel="preload">` for the images. 

### Outside of controllers/views

You can use the helpers outside of a controller or view, simply `include CloudflareImageResizing::Helper` where you need it.

### Resizable formats

Not all formats are resizable. See Cloudflare's docs on [format limitations](https://developers.cloudflare.com/images/image-resizing/format-limitations/)

tl;dr: these helpers only try to resize `image/jpeg`, `image/gif`, `image/png`, and `image/webp`. Other formats are passed through without resizing.

## Prerequisites

* You are using Cloudflare and have Image Resizing enabled. 
* You're using Rails
* You have images either in ActiveStorage or referenced by a URL.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "cloudflare_image_resizing"
```

## Configuration

You can use an initializer to configure the `enabled` flag (defaults to `true` for non-local environments, checking `Rails.env.local?`.)

```ruby
Rails.application.config.cloudflare_image_resizing.enabled = false
```

***Note:*** Image resizing doesn't work from `localhost`, as Cloudflare needs to be able to proxy the request. For that reason, we only enable resizing in production. When disabled, the helpers just return the image path without resize options.


## Related Reading
* [Active Storage and Cloudflare’s R2](https://discuss.rubyonrails.org/t/active-storage-and-cloudflares-r2/80819)

## Contributing
Open a PR. Be kind. Make the world a better place.

We built this for our own use cases and many have not run into yours. Let us know of omissions, but be prepared to do the work yourself. 

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
