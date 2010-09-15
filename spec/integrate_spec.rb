require 'spec_helper'

describe EY::Serverside::Adapter::Integrate do
  it_should_behave_like "it accepts verbose"

  context "with valid arguments" do

    let(:command) do
      adapter = described_class.new do |builder|
        builder.app = "rackapp"
        builder.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        builder.stack = "nginx_unicorn"
        builder.framework_env = "production"
      end
      adapter.call {|cmd| cmd}
    end

    it "invokes the correct version of engineyard-serverside" do
      command.should =~ /engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_/
    end

    it "puts the app in the command line" do
      command.should =~ /--app rackapp/
    end

    it "puts the instances in the command line" do
      command.should =~ /--instances localhost/
      command.should =~ /--instance-roles localhost:han,solo/
      command.should =~ /--instance-names localhost:chewie/
    end

    it "puts the stack in the command line" do
      command.should =~ /--stack nginx_unicorn/
    end

    it "puts the framework env in the command line" do
      command.should =~ /--framework-env production/
    end

    it "properly quotes odd arguments just in case" do
      adapter = described_class.new do |builder|
        builder.app = "rack app"
        builder.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        builder.stack = 'nginx_unicorn'
        builder.framework_env = 'production'
      end
      adapter.call {|cmd| cmd.should =~ /--app 'rack app'/}
    end

    it "invokes the right deploy subcommand" do
      command.should =~ /engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_ integrate/
    end

    it "invokes exactly the right command" do
      command.should == "engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_ integrate --app rackapp --framework-env production --instance-names localhost:chewie --instance-roles localhost:han,solo --instances localhost --stack nginx_unicorn"
    end
  end

  context "with missing arguments" do
    it_should_require :app
    it_should_require :stack
    it_should_require :instances
    it_should_require :framework_env
  end
end
