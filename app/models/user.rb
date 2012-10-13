class User
  include MongoMapper::Document

  many :locations

  key :provider, String
  key :uid, String
  key :name, String
  
  # key :email, String, required: true, unique: true, format: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  timestamps!
  
  def self.create_with_omniauth(auth)
    User.create provider: auth["provider"], uid: auth["uid"], name: auth["info"]["name"]
  end
  
end
