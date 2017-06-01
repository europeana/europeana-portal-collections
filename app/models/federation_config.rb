# frozen_string_literal: true
class FederationConfig < ActiveRecord::Base
  belongs_to :collection

  delegate :provider_enum, to: :class

  class << self
    def provider_enum
      Foederati::Providers.registry.keys
    end
  end

  validates_presence_of [:provider, :collection]
  validates :provider, uniqueness: { scope: :collection }
  validates :provider, :inclusion => { in: provider_enum }
end