# Rails4 Template FullStack
Full-Stack application template for Rails 4. **Pull Requests are welcome!**

## Installation
Consider your application name deeply, and then run

```
$ git clone git://github.com/KazuyaHara/Rails4-Template-FullStack.git
$ bundle exec rails new appname -BT -d postgresql -m ./Rails4-Template-FullStack/initialize.rb
$ cd appname
$ bin/rake rails:template LOCATION=../Rails4-Template-FullStack/setup.rb
```

That's it. ```initialize.rb``` handles Gemfile and application general settings. And ```setup.rb``` handles gem settings.

## After Installation
You should ...
- set environment variables such as AWS access keys and buckets to '.env' or to your server.
- set omniauth API key & Secret key to '.env' or to your server. (as needed)
- set slack channel & webhook url to '.env' or to your server. (as needed)
- push your code to the remote repository.
- go to 'circle ci' & 'code climate' and integrate with your remote repository. (as needed)

## Deployment
This template contains ```gem 'rails_12factor'``` so simply work with Heroku. It may run with Puma and Postgresql. And also with Redis if you answered 'yes' to the question ```Use background jobs?```.
