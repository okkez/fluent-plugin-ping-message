require 'fluent/plugin/input'
require 'fluent/mixin/config_placeholders'

class Fluent::Plugin::PingMessageInput < Fluent::Plugin::Input
  Fluent::Plugin.register_input('ping_message', self)

  helpers :timer

  include Fluent::Mixin::ConfigPlaceholders

  config_param :tag, :string, :default => 'ping'
  config_param :interval, :integer, :default => 60
  config_param :data, :string, :default => `hostname`.chomp

  def start
    super
    start_pingloop
  end

  def shutdown
    super
  end

  def start_pingloop
    @last_checked = Fluent::Engine.now
    timer_execute(:in_ping_message_pingpong, 0.5, &method(:pingloop))
  end

  def pingloop
    if Fluent::Engine.now - @last_checked >= @interval
      @last_checked = Fluent::Engine.now
      router.emit(@tag, Fluent::Engine.now, {'data' => @data})
    end
  end
end
