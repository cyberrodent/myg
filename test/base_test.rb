require File.expand_path('../helper', __FILE__)

class BaseTest < Test::Unit::TestCase

    def setup
        @fixtureA = "Aardvark"
    end

    def test_default
        assert true
    end
end
