# frozen_string_literal: true
module Pro
  class << self
    attr_accessor :site
  end
  self.site = ENV['EUROPEANA_PRO_URL'] || 'http://pro.europeana.eu'
end
