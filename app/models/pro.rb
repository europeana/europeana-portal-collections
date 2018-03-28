# frozen_string_literal: true

module Pro
  class << self
    attr_accessor :site
  end
  self.site = Rails.application.config.x.europeana[:pro_url]
end
