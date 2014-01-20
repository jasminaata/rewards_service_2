require_relative "../rewards_service"

describe AccountManagement::RewardsService do 
  describe "it checks customer rewards" do
    let(:account) { 000731 }
    let(:subscriptions) { ["Sports", "Kids", "Music"] }
    let(:rewards_service) { AccountManagement::RewardsService.new(account, subscriptions) }

    before do
      CustomerStatus::EligibilityService.stub(:new)
        .and_return(double "EligibilityService", 
          output: "CUSTOMER_ELIGIBLE",
          description: "Customer is eligible")  
    end
     
    context "account is eligible" do
      describe "for a mix of channels" do
        it "outputs rewards data for mixed channels" do
          rewards_service.perform.should == ["CHAMPIONS_LEAGUE_FINAL_TICKET", "KARAOKE_PRO_MICROPHONE"]
        end
      end

      describe "for sports channel only" do
        let(:subscriptions) { ["Sports"] }
        it "outputs rewards data for sports channel" do
          rewards_service.perform.should == ["CHAMPIONS_LEAGUE_FINAL_TICKET"]
        end
      end

      describe "for no rewards channel" do
        let(:subscriptions) { ["Kids"] }
        it "outputs no rewards data" do
          rewards_service.perform.should == []
        end
      end
    end

    context "account is not eligible" do
      before do
        CustomerStatus::EligibilityService.stub(:new)
          .and_return(double "EligibilityService", 
            output: "CUSTOMER_INELIGIBLE",
            description: "Customer is not eligible")  
      end

      it "outputs ineligibility message" do
        rewards_service.perform.should == "Customer is not eligible"
      end
    end

    context "there is technical error" do
      before do
        CustomerStatus::EligibilityService.stub(:new)
          .and_return(double "EligibilityService", 
            output: "Technical failure exception",
            description: "Service technical failure")  
      end

      it "outputs technical failure message" do
        rewards_service.perform.should == "Service technical failure"
      end
    end

    context "account is not valid" do
      before do
        CustomerStatus::EligibilityService.stub(:new)
          .and_return(double "EligibilityService", 
            output: "Invalid account number exception",
            description: "The supplied account number is invalid")  
      end

      it "outputs invalid account message" do
        rewards_service.perform.should == "The supplied account number is invalid"
      end
    end
  end  
end