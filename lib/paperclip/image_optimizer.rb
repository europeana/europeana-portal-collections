# frozen_string_literal: true

module Paperclip
  class ImageOptimizer < Processor
    def make
      image_optim = ImageOptim.new(Paperclip::Attachment.default_options[:image_optimizer])
      optimized = image_optim.optimize_image(@file.path)
      File.open(optimized)
    end
  end
end
