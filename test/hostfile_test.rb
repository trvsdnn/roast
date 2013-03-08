require 'test_helper'

describe Roast::Hostsfile do
  Hostsfile = Roast::Hostsfile

  before do
  end

  it "parses a hostfile and creates groups and host entries" do
    path  = File.expand_path('../hostfiles/one', __FILE__)
    hosts = Hostsfile.new(path).read
    hosts.groups.length.must_equal 2
    [[ '127.0.0.1', 'foo.com' ], [ '10.0.1.2', 'blah.dev' ]].each_with_index do |host, i|
      hosts.groups[:base][i].ip.must_equal host.first
      hosts.groups[:base][i].host.must_equal host.last
    end
    [[ '10.0.20.1', 'staging.something.com' ], [ '10.0.20.2', 'staging-two.something.com' ]].each_with_index do |host, i|
      hosts.groups[:staging][i].ip.must_equal host.first
      hosts.groups[:staging][i].host.must_equal host.last
    end
  end

end
