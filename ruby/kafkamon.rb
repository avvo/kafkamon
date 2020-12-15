AvvoKafka.configure do |c|
  c.kafka_hosts = ENV.fetch('KAFKA2_HOSTS')
  c.schema_registry_url = ENV.fetch('SCHEMA_REGISTRY_BASE_URL')
end

class Kafkamon < Sinatra::Base
  set :server, :puma
  set :streams, []

  get '/' do
    erb :index
  end

  get '/stream' do
    content_type 'text/event-stream'
    stream :keep_open do |out|
      settings.streams << out
      out.callback do
        puts 'stream closed'
        settings.streams.delete(out)
      end
    end
  end

  Thread.new do
    AvvoKafka.consume(topic: 'directory-attorney-availability', group_id: Time.now.to_s) do |message|
      streams.each do |stream|
        stream << "event: message\n\n"
        stream << "data: #{JSON.generate(message.value).strip}\n\n"
      rescue => e
        puts e.message
      end
    rescue Kafka::ProcessingError
      retry
    end
  end
end
