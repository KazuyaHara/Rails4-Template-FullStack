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
- set environment variables such as AWS access keys and buckets.
