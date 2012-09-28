class User
  include MongoMapper::Document
  authenticates_with_sorcery!
  
  attr_protected :crypted_password, :salt

  many :locations

  key :email, String, required: true, unique: true, format: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  key :crypted_password, String
  key :salt, String
  timestamps!
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  
end
