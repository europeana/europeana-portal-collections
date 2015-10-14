class Channel < ActiveRecord::Base
  include HasPublicationStates

  has_paper_trail

  validates :key, presence: true, uniqueness: true
  validates :api_params, presence: true

  def to_param
    key
  end

  def api_params_hash
    {}.tap do |hash|
      api_params.split('&').map do |param|
        key, val = param.split('=')
        hash[key] ||= []
        hash[key] << val
      end
    end
  end
end
