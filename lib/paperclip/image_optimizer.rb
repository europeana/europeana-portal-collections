# frozen_string_literal: true

module Paperclip
  # Paperclip processor to optimise images with ImageOptim
  class ImageOptimizer < Processor
    def make
      image_optim = ImageOptim.new(Paperclip::Attachment.default_options[:image_optimizer])
      optimized = image_optim.optimize_image(@file.path)
      optimized.nil? ? @file : File.open(optimized)
    rescue StandardError
      @file
    end
  end
end
