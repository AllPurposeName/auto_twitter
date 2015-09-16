require "yaml"
require "jumpstart_auth"
module DJ
  class Tweet
    unless ARGV[1].nil? || ARGV[1].empty?
      SETTINGS_FILE_PATH =  ARGV[1]
    else
      SETTINGS_FILE_PATH = "../settings/twitter_settings.yml"
    end

    LIMIT = 134
    attr_reader :full_tweet, :tweet_pieces, :jumpstart

    def self.authorize
      @credentials = {
        :consumer_key => "beXya6tT8EwNBtaFokBDtgIaO",
        :consumer_secret => "LinWFjVaR5pUlmDaaIadPMh1BUBUkrfIi4Jr0Wc0BbXlW90wuw"
      }
      consumer = OAuth::Consumer.new(@credentials[:consumer_key], @credentials[:consumer_secret], :site => "https://twitter.com")
      request_token = consumer.get_request_token
      printf "Enter the supplied pin: "
      Launchy.open(request_token.authorize_url)
      pin = STDIN.gets.chomp
      access_token = request_token.get_access_token(:oauth_verifier => pin)
      @credentials[:access_token]      = access_token.token
      @credentials[:access_token_secret] = access_token.secret

      self.write_settings
    end

    def self.write_settings
      settings = File.open(SETTINGS_FILE_PATH, "w")
      settings << @credentials.to_yaml
      settings.close
      @credentials
    end

    def initialize(input="test tweet BACAW")
      @full_tweet = ARGV[0] || input
      @tweet_pieces = []
      @jumpstart = JumpstartAuth.twitter
    end

    def add_indicies
      @tweet_pieces.map!.with_index do |message, index|
        if just_one?
          return message
        else
          message + indicies(index) unless just_one?
        end
      end
    end

    def indicies(index)
      " [#{index + 1}/#{@tweet_pieces.count}]"
    end

    def split_on_tweet_limit(tweets)
      if within_limit?(tweets)
        tweets.split.each_with_object("").with_index do |(word, sentence), index|
          if combined_under_limit(sentence, word)
            sentence << " " unless index == 0
            sentence << word
          else
            @tweet_pieces << sentence
            tweets = tweets.sub(sentence, "")
            split_on_tweet_limit(tweets)
            break
          end
        end
      else
        @tweet_pieces << tweets
      end
      @tweet_pieces
    end

    def run
      split_on_tweet_limit(full_tweet)
      delete_white_space
      add_indicies
      align_settings_with_jumpstart_auth
      tweet
    end

    def delete_white_space
      @tweet_pieces.each do |message|
        while message.start_with?(" ")
          message.sub!(" ", "")
        end
      end
    end

    private

    def tweet
      @tweet_pieces.each do |message|
        jumpstart.update(message)
        puts "successfully tweeted: #{message}"
      end
      count = jumpstart.search("allpurposedj").attrs[:statuses].first[:user][:statuses_count]
      puts "currently at #{count} tweets. Keep up the good work!"
    end

    def just_one?
      @tweet_pieces.count <= 1
    end

    def within_limit?(tweets)
      tweets.length > LIMIT
    end

    def combined_under_limit(sen, word)
      sen.length + word.length + 1 <= LIMIT
    end

    def align_settings_with_jumpstart_auth
      keys = YAML.load_file(SETTINGS_FILE_PATH)
      jumpstart.consumer_key        = keys[:consumer_key]
      jumpstart.consumer_secret     = keys[:consumer_secret]
      jumpstart.access_token        = keys[:access_token]
      jumpstart.access_token_secret = keys[:access_token_secret]
    end
  end
end

if __FILE__ == $0
  if ARGV[0] == "authorize"
    DJ::Tweet.authorize
  else
    DJ::Tweet.new.run
  end
end
