a)Required: Ruby (1.9.3), bundler, mongodb ( Mac OSX)

b)Prerequisites:
1)Start `mongod` locally
2)Go inside app directory and run
       `bundle install`
   This will install all the required gems(ie; Gems mentioned in Gemfile)


c)Running the app locally:

`bundle exec rackup config.ru -p 4567`