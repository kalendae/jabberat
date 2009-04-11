# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def super_user?
    current_user and (current_user.login == 'tao' or current_user.login == 'kalendae' or current_user.login == 'scott')
  end

  def gravatar_url_for(user, options = {})
    if user.avatar_url.blank?
      if (ENV) and (ENV['HOSTNAME']) and (ENV['HOSTNAME'].starts_with? 'vmcentos')
        "/images/default_avatar.jpg"
      else
        url_for({ :gravatar_id => Digest::MD5.hexdigest(user.email), :host => 'www.gravatar.com',
                  :protocol => 'http://', :only_path => false, :controller => 'avatar.php', 'd' => 'http://www.jabberat.com/images/default_avatar.jpg'
                }.merge(options))
      end
    else
      user.avatar_url
    end
  end

end
