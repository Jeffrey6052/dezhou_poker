
class DezhouRoute < DezhouController

  route :get,  '/'                    do index end

  route :get,  '/:playerSum'         do show end

  route :get,  '/:playerSum/rank'    do rank end

  route :get,  '/:playerSum/search'    do search end  

  route :get,:post,  '/start_running'      do start_running end

  route :get,:post,  '/pause_running'      do pause_running end

  route :get,:post, '/:playerSum/add_table'    do add_table end

  route :get,:post, '/:playerSum/remove_table'     do remove_table end


end
