class User < ApplicationRecord  
  has_many :projects, dependent: :destroy
  searchkick
  has_secure_password


  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }


  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase
  end
end
