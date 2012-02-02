class User < ActiveRecord::Base
  has_secure_password

  ROLES = ['admin', 'field-coordinator']

  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => { :on => :create }
  validates :password_confirmation, :presence => { :on => :create }
  validates :name, :presence => true
  validates :language, :presence => true
  validates :timezone, :presence => true
  validates :role, :presence => true


  def self.roles
    ROLES
  end

end
