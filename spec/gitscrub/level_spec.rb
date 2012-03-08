require 'spec_helper'
require 'grit'

describe Gitscrub::Level do
  
  before(:each) do
    @file = <<-eof
difficulty 1
description "A test description"
setup do
  "test"
end
solution do
  Grit::Repo.new("gitscrub/notadir")
end
    eof
    File.stub(:exists?).and_return(true)
    File.stub(:read).and_return(@file)
    @level = Gitscrub::Level.load(1)
    @repo = mock
    @repo.stub(:reset) 
    Gitscrub::Repository.stub(:new).and_return(@repo)
  end

  it "should mixin UI" do
    Gitscrub::Level.ancestors.should include(Gitscrub::UI)
  end


  describe "load" do
    
    it "should load the level" do
      File.stub(:dirname).and_return("")
      File.should_receive(:read).with('/../../levels/init.rb').and_return(@file)
      level = Gitscrub::Level.load(1)
      level.instance_variable_get("@difficulty").should eql(1)
      level.instance_variable_get("@description").should eql("A test description")
    end

    it "should return false if the level does not exist" do
      File.stub(:exists?).and_return(false)
      Gitscrub::Level.load(1).should eql(false)
    end

  end


  describe "solve" do
    
    it "should solve the problem" do
      @level.solve.should eql(false)
    end

    it "should return true if the requirements have been met" do
      Grit::Repo.stub(:new).and_return(true) 
      @level.solve.should eql(true)
    end

  end


  describe "full_description" do

    it "should display a full description" do
      Gitscrub::UI.stub(:puts)
      Gitscrub::UI.should_receive(:puts).with("Level: 1")
      Gitscrub::UI.should_receive(:puts).with("Difficulty: *")
      Gitscrub::UI.should_receive(:puts).with("A test description")
      @level.full_description
    end

  end

  describe "setup" do

    it "should call setup" do
      @level.setup_level.should eql("test") 
    end

    it "should not call the setup if none exists" do
      @level.instance_variable_set("@setup", nil)
      lambda {@level.setup_level}.should_not raise_error(NoMethodError)
    end

  end
  

  describe "repo" do
      
    it "should initialize a repository when repo is called" do
      @level.repo.should equal(@repo)
      Gitscrub::Repository.should_not_receive(:new)
      @level.repo.should equal(@repo)
    end

    it "should call reset on setup_level" do
      @repo.should_receive(:reset) 
      @level.setup_level
    end

  end


  
end
