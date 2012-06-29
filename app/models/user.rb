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

  def code
    username
  end

  def as_json(options = nil)
    return super(options) unless (options||{})[:schema] == :offline

    {
      'username' => username,
      'name'     => name,
      'role'     => role,
      'language' => language,
      'timezone' => timezone,
    }
  end

end
