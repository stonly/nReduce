require 'spec_helper'

describe Checkin do
  before :all do
    @user = FactoryGirl.create(:user)
    @checkin = Checkin.new(:user_id => @user.id, :start_comments => 'Make awesome happen')
    @valid_youtube_url = 'http://www.youtube.com/watch?v=4vkqBfv8OMM'
  end

  it "should allow valid youtube urls" do
    @checkin.start_video_url = 'http://www.youtube.com/watch?v=4vkqBfv8OMM'
    @checkin.errors.on(:start_video_url).should be_nil

    @checkin.start_video_url = 'http://youtu.be/Q8FPOcHZSnU'
    @checkin.errors.on(:start_video_url).should be_nil

    @checkin.start_video_url = 'http://www.youtube.com/embed/tsh8xvjtalo'
    @checkin.errors.on(:start_video_url).should be_nil
  end

  it "should not allow invalid youtube urls" do
    @checkin.start_video_url = 'http://google.com'
    @checkin.errors.on(:start_video_url).should == "invalid Youtube URL"

    @checkin.start_video_url = 'http://www.youtube.com/testvideo'
    @checkin.errors.on(:start_video_url).should == "invalid Youtube URL"

    @checkin.start_video_url = 'http://youtube.fakeurl.com/watch?v=4vkqBfv8OMM'
    @checkin.errors.on(:start_video_url).should == "invalid Youtube URL"
  end

  it "should never change the timestamp on submitted at date" do
    @checkin.start_video_url = @valid_youtube_url
    @checkin.save
    submitted_at = @checkin.submitted_at
    # Make sure submitted as isn't nil
    submitted_at.should_not be_nil

    # Assign new video
    @checkin.start_video_url = 'http://youtu.be/Q8FPOcHZSnU'
    @checkin.save

    @checkin.submitted_at.should == submitted_at
  end

  it "should never change the timestamp on completed at date" do
    @checkin.start_video_url = @valid_youtube_url
    @checkin.end_video_url = @valid_youtube_url
    @checkin.end_comments = 'Made it happen!'
    @checkin.save.should be_true

    completed_at = @checkin.completed_at
    @checkin.end_video_url = 'http://www.youtube.com/watch?v=R72kxEmB3EE&feature=g-logo-xit'
    @checkin.save.should be_true

    @checkin.completed_at.should == completed_at
  end

  it "should notify this startup's relationships when they complete a checkin" do
    pending
  end
end
