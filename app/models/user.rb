require 'bcrypt'
require 'securerandom'

class User < Sequel::Model
  plugin :validation_helpers
  one_to_many :spaces
  self.raise_on_save_failure = false
  HASH_COST = ENV['RACK_ENV'] == 'test' ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
  DUMMY_HASH = BCrypt::Password.create(SecureRandom.hex(32), cost: HASH_COST).to_s

  def validate
    super
    validates_presence [:username, :email, :password_hash]
    validates_max_length 50, [:username, :email]
    validates_format(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/, :email)
    validates_unique :username
    validates_unique :email
    errors.add(:password, 'must contain between 8 and 72 bytes') if @invalid_password
  end

  def password=(password)
    @invalid_password = !password.is_a?(String) || !password.bytesize.between?(8, 72)
    self.password_hash = if @invalid_password
                          nil
                        else
                          BCrypt::Password.create(password, cost: HASH_COST).to_s
                        end
  end

  def self.get(id)
    self[id] if id.is_a?(Integer)
  end

  def self.authenticate(email, password)
    return unless email.is_a?(String) && password.is_a?(String) && password.bytesize <= 72
    user = first(email: email)
    matches = BCrypt::Password.new(user ? user.password_hash : DUMMY_HASH) == password
    user if user && matches
  rescue BCrypt::Errors::InvalidHash
    nil
  end
end
