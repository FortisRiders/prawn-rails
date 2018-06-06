require 'prawn'
require 'prawn-rails/extension'

Gem.loaded_specs.keys.select{|spec_name| spec_name.starts_with?('prawn-')}.each do |gem_name|
  next if gem_name == 'prawn-rails' # Prevent circular loading
  begin
    require gem_name.gsub('-', '/')
  rescue LoadError => e
    puts e
    puts e.backtrace
  end
end

module PrawnRails

  # This derives from Prawn::Document in order to override defaults. Note that the Prawn::Document behaviour itself shouldn't be changed.
  class Document < Prawn::Document
    def initialize(opts = {})
      if PrawnRails.config.respond_to?(:to_h)
        default = PrawnRails.config.to_h.merge(opts)
      else
        default = PrawnRails.config.marshal_dump.merge(opts)
      end
      super(default)
    end

    # Typically text expects a string. But rails views have this interesting concept that they implicitly call 
    # `to_s` on all the variables before rendering. So, passing an integer to text fails:
    #
    # pdf.text 10       #=> fails because 10 is not a string
    # pdf.text 10.to_s  #=> works
    #
    # To circumvent this situation, we call to_s on value, and delegate action to actual Prawn::Document.
    def text(value, options = {})
      super(value.to_s, options)
    end
  end

  Document.extensions << Extension
end
