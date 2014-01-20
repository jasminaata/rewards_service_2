require_relative 'eligibility_service'

module AccountManagement
  class RewardsService
    def initialize(account, subscriptions)
      @account = account
      @subscriptions = normalize_subscriptions(subscriptions)
    end

    def normalize_subscriptions(subscriptions)
      subscriptions.map { |sub| sub.upcase! }
    end

    def perform
      return response.description unless eligible? 
      get_rewards  
    end

    def response
      @response ||= CustomerStatus::EligibilityService.new(@account)
    end

    def eligible?
      response.output == "CUSTOMER_ELIGIBLE"
    end

    def get_rewards
      rewards = []
      @subscriptions.each { |sub| rewards.push(rewards_map[sub]) unless rewards_map[sub] == "N/A" } 
      rewards
    end 

    def rewards_map
      {
        "SPORTS" => "CHAMPIONS_LEAGUE_FINAL_TICKET",
        "KIDS" => "N/A",
        "MUSIC" => "KARAOKE_PRO_MICROPHONE",
        "NEWS" => "N/A",
        "MOVIES" => "PIRATES_OF_THE_CARIBBEAN_COLLECTION",
      }
    end
  end
end