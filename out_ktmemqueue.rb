module Fluent
  class KtMemQueueOutput < BufferedOutput
    Fluent::Plugin.register_output('ktmemqueue', self)
    attr_reader :host, :port, :inputkey, :expire

    def initialize
      super
      require 'memcached'
      require 'msgpack'
    end

    def configure(conf)
      super

      @host = conf.has_key?('host') ? conf['host'] : 'localhost'
      @port = conf.has_key?('port') ? conf['port'].to_i : 11211
      @inputkey = conf.has_key?('inputkey') ? conf['inputkey'].to_s : 'fluent-plugin-ktmemqueue'
      @expire = conf.has_key?('expire') ? conf['expire'].to_i : 0

    end

    def start
      super

      @connect = @host.to_s + ":" + @port.to_s
      @memcached = Memcached.new(@connect)
      @memcached.set @inputkey, "fluent-plugin-ktmemqueue start", @expire, false
    end

    def shutdown
      @memcached.set @inputkey, "fluent-plugin-ktmemqueue end", @expire, false
      @memcached.quit
    end

    def format(tag, time, record)
      [tag, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each do |tag, record|
        @memcached.set @inputkey, tag.to_s + " " + record.to_s, @expire, false
      end
    end
  end
end

