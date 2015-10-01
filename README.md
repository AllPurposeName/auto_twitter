# AutoTwitter
This is a quick app I wrote up to tweet from the command line. It interacts with
the Twitter API through the [JumpstartAuth
gem](https://github.com/JumpstartLab/jumpstart_auth).

##Usage
Pull the repo down and make an alias to open up the file with the second
argument as `ARGV[0]`,
```alias tweet="ruby ~/auto_twitter/lib/tweet.rb" $1```
Tweet from the command line!
![alt text](http://oi62.tinypic.com/21dq33p.jpg "A tweet from the command line")

##TODO
Currently large tweets are posted with `1/*` in succession to each other. A
better way to chain tweets would be to post the first normally and each
subsequent portion of the message as a reply to the first. This requires a bit
more API involvement and I'm lazy right now, so maybe I will get to this when
I'm bored sometime.
