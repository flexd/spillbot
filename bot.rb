require 'rubygems'
require 'bundler/setup'
require 'cinch'
require 'require_all'
require_all 'plugins'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "spillbot"
    c.server          = "irc.coldfront.net"
    c.verbose         = true
    c.plugins.plugins = [Access]
  end

  on :connect do
    bot.join "#test"
  end
end
bot.start