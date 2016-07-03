class StaticController < ApplicationController
  def letsencrypt
    if params[:id] == ENV["LETSENCRYPT_ACME_CHALLENGE"]
      render text: params[:id]
    else
      render text: nil
    end
  end
end
