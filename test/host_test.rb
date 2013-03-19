require 'test_helper'

describe Roast::Host do

  it "initializes a Host" do
    host = Roast::Host.new('127.0.0.1', 'blah.dev')
    host.hostname.must_equal 'blah.dev'
    host.ip_address.must_equal '127.0.0.1'
    host.state.must_equal 'enabled'
    host.must_be :enabled?
  end

  it "disables a host" do
    host = Roast::Host.new('127.0.0.1', 'blah.dev')
    host.state.must_equal 'enabled'
    host.disable!
    host.state.must_equal 'disabled'
    host.must_be :disabled?
  end

  it "enables a host" do
    host = Roast::Host.new('127.0.0.1', 'blah.dev')
    host.disable!
    host.must_be :disabled?
    host.enable!
    host.must_be :enabled?
  end

  it "attempts to resolve a source hostname if given" do
    Roast::Host.any_instance.expects(:resolve_source)
    Roast::Host.new('google.com', 'blah.dev')
  end

  it "validates the hostname" do
    ['foo_com', '@#$asdf.com'].each do |hostname|
      lambda { Roast::Host.new('127.0.0.1', hostname) }.must_raise ArgumentError
    end
  end


end