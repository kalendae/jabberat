#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/boot'
require RAILS_ROOT + '/config/environment'

@error_file = "queue_handler_errors.log"
@log_file = "queue_handler.log"

def stop_int
  puts "INT signal received. should shutdown soon."
  @stop = true
  @stop_reason = 'INT'
end

def stop_term
  puts "TERM signal received. should shutdown soon."
  @stop = true
  @stop_reason = 'TERM'
end

@stop = false
@stop_reason = ''
Signal.trap 'INT' do
  stop_int
end
Signal.trap 'TERM' do
  stop_term
end

def log str
    File.open(@log_file,'a') do |f|
        f.puts str
    end
    puts str
end

def log_error str
    File.open(@error_file,'a') do |f|
        f.puts str
    end
    puts
end

processed = 0
errors = 0
sleep_duration = 1
MAX_SLEEP = 16

puts "starting thread to process queue"
#mc_servers = YAML.load(File.open('config/memcache.yml'))
#qmcc=MemCache.new(mc_servers['qmcc'])
#adgen_server= File.read('config/adgen_server.cfg').strip

while @stop == false
    items = QueueItem.find(:all, :order => :id)
    begin
        if items.blank?
          log "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] no more in queue, sleeping for #{sleep_duration}! processed: #{processed}, errors: #{errors}"
          sleep sleep_duration
          sleep_duration *= 2
          sleep_duration = MAX_SLEEP if sleep_duration > MAX_SLEEP
        else
          sleep_duration = 1
          items.each do |item|
            begin
              item.destroy
              comment = Comment.find item.content
              comment.notify_all_past_users_in_topic
              processed += 1
            rescue Exception => e
              errors += 1
              log_error "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] Error for [#{item.id}][#{item.queue_type}][#{item.content}] Exception: #{e.inspect} #{e.backtrace}"
            end
          end
        end
    rescue Exception => e
      errors += 1
      log_error "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] Exception: #{e.inspect} #{e.backtrace}"
    end
    if (processed % 100) == 0
        log "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] processed: #{processed}, errors: #{errors}"
    end
    STDOUT.flush
end

puts "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] finished running!"
puts "processed #{processed} emails"
puts "errored #{errors} emails"
