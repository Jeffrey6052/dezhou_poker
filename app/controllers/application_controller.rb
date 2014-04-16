
class ApplicationController < Sinarey::Application

  helpers ApplicationHelper

  set :views, ['application']
  
  before do
    @temp = {}
    @temp[:request_time] = Time.now
    verify_authenticity_token #防止CSRF
    #check_current_user
  end

  after do
    server_time = ((Time.now-@temp[:request_time])*1000).to_i
    writelog "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"+" | _#{response.status}_ | "+"#{server_time}".ljust(3)+"ms | #{get_client_ip}"+" | #{request.request_method.ljust(4)}"+" | #{request.url}"
  end

  error do
    dump_errors
    erb :'500'
  end

  not_found { erb :'404' }

  def verify_authenticity_token
    if request.get? or form_authenticity_token==env['HTTP_X_CSRF_TOKEN']
      @temp[:is_csrf] = false
    else
      if params[:_csrf_token] and form_authenticity_token==params[:_csrf_token]
        @temp[:is_csrf] = false
      else
        @temp[:is_csrf] = true
      end
    end
    @temp[:is_csrf]
  end

  def skip_verify_authenticity_token
    @temp[:is_auth] = true
  end

  def check_current_user 
    if login_state = login_from_session || login_from_cookie
      if login_state[:res]
        @current_user = login_state[:user]
        @current_uid = @current_user.id
      end
    end
  end

  def set_login_state(user,options={})
    if options[:remember_me]
      #用户id|失效时间|hash值。 hash值由"用户id+失效时间+ip地址+用户密码（加密后的）的前几位+salt"  
      digest_str = "#{user.id}|#{get_client_ip}|#{user.encrypted_password.first(6)}|#{Sinarey.secret}"
      remember_me = "#{user.id}|#{Digest::SHA2.hexdigest(digest_str)}"
      set_cookies(:remember_me, remember_me, expires: 2.week.from_now)
    end
    set_login_session(user)
  end

  def clear_login_state
    return if !@temp[:is_auth] and @temp[:is_csrf]
    delete_session(:user)
    delete_cookies(:remember_me)
  end

  def set_login_session(user)
    #用户id|用户昵称|hash值。 hash值由"用户id+ip地址+用户密码（加密后的）的前六位+salt"
    digest_str = "#{user.id}|#{get_client_ip}|#{user.encrypted_password.first(6)}|#{Sinarey.secret}"
    set_session(:user, {id:user.id,secrue:Digest::SHA2.hexdigest(digest_str)} )
  end

  def set_session(symbol,value)
    return if @temp[:is_auth].blank? and @temp[:is_csrf]
    env['rack.session.options'].merge! domain: get_master_domain
    session[symbol] = value
  end

  def delete_session(symbol)
    return if @temp[:is_auth].blank? and @temp[:is_csrf]
    env['rack.session.options'].merge! domain: get_master_domain
    session[symbol] = nil
  end

  def set_cookies(key,value,options={})
    return if @temp[:is_auth].blank? and @temp[:is_csrf]
    cookies.store(key, value, {domain:get_master_domain}.merge(options))
  end

  def delete_cookies(key)
    return if @temp[:is_auth].blank? and @temp[:is_csrf]
    cookies.remove(key, domain: get_master_domain)
  end

  def login_from_session
    return if @temp[:is_auth].blank? and @temp[:is_csrf]
    return if ( token = session[:user] ).blank?
    uid, secrue = token[:id], token[:secrue]
    return if uid.blank? or secrue.blank?
    user = User.find_lru_user(uid)
    if user.nil?
      delete_session(:user)
      return {res:false}
    end
    #DONE 验证session的安全性
    str = "#{uid}|#{get_client_ip}|#{user.encrypted_password.first(6)}|#{Sinarey.secret}"
    if Digest::SHA2.hexdigest(str) != secrue
      return {res:false,msg:'为了保护您的账号安全，请重新登录'}
    end
    return {res:true,user:user}
  end

  def login_from_cookie
    return if !@temp[:is_auth] and @temp[:is_csrf]
    return if cookies[:remember_me].blank?

    uid,secrue = cookies[:remember_me].split('|')
    return if uid.blank? or secrue.blank?

    if ( user = User.find_lru_user(uid) ).nil?
      return {res:false}
    end

    #DONE 验证cookie的安全性
    str = "#{uid}|#{get_client_ip}|#{user.encrypted_password.first(6)}|#{Sinarey.secret}"
    if Digest::SHA2.hexdigest(str) != secrue
      return {res:false,msg:'为了保护您的账号安全，请重新登录'}
    end
    set_login_session(user)
    return {res:true,user:user}
  end

  def redirect_back_or_default(default)
    custom_return_to = params[:return_to]
    #TODO 验证链接主域名，添加域名白名单
    #TODO 不符合的链接，跳转到安全提示页
    domains = ['suixin365.com','520hub.com']
    if custom_return_to.present?
      return_to = custom_return_to
    else
      return_to = default
    end
    redirect return_to, 303
  end

  

  def get_client_ip
    @temp[:client_ip] ||= env['X-Real-IP'] || request.ip
  end

  def get_master_domain
    @temp[:master_domain] ||= begin
      request.host.split('.')[1..-1].join('.')
    rescue
      ''
    end
  end

  def get_location(ip)
    return {} if ip.blank?
    temp = @temp[:"loc#{ip}"]
    return temp if temp
    ip_score = 0
    ip.split(".").each_with_index { |ip,index| ip_score +=(ip.to_i)*(256**(3-index)) }
    record = IpTable.select('province_name,city_name').where(["start_at<=? and end_at >= ?",ip_score,ip_score]).first
    return {} if record.nil?
    temp = {province:record.province_name,city:record.city_name}
  end

  #未登录
  def render_400
    halt 400,'未登录'
  end

  #没有权限
  def render_401
    halt 401,'你没有权限进行该操作'
  end

  #资源不存在
  def render_404(msg='')
    halt 404,msg
  end

  #操作失败
  def render_500(msg='')
    halt 500,msg
  end

  #请求有误
  def render_412(msg='')
    text = "参数错误。"
    text += " #{msg}" if msg
    halt 412,text
  end

  def render_json(json)
    content_type :json
    Oj.dump(json, mode: :compat)
  end

  def render_to_string(options)
    partial = options.delete(:partial)
    args = {layout:false}.merge(options)
    erb partial, args
  end

  def redirect_to_login
    set_session(:return_to, request.fullpath)
    redirect '/login/signin',303
  end

  def set_seo_meta(title = nil, meta_description = nil, meta_keywords = nil)
      default_description = "随心社区,是一个自由自在的网络社区。"
      default_keywords = "随心社区,随心365,网络社区,社区"
      @page_title = "#{title} - 随心社区" if title.present?
      @page_description = meta_description || default_description    
      @page_keywords = meta_keywords || default_keywords
  end

  def oauth2_callback

    success  = params[:success]=='true' || false
    txt      = params[:txt] || nil
    style    = params[:style] || nil
    return_to = session[:return_to]

    erb :_oauth2_callback, locals:{success:success,txt:txt,style:style,return_to:return_to}
  end

  #跨域登陆，params: remember_me, uid, secrue
  def cross_domain_authorize

    if @current_user.nil?
      uid = params[:uid].to_i
      render_json({res:false,msg:'登陆失败'}) unless uid > 0

      if params[:remember_me].present?
        set_cookies(:remember_me, params[:remember_me], expires: 2.week.from_now)
      end
      set_session(:user, {id:uid,secrue:params[:secrue]} )
      check_current_user
    end

    if @current_user
      render_json({res:true,nickname:@current_user.nickname,uid:@current_uid,msg:'登陆成功'})
    else
      render_json({res:false,msg:'登陆失败'})
    end
  end

end