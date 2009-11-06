#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/boot'
require RAILS_ROOT + '/config/environment'

@error_file = "weekly_update_errors.log"
@log_file = "weekly_update.log"

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

log "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] starting weekly update process"

begin
  # find top 5 topics to send TODO: we can make this more personalized later for each user and use this as default only
  topics = Topic.find(:all, :joins=>[:comments], :conditions=>['topics.updated_at > ?',(Time.now - 1.week)],
           :order => 'count(comments.id) desc', :limit=>5, :group => 'topics.id')
  if topics.blank?
    log_error "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] No hot topics found for this week}"
  else
    users = User.find_all_by_subscribe(true)
    users.each do |user|
      begin
        UserMailer.deliver_weekly(user,topics)
        log "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] weekly update sent to #{user.login} at #{user.email}"
      rescue
        log_error "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] Per User Exception [#{user.login}] [#{user.email}]: #{e.inspect} #{e.backtrace.join("\n     ")}"
      end
    end
  end
rescue
  log_error "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] General Exception: #{e.inspect} #{e.backtrace.join("\n     ")}"
end

log "[#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}] ending weekly update process"