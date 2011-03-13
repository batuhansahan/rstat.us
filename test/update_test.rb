require_relative "test_helper"

class UpdateTest < MiniTest::Unit::TestCase

  include TestHelper

  def test_140_limit
    u = Update.new(:text => "This is a long update. This is a long update. This is a long update. This is a long update. This is a long update. This is a long update. jklol")
    refute u.save, "I made an update with over 140 characters"
  end

  def test_htmlize
    u = Update.new(:text => "This is a message mentioning @steveklabnik.")
    assert_match /<a href='\/users\/steveklabnik'>@steveklabnik<\/a>/, u.to_html
  end

end
