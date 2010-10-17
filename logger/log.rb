require 'logger'

class Logger
  
  @@logger = Logger.new(STDOUT)
  @@logger.level = 0
  methods = [:error, :warning, :info, :debug]
  level = 0
  methods.each do |method|
    if @@logger.level >= level
      class_eval %(class << self
                        def #{method.to_s} (message, params=nil)
                            params = self.format_params(params) unless params.nil?
                            @@logger.#{method.to_s}("\#{message}\#{params.to_s}")
                        end
                      end
                    )
    else
      class_eval %(class << self
                        def #{method.to_s} (message, params=nil)
                        end
                      end
                    )
    end
    level += 1
  end

  def self.level= (level)
    @@logger.level = level
  end

private

  def self.format_params (parameters)
    str = ""
    if parameters.class == Hash
      parameters.each do |key, value|
        value = value.inspect if value.class != String
        str += "#{key}='#{value}';"
      end
    end
    str = ";#{str}" if str.length > 0
  end
  
end
