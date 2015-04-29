class User < ActiveRecord::Base
  include Invitational::InvitedTo
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
         
  has_many :assignments
  has_many :projects, :through => :assignments
  
  validates :email, :password, presence: true
  validates :first_name, :last_name, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 8 }
  validates :first_name, length: { minimum: 2 }
  validates :last_name, length: { minimum: 2 }
  
           
         
  def self.get_name
    "#{first_name} #{last_name}"
  end
  
  def self.testing
    "test"
  end

end




