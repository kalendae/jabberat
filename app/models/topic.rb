class Topic < ActiveRecord::Base
  acts_as_ferret :fields => [:content]
  has_many :comments
  belongs_to :user
end
