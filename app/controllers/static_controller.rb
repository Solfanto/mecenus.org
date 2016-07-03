class StaticController < ApplicationController
  def letsencrypt
    render text: ENV["LETSENCRYPT_ACME_CHALLENGE"]
  end
end
