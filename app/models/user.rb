class User < ActiveRecord::Base
  include Invitational::InvitedTo
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
         
  has_many :assignments
  has_many :projects, :through => :assignments
  
  validates :email, :password, :first_name, :last_name, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 8 }
  validates :first_name, length: { minimum: 2 }
  validates :last_name, length: { minimum: 2 }
end




