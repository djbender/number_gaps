require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'lib/number_gaps'
require 'byebug' if ENV.fetch('RACK_ENV', 'development') == 'development

class NumberGapsApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index
  end

  post '/upload' do
    gaps = NumberGaps.run!(file: params[:file])

    @precision = gaps.last&.l.digits.count

    erb :upload, locals: { gaps: gaps }
  end

  helpers do
    def fmt(val)
      sprintf("%0#{@precision}d", val)
    end
  end
end
