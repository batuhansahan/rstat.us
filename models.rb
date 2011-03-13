class Update
  require 'cgi'
  include MongoMapper::Document

  belongs_to :user
  key :text, String

  validates_length_of :text, :maximum => 140

  def to_html
    #first, usernames
    out = CGI.escapeHTML(text)
    out.gsub!(/@(\w+)/, "<a href='/users/\\1'>@\\1</a>")
    out
  end

  timestamps!
end

class User
  include MongoMapper::Document
  many :authorizations

  key :name, String
  key :username, String
  key :email, String
  key :website, String
  key :bio, String
  key :twitter_image, String

  key :following_ids, Array
  many :following, :in => :following_ids, :class_name => 'User'

  key :followers_ids, Array
  many :followers, :in => :followers_ids, :class_name => 'User'

  def follow! followee
    following << followee
    save
    followee.followers << self
    followee.save
  end

  def unfollow! followee
    following_ids.delete(followee.id)
    save
    followee.followers_ids.delete(id)
    followee.save
  end

  def following? user 
    following.include? user
  end

  many :updates, :dependent => :destroy

  def self.create_from_hash!(hsh)
    create!(
      :name => hsh['user_info']['name'],
      :username => hsh['user_info']['nickname'],
      :website => hsh['user_info']['urls']['Website'],
      :bio => hsh['user_info']['description'],
      :twitter_image => hsh['user_info']['image']
    )
  end

  timestamps!

  def timeline
    following.map(&:updates).flatten
  end

  after_create :follow_yo_self

  private

  def follow_yo_self
    following << self
    followers << self
    save
  end
end

class Authorization
  include MongoMapper::Document
  
  belongs_to :user

  key :uid, Integer, :required => true
  key :provider, String, :required => true

  validates_uniqueness_of :uid, :scope => :provider

  def self.find_from_hash(hsh)
    first :provider => hsh['provider'], :uid => hsh['uid'].to_i
  end

  def self.create_from_hash(hsh, user = nil)
    user ||= User.create_from_hash!(hsh)
    create!(:user => user, :uid => hsh['uid'], :provider => hsh['provider'])
  end

  timestamps!

end
