class StaticController < ApplicationController
  def letsencrypt
    if params[:id] == ENV["LETSENCRYPT_ACME_CHALLENGE"]
      render text: params[:id] + "." + ENV["LETSENCRYPT_ACME_CHALLENGE_SECRET"]
    else
      render text: nil
    end
  end
end
