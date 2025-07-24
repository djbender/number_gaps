class NumberGapsController < ApplicationController
  def index
  end

  def analyze
    return redirect_to number_gaps_index_path, alert: 'Please select a file' unless file_params[:file]

    begin
      gaps = NumberGapsFinder.run!(
        file: file_params[:file].tempfile,
        column: file_params.fetch(:column, 1).to_i,
        headers: file_params.fetch(:headers, 'true') == 'true'
      )
      
      @precision = gaps.last&.l&.digits&.count
      @gaps = gaps
      @formatted_gaps = format_gaps(gaps)
      
      render :analyze
    rescue => e
      redirect_to root_path, alert: "Error processing file: #{e.message}"
    end
  end

  private

  def file_params
    params.permit(:file, :column, :headers, :authenticity_token, :commit)
  end

  def format_gaps(gaps)
    gaps.map do |gap|
      text = fmt(gap.f)
      text += "-#{fmt(gap.l)}" if gap.f != gap.l
      text
    end.join("\n")
  end

  def fmt(val)
    sprintf("%0#{@precision}d", val)
  end
end
