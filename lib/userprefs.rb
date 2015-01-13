# This is the userprefs interface code.
# If you want to do things with User preferences.
# You must create a class that satisfies this interface

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
