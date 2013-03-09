require 'test_helper'

describe Roast::Group do

  before do
    @group = Roast::Group.new(:base, [
      Roast::Host.new('127.0.0.1', 'foo.bar.dev'),
      Roast::Host.new('10.0.1.1', 'example.org')
    ])
  end

  it "adds a host to the group" do
    host = Roast::Host.new('127.0.0.1', 'something.dev')
    @group << host
    @group.hosts.include?(host).must_equal true
  end

  it "pads host entries correctly" do
    @group.entries_to_s.must_equal <<-RESULT.gsub /^\s+/, ""
    127.0.0.1    foo.bar.dev
    10.0.1.1     example.org
    RESULT
  end

  it "converts the group to a string correctly" do
    @group.to_s.must_equal <<-RESULT.gsub /^\s+/, ""
    ## ROAST [base]
    127.0.0.1    foo.bar.dev
    10.0.1.1     example.org
    ## TSAOR
    RESULT
  end

end
