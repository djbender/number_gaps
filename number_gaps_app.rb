require 'sinatra/base'
require 'sinatra/reloader' if ENV.fetch('RACK_ENV', 'development') == 'development'
require_relative 'lib/number_gaps'
require 'byebug' if ENV.fetch('RACK_ENV', 'development') == 'development'

class NumberGapsApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index
  end

  post '/upload' do
    gaps = NumberGaps.run!(
      file: params.dig(:file, :tempfile),
      column: params.fetch(:column, 1).to_i,
      headers: params.fetch(:headers, "true") == "true"
    )
    # this helps display numbers as zero padded values
    @precision = gaps.last&.l&.digits&.count
    pre = gaps.map do |gap|
      text = "#{fmt(gap.f)}"
      text += "-#{fmt(gap.l)}" if gap.f != gap.l
      text
    end.join("\n")


    erb :upload, locals: { gaps:, pre: }
  end

  helpers do
    def fmt(val)
      sprintf("%0#{@precision}d", val)
    end
  end
end
