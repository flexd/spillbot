class State
  include Cinch::Plugin
  
#  listen_to :channel, method: :join

  match /state/, method: :state
  def state(m)
    m.reply "Noe spennende!"
    m.reply "#{@bot.channels.inspect}"
  end
end