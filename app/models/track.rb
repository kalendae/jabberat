class Track < ActiveRecord::Base
  cattr_reader :per_page
  belongs_to :user
  @@per_page = 30
end
