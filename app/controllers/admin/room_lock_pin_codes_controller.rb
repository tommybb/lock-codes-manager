module Admin
  class RoomLockPinCodesController < Admin::AdminController
    def resend
      if SendRoomPinCode.call(params[:id].to_i)
        redirect_to root_path, alert: 'Lock code has been successfully resent to guest.'
      end
    end

    def reset
      if SetRoomPinCode.call(params[:id].to_i)
        message = 'New pin code has been set!'
      else
        message = 'New pin code has not been set! Something went wrong.'
      end

      redirect_to root_path, alert: message
    end
  end
end
