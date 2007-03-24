class Person < ActiveRecord::Base
  validates_email_format_of :email, :on => :create, :message => 'fails with custom message'
end