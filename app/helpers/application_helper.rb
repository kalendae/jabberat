# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def super_user?
    current_user and (current_user.login == 'tao' or current_user.login == 'kalendae' or current_user.login == 'milener')
  end

  def gravatar_url_for(user, size_class, options = {})
    if user.photo_file_name
      user.photo.url(size_class)
    elsif user.avatar_url
      user.avatar_url
    else
      if (ENV) and (ENV['HOSTNAME']) and (ENV['HOSTNAME'].starts_with? 'vmcentos')
        "/images/default_avatar.jpg"
      else
        url_for({ :gravatar_id => Digest::MD5.hexdigest(user.email), :host => 'www.gravatar.com',
                  :protocol => 'http://', :only_path => false, :controller => 'avatar.php', 'd' => 'http://www.jabberat.com/images/default_avatar.jpg'
                }.merge(options))
      end
    end
  end

  def auto_jabber_link(text)
    auto_link(text, :all, :target => '_blank') do |t|
      slash_parts = t.split('//').last.split('/')
      if slash_parts.size > 1
        slash_parts.first + "/..."
      else
        slash_parts.first
      end
    end
  end

  def notification_html(notification)
    if notification.class == Topic
      topic = notification
      return "#{link_to(image_tag(gravatar_url_for(topic.last_comment.user, :small), :width => 20, :height => 20, :class => 'owner_pic_in_list'),topic.last_comment.user, :class => 'topic_owner_in_list')}#{link_to("<div class='topic_content_in_list' style='margin-left:25px;'>#{topic.last_comment.content}</div>",{:controller => :start, :action => :index, :id => topic}, :class => 'topic_content_link_in_list')}"
    elsif notification.class == Comment
      comment = notification
      return "#{link_to(image_tag(gravatar_url_for(comment.last_reply.user, :small), :width => 20, :height => 20, :class => 'owner_pic_in_list'),comment.last_reply.user, :class => 'topic_owner_in_list')}#{link_to("<div class='topic_content_in_list' style='margin-left:25px;'>#{comment.last_reply.content}</div>",{:controller => :start, :action => :index, :id => comment.topic}, :class => 'topic_content_link_in_list')}"
    end
    ""
  end

  def notification_explanation_html(notification)
    if notification.class == Topic
      topic = notification
      return "#{topic.last_comment.user.login} commented on a topic you created"
    elsif notification.class == Comment
      comment = notification
      return "#{comment.last_reply.user.login} replied to your comment"
    end
    ""
  end

  def activity(act)
    "#{act.user.login} said '#{link_to(act.content, {:controller => :start, :action => :index, :id => act.topic.id}, :class => 'activity_link')}'"
  end

end
