require 'helper'

class TestRakeProgressbar < Test::Unit::TestCase
  should "Rake progress bar return valid object after initialization" do
    bar = RakeProgressbar.new(0)
    assert_not_nil bar
    bar = RakeProgressbar.new(100)
    assert_not_nil bar
    bar = RakeProgressbar.new(500)
    assert_not_nil bar
    bar = RakeProgressbar.new(-100)
    assert_not_nil bar
    bar = RakeProgressbar.new(nil)
    assert_not_nil bar
    
  end
end
