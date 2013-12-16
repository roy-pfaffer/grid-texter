class DataParser
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def from_number
    params[:From]
  end

  def message
    @message ||= params[:Body].split(' - ')[1..-1].join(' - ')
  end

  def original_alias
    @original_alias ||= params[:Body].split(' - ')[0]
  end

  # parsing commands

  def parsed_input
    @parsed_input ||= params[:Body].split(' - ')[1..-1].join(' - ')
  end

  def command?
    parsed_input[0] == '/'
  end

  def sent_command
    @sent_command ||= parsed_input[1..-1].split(' ')[0]
  end

  def sent_args
    @sent_args ||= parsed_input[1..-1].split(' ')[1..-1]
  end

end
