require 'minitest/autorun'
require 'minitest/pride'
require './lib/tweet'

class TweetTest < Minitest::Test
  LIMIT = 134

  def chars_210
    "this is a tweet of 210 characters. I intend to tweet things out this much as long as I can parse it correctly. Tweeting this much is pretty silly, but that's the nature of tweeting, amirite? GG! #test_it_exists"
  end

  def chars_400
    "this message is supposed to be 400 character longs for a test which won't actually tweet but will check the index additions of a tweet, but first it will separate the message into chunks which can have an addition of an index without spoiling the message. The original untested implementation would cut words off and continue them in a later tweet which was very annoying. Only 28 more characters!!!!"
  end

  def test_it_exists
    assert DJ::Tweet
  end

  def test_is_has_a_full_tweet
    test_message = "hello twitter world"
    tweeter      = DJ::Tweet.new(test_message)
    assert_equal test_message, tweeter.full_tweet
  end

  def test_it_parses_special_characters
    skip
    "until I can find a way to force use string literals, I can't complete this one"
    tweeter      = DJ::Tweet.new
    unparsed_message = "`git push -F` would be followed by a bang(\!) in \"Ruby\""
    parsed_message = '<git push -F> would be followed by a bang(!) in "Ruby"'

    assert_equal parsed_message, tweeter.special_character_parse(unparsed_message)
  end

  def test_it_does_not_cut_apart_a_short_tweet
    tweeter = DJ::Tweet.new
    message = "hello (twitter) world!"

    assert_equal [message], tweeter.split_on_tweet_limit(message)
  end

  def test_it_correctly_cuts_apart_a_long_tweet
    half_message = "this is a tweet of 210 characters. I intend to tweet things out this much as long as I can parse it correctly. Tweeting this much is"
    tweeter      = DJ::Tweet.new

    assert_equal half_message, tweeter.split_on_tweet_limit(chars_210).first
    assert_under LIMIT, tweeter.split_on_tweet_limit(chars_210).first.length
  end

  def test_it_forgoes_appending_split_number_to_short_tweets
    tweeter = DJ::Tweet.new
    message = ["hello (twitter) world!"]

    tweeter.instance_variable_set(:@tweet_pieces, message)
    tweeter.add_indicies
    assert_equal message, tweeter.tweet_pieces
  end

  def test_it_appends_split_number_to_long_tweets
    tweeter                = DJ::Tweet.new
    messages               = ["hello (twitter)...", "world!"]
    messages_with_indicies = ["hello (twitter)... [1/2]", "world! [2/2]"]

    tweeter.instance_variable_set(:@tweet_pieces, messages)
    tweeter.add_indicies

    assert_equal messages_with_indicies, tweeter.tweet_pieces
  end

  def test_it_deletes_white_space
    tweeter         = DJ::Tweet.new
    control_message = "hello"
    short_message   = "   hello"
    long_message    = "            hello this is the end of the conversation but thank you very much for calling us ehre at gentech securites, we hope you always look to gentech when you look to secure things"
    long_answer     = "hello this is the end of the conversation but thank you very much for calling us ehre at gentech securites, we hope you always look to gentech when you look to secure things"


    tweeter.instance_variable_set(:@tweet_pieces, [control_message])
    tweeter.delete_white_space
    assert_equal control_message, tweeter.tweet_pieces.first
    tweeter.instance_variable_set(:@tweet_pieces, [short_message])
    tweeter.delete_white_space
    assert_equal control_message, tweeter.tweet_pieces.first
    tweeter.instance_variable_set(:@tweet_pieces, [long_message])
    tweeter.delete_white_space
    assert_equal long_answer, tweeter.tweet_pieces.first
  end

  def test_it_works_with_a_very_long_message
    tweeter      = DJ::Tweet.new
    last_message = "characters!!!! [4/4]"
    tweeter.split_on_tweet_limit(chars_400)
    tweeter.delete_white_space
    tweeter.add_indicies

    assert_equal 4, tweeter.tweet_pieces.count
    assert_equal last_message, tweeter.tweet_pieces[3]
  end

  def assert_under(expected, actual)
    assert expected >= actual
  end
end

