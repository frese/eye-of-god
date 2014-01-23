#-----------------------------------------------------------------
# Amazon SQS driver for collector
#
require "right_aws"

class SqsDriver
    attr :log
    attr :queue
    attr :options

    def initialize(options, log)
        @queue   = nil
        @sqs     = nil
        @options = options
        @log     = log

        @log.debug("options = #{options.inspect}")
    end

    def connect
        @sqs = RightAws::SqsGen2.new(@options['access-key'], @options['secret-key'], { :server => @options['url']})
        @log.debug( "SQS Created: " + @sqs.inspect)

        @queue = @sqs.queue(@options['queue'])
        @log.debug( "Queue Created: " + @queue.url)

    end

    def disconnect
    end

    def publish(data)
        msg = @queue.push(data)
        @log.info("message sent : #{msg.id}")
    end

    def subscribe()

        @log.debug('polling for messages ...')
        while true
            msg = @queue.pop()
            if msg.nil?
                sleep(5)
                next
            else
                yield msg.body
            end
        end
    end
end
