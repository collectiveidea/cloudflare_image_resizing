module CloudflareImageResizing
  class Configuration
    # Whether to enable resizing. Defaults to true.
    # Often useful to disable in dev/test environments
    attr_accessor :enabled

    def initialize
      @enabled = ::Rails.env.local?
    end
  end
end
