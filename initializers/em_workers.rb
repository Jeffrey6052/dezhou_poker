
class DezhouEMWorker

  attr_accessor :config

  def initialize(&block)
    @config = {
      is_running: false,
      time: 1.0/1000,
      tables:[]
    }
  end

  def run(&block)
    return false unless block_given?
    @is_running = true
    EM.cancel_timer(@worker_timer) if @worker_timer

    @worker_timer = EM.add_periodic_timer(@config[:time]) do
      yield
      EM.cancel_timer(@worker_timer) unless @config[:is_running]
    end
    true
  end

  def stop
    EM.cancel_timer(@worker_timer)
    @config[:is_running] = false
  end

end

AppDezhouWorker = DezhouEMWorker.new