require 'test_helper'

describe Roast::Host do

  it "parses a hosts file line and creates a host" do
    host = Roast::Host.parse_and_create('127.0.0.1  foobar.dev')
    host.ip.must_equal '127.0.0.1'
    host.host.must_equal 'foobar.dev'
  end


end