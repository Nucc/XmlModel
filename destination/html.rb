require 'destination/abstract.rb'

module XmlModel
	module Destination
		class Html
			include Interface
			
			def generate
				@model
			end
		end
	end
end