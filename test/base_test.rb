require File.expand_path('../helper', __FILE__)
require './lib/mygoogle'

class BaseTest < Test::Unit::TestCase

    def setup
        @fixtureA = "Aardvark"
    end

    def test_default
        assert true
    end


    def test_mg_get_prefs
            # CAUTION
            # This tests against the database
            # this is a horrible thing to do
            # but it is far less worse than 
            # to have no tests
            #
            tabs = Mg.get_prefs(1)
            assert tabs.length > 1
            assert tabs[0][:tabname] == "Home"
    end

    def test_mg_get_user_tabs
            tab_data = Mg.get_user_tabs(1)
            # something is stupid in this
            # is it even used?
            assert tab_data.length > 0
    end

end
