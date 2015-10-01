require "yaml"
require "jumpstart_auth"
module DJ
  class Tweet
    LIMIT = 134
    attr_reader :full_tweet, :tweet_pieces, :jumpstart

    def initialize(input="test tweet BACAW")
      @full_tweet = ARGV[0] || input
      @tweet_pieces = []
      @jumpstart = JumpstartAuth.twitter
    end

    def run
      split_on_tweet_limit(full_tweet)
      delete_white_space
      add_indicies
      tweet
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
      tweet_count = jumpstart.search("allpurposedj").attrs[:statuses].first[:user][:statuses_count]
      puts "currently at #{tweet_count} tweets. Keep up the good work!"
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
  end
end

if __FILE__ == $0
  if ARGV[0] == "authorize"
    DJ::Tweet.authorize
  else
    DJ::Tweet.new.run
  end
end
