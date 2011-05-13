class Person < ActiveRecord::Base
  validates_email_format_of :email, 
                            :on => :create, 
                            :message => 'fails with custom message', 
                            :allow_nil => true
end

class PersonForbidNil < ActiveRecord::Base
  set_table_name 'people'

  validates_email_format_of :email,
                            :on => :create,
                            :allow_nil => false
end


class MxRecord < ActiveRecord::Base
  set_table_name 'people'
  
  validates_email_format_of :email, 
                            :on => :create, 
                            :check_mx => true
end

if ActiveRecord::VERSION::MAJOR >= 3
  class Shorthand < ActiveRecord::Base
    set_table_name 'people'

    validates :email, :email_format => { :message => 'fails with shorthand message' },
                      :length => { :maximum => 1 }

  end
end