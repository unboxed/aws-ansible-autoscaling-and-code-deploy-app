class PingController < ApplicationController
  def ping
    render text: "PONG\n"
  end
end
