#-----------------------------------------------------------------
# Bunny driver for collector
#

require "openssl"
require "bunny"

class BunnyDriver
    attr :log
    attr :bunny
    attr :queue
    attr :exchange
    attr :ctx
    attr :options

    def initialize(options, log)
        @bunny    = nil
        @queue    = nil
        @exchange = nil
        @ctx      = false
        @options  = options
        @log      = log

        @log.debug("options = #{options.inspect}")
    end

    def connect
        retries = 3
        if @options['ssl']
            # Prepare the ssl certificate
            @log.debug("Setting up SSL context")
            @ctx      = OpenSSL::SSL::SSLContext.new
            @ctx.cert = OpenSSL::X509::Certificate.new(File.open(@options['certificate']))
            @ctx.key  = OpenSSL::PKey::RSA.new(File.open(@options['key']))
        end
        begin
            log.debug("Starting bunny.")
            @bunny = Bunny.new(:user => @options['user'], 
                               :pass => @options['password'], 
                               :host => @options['server'], 
                               :port => @options['port'], 
                               :ssl  => @ctx, :verify_ssl => false, :connect_timeout => 5)
            @bunny.start 
        rescue 
            exit if retries <= 0
            @log.error("Cannot start bunny (#{$!}), retry in 2 sec")
            sleep(2)
            retries -= 1
            retry
        end
        @log.debug("Connecting to queue #{@options['queue']}")
        @exchange = @bunny.exchange(@options['queue'], :durable => true)
        @queue    = @bunny.queue(@options['queue'], :durable => true)
        @queue.bind(@exchange, :key => @options['queue'])
    end

    def disconnect
        @bunny.stop
    end

    def publish(data)
        @exchange.publish(data, :key => @options['queue'])
    end

    def subscribe()
        @queue.subscribe(:timeout => 120) do |msg|
            yield msg[:payload]
        end
    end

end
