class DataProvider < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :uri, presence: true, uniqueness: true, format:
    { with: %r{\Ahttp://data.europeana.eu/organization/\d{6}\z} }
end
