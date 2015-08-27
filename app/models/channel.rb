class Channel < ActiveRecord::Base
  has_one :landing_page, dependent: :nullify

  has_paper_trail

  validates :key, presence: true, uniqueness: true
  validates :api_params, presence: true
  validates :landing_page, uniqueness: true, allow_nil: true

  def title
    I18n.t("site.channels.#{key}.title")
  end

  def to_param
    key
  end
end
