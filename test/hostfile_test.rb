require 'test_helper'

describe Roast::HostsFile do
  HOSTSFILES_PATH = File.expand_path('../hostfiles', __FILE__)

  before do
    path   = File.join(HOSTSFILES_PATH, 'one')
    @hosts = Roast::HostsFile.new(path).read
  end

  after do
    baks = Dir[File.join(HOSTSFILES_PATH, '*.bak')]
    news = Dir[File.join(HOSTSFILES_PATH, '*.new')]
    FileUtils.rm(baks)
    FileUtils.rm(news)
  end

  it "parses a hostfile and creates groups and host entries" do
    @hosts.groups.length.must_equal 2
    [[ '127.0.0.1', 'foo.com' ], [ '10.0.1.2', 'blah.dev' ]].each_with_index do |host, i|
      @hosts.groups[:base].hosts[i].ip_address.must_equal host.first
      @hosts.groups[:base].hosts[i].hostname.must_equal host.last
    end
    [[ '10.0.20.1', 'staging.something.com' ], [ '10.0.20.2', 'staging-two.something.com' ]].each_with_index do |host, i|
      @hosts.groups[:staging].hosts[i].ip_address.must_equal host.first
      @hosts.groups[:staging].hosts[i].hostname.must_equal host.last
    end
  end

  it "parses a hostfile and writes with updated entries" do
    @hosts.groups.length.must_equal 2
    @hosts.groups[:base] << Roast::Host.new('127.0.0.1', 'example.org')
    @hosts.write(File.join(HOSTSFILES_PATH, 'one.new'))
  end

  it "does not create a backup file if the output file is a different name" do
    @hosts.groups.length.must_equal 2
    @hosts.groups[:base] << Roast::Host.new('127.0.0.1', 'example.org')
    @hosts.write(File.join(HOSTSFILES_PATH, 'two.new'))
    File.exist?(File.join(HOSTSFILES_PATH, 'one.bak')).wont_equal true
  end

  it "creates a backup file if the output file is the same as the input file" do
    @hosts.groups.length.must_equal 2
    @hosts.groups[:base] << Roast::Host.new('127.0.0.1', 'example.org')
    @hosts.write
    File.exist?(File.join(HOSTSFILES_PATH, 'one.bak')).must_equal true
  end

end
