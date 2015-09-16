class Channel < ActiveRecord::Base
  include HasPublicationStates

  has_paper_trail

  validates :key, presence: true, uniqueness: true
  validates :api_params, presence: true

  def to_param
    key
  end
end
