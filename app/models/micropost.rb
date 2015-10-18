class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order(created_at: :desc) } #default_scope is used to order rows from db, here we order microposts in descending order
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
