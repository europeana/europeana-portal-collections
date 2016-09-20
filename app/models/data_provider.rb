class DataProvider < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :uri, presence: true, uniqueness: true, format:
    { with: %r{\Ahttp://data.europeana.eu/organization/\d{6}\z} }

  has_one :logo, class_name: 'DataProviderLogo', dependent: :destroy,
    inverse_of: :data_provider

  delegate :image, to: :logo, allow_nil: true

  accepts_nested_attributes_for :logo, allow_destroy: true

  def image=(*args)
    (logo || build_logo).send(:image=, *args)
  end

  def org_id
    uri.sub('http://data.europeana.eu/organization/', '')
  end
end
