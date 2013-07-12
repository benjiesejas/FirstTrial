class ApplicationController < ActionController::Base
  #protect_from_forgery
  before_filter :set_account, :authenticate
    protected
    def set_account
      @account = Account.find_by(url_name: request.subdomains.first)
    end

    def authenticate
      case request.format
      when Mime::XML, Mime::ATOM
        if user = authenticate_with_http_basic { |u, p| @account.users.authenticate(u, p) }
          @current_user = user
        else
          request_http_basic_authentication
        end
      else
        if session_authenticated?
          @current_user = @account.users.find(session[:authenticated][:user_id])
        else
          redirect_to(login_url) and return false
        end
      end
    end
end
