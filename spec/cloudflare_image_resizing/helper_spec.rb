require "spec_helper"

RSpec.describe "CloudflareImageResizing::Helper" do
  include ActionView::Helpers::AssetTagHelper

  let(:helper) {
    Class.new {
      include CloudflareImageResizing::Helper
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::CaptureHelper
      include ActionView::Context
    }.new
  }

  before do
    # Set up context for content_for helpers
    helper._prepare_context
  end

  describe "resized_image_tag" do
    it "calls resized_image with the resize: options" do
      expect(helper).to receive(:resized_image).with("/foo.jpg", {width: 10, rotate: 90}).and_call_original
      expect(helper).to receive(:resized_image).with("/foo.jpg", {dpr: 3, width: 10, rotate: 90}).and_call_original
      expect(helper).to receive(:resized_image).with("/foo.jpg", {dpr: 2, width: 10, rotate: 90}).and_call_original
      expect(helper).to receive(:resized_image).with("/foo.jpg", {dpr: 1, width: 10, rotate: 90}).and_call_original
      result = helper.resized_image_tag "/foo.jpg", resize: {width: 10, rotate: 90}, alt: "A foo", width: 20
      expect(result).to eq('<img srcset="/cdn-cgi/image/dpr=1%2Crotate=90%2Cwidth=10/foo.jpg, /cdn-cgi/image/dpr=2%2Crotate=90%2Cwidth=10/foo.jpg 2x, /cdn-cgi/image/dpr=3%2Crotate=90%2Cwidth=10/foo.jpg 3x" alt="A foo" width="20" src="/cdn-cgi/image/rotate=90,width=10/foo.jpg" />')
    end

    it "calls image_tag with the resize: options" do
      expect(helper).to receive(:resized_image).exactly(4).times.and_return("/foo.jpg")
      result = helper.resized_image_tag "/foo.jpg", resize: {width: 10, rotate: 90}, alt: "A foo", width: 20
      expect(result).to eq(image_tag("/foo.jpg", srcset: "/foo.jpg, /foo.jpg 2x, /foo.jpg 3x", alt: "A foo", width: 20))
    end

    it "does not override the srcset if one is provided" do
      expect(helper).to receive(:resized_image).exactly(4).times.and_call_original
      result = helper.resized_image_tag "/foo.jpg", resize: {width: 10, rotate: 90}, srcset: "nope.gif", alt: "A foo", width: 20
      expect(result).to eq('<img srcset="nope.gif" alt="A foo" width="20" src="/cdn-cgi/image/rotate=90,width=10/foo.jpg" />')
    end
  end

  describe "resized_image" do
    let(:image) { "/foo/bar/baz.png" }
    let(:non_resizable_image) { "/foo/bar/baz.svg" }

    it "uses Cloudflare Image resizing if enabled" do
      allow(::Rails.application.config.cloudflare_image_resizing).to receive(:enabled).and_return(true)

      result = helper.resized_image(image, width: 10, fit: "crop")
      expect(result).to eq("/cdn-cgi/image/fit=crop,width=10/foo/bar/baz.png")
    end

    it "does not use Cloudflare Image resizing if disabled" do
      allow(::Rails.application.config.cloudflare_image_resizing).to receive(:enabled).and_return(false)

      result = helper.resized_image(image, width: 10, fit: "crop")
      expect(result).to eq("/foo/bar/baz.png")
    end

    it "does not use Cloudflare Image resizing if the image is not resizable" do
      allow(::Rails.application.config.cloudflare_image_resizing).to receive(:enabled).and_return(true)

      result = helper.resized_image(non_resizable_image, width: 10, fit: "crop")
      expect(result).to eq("/foo/bar/baz.svg")
    end

    context "preload" do
      it "adds a content_for resized images if preload=true" do
        result1 = helper.resized_image(image, width: 10, fit: "crop", preload: true)
        result2 = helper.resized_image("another_image.png", width: 10, fit: "crop", preload: true)
        expect(helper.content_for(:cloudflare_image_resizing_preload)).to include(result1)
        expect(helper.content_for(:cloudflare_image_resizing_preload)).to include(result2)
      end

      it "doesn't a content_for on a non-resizable image if preload=true" do
        # Call a "good" one so the content_for gets set. Not required, but easier testing.
        result1 = helper.resized_image(image, width: 10, fit: "crop", preload: true)
        result2 = helper.resized_image(non_resizable_image, width: 10, fit: "crop", preload: true)
        expect(helper.content_for(:cloudflare_image_resizing_preload)).to include(result1)
        expect(helper.content_for(:cloudflare_image_resizing_preload)).not_to include(result2)
      end
    end
  end

  describe "resizable?" do
    let(:image) { "/foo/bar/baz.png" }
    let(:non_resizable_image) { "/foo/bar/baz.svg" }

    context "with an asset path" do
      it "returns true if it is a resizable type" do
        expect(helper.resizable?(image)).to be(true)
      end

      it "returns true if it is a resizable type" do
        expect(helper.resizable?(non_resizable_image)).to be(false)
      end
    end

    # context "with an ActiveStorage attachment" do
    #   let(:user) { create(:user) }
    #   it "returns true if it is a resizable type" do
    #     user.update! avatar: fixture_file_upload(Rails.root.join("app/assets/images/logo-icon.png"), "image/png")
    #     expect(helper.resizable?(user.avatar)).to be(true)
    #   end

    #   it "returns true if it is a resizable type" do
    #     user.update! avatar: fixture_file_upload(Rails.root.join("app/assets/images/logo-icon.svg"), "image/svg+xml")
    #     user.reload
    #     expect(helper.resizable?(non_resizable_image)).to be(false)
    #   end
    # end

    context "with an unexpected object" do
      it "returns false" do
        expect(helper.resizable?({})).to be(false)
      end
    end
  end
end
