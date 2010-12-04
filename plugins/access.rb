# Give this bot ops in a channel and it'll auto voice
# visitors
#
# Enable with !autoop on
# Disable with !autovoice off

class Access
  include Cinch::Plugin
  def marshal
    ma = Marshal::dump(@@access_list)
    File.open('data/access.dump', 'w') {|f| f.write(ma) }
  end
  class Modes
    attr_accessor :address, :modes
    def initialize(modes)
      @modes = modes
    end
    def op?
      @modes.include?('o')
    end
  end

  listen_to :join, method: :join

  match /test/, method: :test
  match /access set (.+)/, method: :set
  match /access get (.+)/, method: :get
  match /access list/, method: :list
  match /access save/, method: :save
  def initialize(*args)
    super
    if File.exists?('data/access.dump') then
      puts "Loading access list from marshal"
      @@access_list = Marshal::load(File.open('data/access.dump'))
    else
      puts "Access list did not exist"
      @@access_list = {}
      self.marshal
    end
    @admins = ['flexd']
  end
  def test(m)
    m.reply "User.authname: #{m.user.authname}"
  end
  def save(m)
    self.marshal
    m.reply "Access list has been saved to disk!"
  end
  def check_user(user)
    user.refresh
    @admins.include?(user.nick)
  end
  def set(m, arg)
    return unless check_user(m.user)
    target, modes = arg.split(/ /, 2) # Get the target and modes wanted
    modes = modes.split(/ /)[0] # To make sure we just have one argument there.
   # m.reply "User is: #{user.inspect}"
    @@access_list[target] = Modes.new(modes)
   # @@access_list << User.new(target, modes) unless @@access_list.include?(target)
    m.reply "Set #{target}'s modes to: #{modes}"
    self.marshal
  end
  def get(m, arg)
    return unless check_user(m.user)
    if @@access_list.include?(arg) then
      m.reply "#{arg}'s modes are: #{@@access_list[arg].modes}"
    else
      m.reply "That user does not have any modes defined"
    end
  end
  def del(m, arg)
  
  end
  def list(m, arg)
    m.reply "Access list:"
  end
  def join(m)
    m.user.refresh
    if m.channel.opped?(@bot.nick) then
      if @@access_list[m.user.nick] then
        # Person has access rights
        @@access_list[m.user.nick].modes.each_char do |c|
          case c
            when "o" 
              m.channel.op(m.user.nick)
            when "v" 
              m.channel.voice(m.user.nick)
            else
              puts "Unhandled mode"
          end
        end
      end
    end
  end
  def listen(m)
    unless m.user.nick == bot.nick
      m.channel.voice(m.user) if @autovoice
    end
  end

  #def execute(m, option)
   # m.reply "You triggered me"
    #@autovoice = option == "on"

    #m.reply "Autovoice is now #{@autovoice ? 'enabled' : 'disabled'}"
  #end
end