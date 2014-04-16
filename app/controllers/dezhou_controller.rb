
class DezhouController < ApplicationController

  set :views, ['dezhou','application']


  def index

    @is_running = AppDezhouWorker.config[:is_running]

    @tables = {}
    (2..12).each do |n|
      @tables[n] = {}
    end

    config_tables = AppDezhouWorker.config[:tables] || []
    config_tables.each do |n|
      @tables[n][:exist] = true
    end

    erb :index
  end

  #playerSum
  def show
    playerSum = params[:playerSum].to_i
    return redirect '/' unless valid_player_sum(playerSum)

    #手动完成一轮牌局
    DeZhouPoker.new(playerSum)

    last_match = DeZhouPoker::Last_Match[playerSum]
    @players = last_match[:players].sort_by{|p| p[:river][:rank] }
    @publicPokers = last_match[:publicPokers]

    erb :show
  end

  #playerSum
  def rank
    playerSum = params[:playerSum].to_i
    return redirect '/' unless valid_player_sum(playerSum)

    reports = DezhouReport.where(playerSum:playerSum)

    @reports = reports.sort_by{|r| r.riverWinnerTimes * 1.0 / r.allGameTimes }.reverse
    @reports_length = @reports.length

    tmp_pokers = ( params[:pokers] || '' ).chomp.upcase

    if tmp_pokers.length>=2
      v1,v2 = tmp_pokers[0,2].split('')
      checked_pokers = sort_playerPokers(v1,v2)
      @search_results = []
      @reports.each_with_index do |report,index|
        @search_results << {rank:index+1,report:report} if report.playerPokers==checked_pokers
      end
    end

    erb :rank
  end

  #手牌查询
  def search
    playerSum = params[:playerSum].to_i
    return redirect '/' unless valid_player_sum(playerSum)

    tmp_pokers = ( params[:pokers] || '' ).chomp.upcase
    if tmp_pokers.length>=2
      v1,v2 = tmp_pokers[0,2].split('')
      checked_pokers = sort_playerPokers(v1,v2)
      @search_results = DezhouReport.where(playerSum:playerSum,playerPokers:checked_pokers).all
    end

    erb :search
  end

  # actions

  def start_running

    start_dezhou_task
    action_redirect "/"
  end

  def pause_running
    
    stop_dezhou_task
    action_redirect "/"
  end

  def add_table

    add_dezhou_task_table(params[:playerSum])
    action_redirect "/#{params[:playerSum]}"
  end

  def remove_table

    remove_dezhou_task_table(params[:playerSum])

    action_redirect "/#{params[:playerSum]}"
  end

  def remove_all_table

    remove_all_dezhou_task_table
    action_redirect "/"
  end

  private

  def action_redirect(default)

    if request.referer
      redirect request.referer,303
    else
      redirect default,303
    end
  end

  def valid_player_sum(playerSum)
    playerSum >= 2 and playerSum <= 12
  end

  def add_dezhou_task_table(playerSum=nil)

    if playerSum
      tables = AppDezhouWorker.config[:tables] || []
      tables << playerSum
      tmp_tables = []
      tables.each do |sum|
        sum = sum.to_i
        tmp_tables << sum if valid_player_sum(sum)
      end
      tmp_tables = tmp_tables.uniq
      p tmp_tables
      AppDezhouWorker.config[:tables] = tmp_tables
      refresh_dezhou_task_config
    end
  end

  def remove_dezhou_task_table(playerSum=nil)
    if playerSum
      playerSum = playerSum.to_i
      return unless valid_player_sum(playerSum)
      tables = AppDezhouWorker.config[:tables] || []
      tables = tables.uniq
      tmp_tables = []
      tables.each do |sum|
        sum = sum.to_i
        if playerSum!=sum
          tmp_tables << sum if valid_player_sum(playerSum)
        end
      end
      AppDezhouWorker.config[:tables] = tmp_tables
      refresh_dezhou_task_config
    end
  end

  def remove_all_dezhou_task_table
    AppDezhouWorker.config[:tables] = []
    refresh_dezhou_task_config
  end

  def refresh_dezhou_task_config
    if AppDezhouWorker.config[:is_running]
      start_dezhou_task
    end
  end

  def start_dezhou_task
    AppDezhouWorker.config[:is_running] = true
    tables = AppDezhouWorker.config[:tables] || []
    AppDezhouWorker.run do
      dezhou_task(tables)
    end
  end

  def stop_dezhou_task
    AppDezhouWorker.stop
  end

  def dezhou_task(tables)
    tables.each do |playerSum|
      DeZhouPoker.new(playerSum)
    end
  end

end
