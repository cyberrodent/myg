module AbstractInterface

  class InterfaceNotImplementedError < NoMethodError
  end

  def self.included(klass)
    klass.send(:include, AbstractInterface::Methods)
    klass.send(:extend, AbstractInterface::Methods)
  end

  module Methods

    def api_not_implemented(klass)
      caller.first.match(/in \`(.+)\'/)
      method_name = $1
      raise AbstractInterface::InterfaceNotImplementedError.new("#{klass.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end

  end

end


module Userprefs
  include AbstractInterface

  def get_user_tabs(user_id)
    Userprefs.api_not_implemented(self)
  end

  def get_user_tab(tab_id)
    Userprefs.api_not_implemented(self)
  end

  def get_prefs
    Userprefs.api_not_implemented(self)
  end

  def set_feed_name(tab_id, position, feed_name)
    Userprefs.api_not_implemented(self)
  end 

  def store_user_prefs(opts)
    Userprefs.api_not_implemented(self)
  end
end
