#-----------------------------------------------------------------
# Bunny driver for collector
#
$:.unshift("/home/air/lib/ruby")

require "rubygems"
require "openssl"
require "stomp"

class StompDriver
    attr :log
    attr :bunny
    attr :queue
    attr :exchange
    attr :ctx
    attr :options

    def initialize(options, log)
        @connection = nil
        @client     = nil
        @queue      = nil
        @exchange   = nil
        @ctx        = false
        @options    = options
        @log        = log

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
            log.debug("Starting stomp.")

            pools = @options["stomp.pool.size"].to_i
            hosts = []

            1.upto(pools) do |poolnum|
                host = {}

                host[:host]     = @options["stomp.pool.host#{poolnum}"]
                host[:port]     = @options["stomp.pool.port#{poolnum}"].to_i
                host[:login]    = @options["stomp.pool.user#{poolnum}"]
                host[:passcode] = @options["stomp.pool.password#{poolnum}"]
                host[:ssl]      = @options["stomp.pool.ssl#{poolnum}"]

                @log.debug("Adding #{host[:host]}:#{host[:port]} to the connection pool")
                hosts << host
            end
            raise "No hosts found for the STOMP connection pool" if hosts.size == 0


            # @connection = Stomp::Connection.new( {:hosts => hosts, :logger => @log} )
            @client = Stomp::Client.new(@options['url'])
            
            # @options['user'], @options['password'], @options['server'], @options['port'], true)

            # @client = Stomp::Client.new({ :user       => @options['user'], 
            #                               :passcode   => @options['password'], 
            #                               :host       => @options['server'], 
            #                               :port       => @options['port'], 
            #                               :ssl        => @ctx, 
            #                               :verify_ssl => false, 
            #                               :connect_timeout => 5 } )
        # rescue 
        #     exit if retries <= 0
        #     @log.error("Cannot start stomp driver (#{$!}), retry in 2 sec")
        #     sleep(2)
        #     retries -= 1
        #     retry
        end
    end

    def disconnect
        # @connection.disconnect
        @client.close
    end

    def publish(data)
        @log.debug("about to publish data [#{data}]")
        @client.publish(@options['queue'], data)
        # @connection.send(@options['queue'], data)
    end

    def subscribe()
        @connection.subscribe(@options['queue'], {:ack => :client}) do |msg|
            yield msg
        end
        @connection.join
    end

end
