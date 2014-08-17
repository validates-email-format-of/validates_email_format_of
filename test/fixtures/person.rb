require 'validates_email_format_of'

module ValidatesEmailFormatOf
  class Base
    include ActiveModel::Model
    attr_accessor :email
  end
end


class Shorthand < ValidatesEmailFormatOf::Base
  validates :email, :email_format => { :message => 'fails with shorthand message' },
                    :length => { :maximum => 1 }
end
