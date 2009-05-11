class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://jabberAt.com/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://jabberAt.com/"
  end

  def invite(current_user, emails, content)
    @recipients  = "#{emails}"
    @from        = "hello@jabberAt.com"
    @subject     = "#{current_user.login} has invited you to a tawk conversation"
    @sent_on     = Time.now
    @body[:content] = content
    @content = content
  end

  def notify(user,users,topic,comment)
    @bcc = "#{users.collect{|u| u.email}.join(",")}"
    @from = "hello@jabberAt.com"
    @subject = "#{user.login} replied to a Tawk conversation you were part of"
    @sent_on = Time.now
    @topic = topic
    @user = user
    @comment = comment
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "hello@jabberAt.com"
      @subject     = "[jabberAt] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
