require "spec_helper"

RSpec.describe CloudflareImageResizing do
  it "has a version number" do
    expect(CloudflareImageResizing::VERSION).not_to be_blank
  end
end
