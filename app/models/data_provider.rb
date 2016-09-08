class DataProvider < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :uri, presence: true, uniqueness: true
end
