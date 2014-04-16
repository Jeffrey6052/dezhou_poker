
module ApplicationHelper

  def pokers_html(arr)
    str = arr.collect{|poker|
      poker.gsub('♥',"<font style='color:red;'>♥</font>")
           .gsub('♦',"<font style='color:red;'>♦</font>")
           .gsub('♠',"<font style='color:black;'>♠</font>")
           .gsub('♣',"<font style='color:black;'>♣</font>")
    }.join('.')
    " &nbsp; #{str} &nbsp; "
  end

  def rank_html(num)
    case num
    when 1
      "<font style='color:red;font-weight:bold;'>"+"#{num}"+"</font>"
    when 2
      "<font style='color:#ec4d00;font-weight:bold;'>"+"#{num}"+"</font>"
    when 3
      "<font style='color:#ec4d00;font-weight:bold;'>"+"#{num}"+"</font>"
    else
      "#{num}"
    end
  end

  def get_playerPokers(pokers)
      v1,v2 = pokers[0][1],pokers[1][1]
      sort_playerPokers(v1,v2)
  end

  def sort_playerPokers(v1,v2)
      k1,k2 = DeZhouPoker::Value_Hash[v1],DeZhouPoker::Value_Hash[v2]
      k1 ||= 0
      k2 ||= 0
      playerPokers = k1 > k2 ? "#{v1}#{v2}" : "#{v2}#{v1}"
  end

  def form_authenticity_token
    session[:_csrf_token] ||= set_session(:_csrf_token, SecureRandom.base64(32))
  end

  #检测是否登录
  def signed_in?
      @current_user.present?
  end

  def requirejs_base_url
    @temp[:version_path] ||= Settings.static_version.presence && "/#{Settings.static_version}"
    "#{Settings.static_root}#{@temp[:version_path]}/js/lib"
  end

  #静态文件url
  def static_url(file)
    @temp[:version_path] ||= Settings.static_version.presence && "/#{Settings.static_version}"
    "#{Settings.static_root}#{@temp[:version_path]}#{file}"
  end

  #获取文件url
  def file_url(file_path)
    return file_path if file_path.nil? or file_path.empty?
    file_path.match(/^http/) ? file_path : File.join(Settings.oss_root, file_path)
  end

  #检测IE6
  def ie6?
      @temp[:is_ie6] ||= (request.user_agent && request.user_agent.match(/(?i)msie [1-7]/)) ? 1 : 0
      @temp[:is_ie6] == 1
  end

  def ie8?
      return true if ie6?
      @temp[:is_ie8] ||= (request.user_agent && request.user_agent.match(/(?i)msie 8/)) ? 1 : 0
      @temp[:is_ie8] == 1
  end

  #检测是否为管理员
  def admin?
    @temp[:is_admin] ||= (
      if @current_uid
        admin_uids = [1]
        is_admin = admin_uids.include? @current_uid
        is_admin ? 1 : 0
      else
        0
      end )
    @temp[:is_admin] == 1
  end

  def params_page
    @temp[:params_page] ||= (
      if params[:page].present?
        params[:page].to_i
      else
        1
      end
    )
  end

  #设置分页的默认值
  def paginate(sequel_pagination = nil, options = {})
    options[:previous_label] ||= '上一页'
    options[:next_label] ||= '下一页'
    options[:inner_window] ||= 3
    options[:outer_window] ||= 0
    options[:params] = params if request.post?
    temp = PaginateTemp.new(sequel_pagination)
    will_paginate(temp, options)
  end

end

#用于将sequel pagination对象转成will_paginate能处理的对象
class PaginateTemp

  def initialize(sequel_pagination)
    @current_page = sequel_pagination.current_page
    @total_pages = sequel_pagination.pagination_record_count/sequel_pagination.page_size
  end

  def current_page
    @current_page
  end

  def total_pages
    @total_pages
  end

  def previous_page
    @current_page - 1
  end

  def next_page
    @current_page + 1
  end

  def out_of_bounds?
    @current_page > @total_pages
  end

end