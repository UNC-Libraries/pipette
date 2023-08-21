# frozen_string_literal: true

require 'git/failed_error'

module Pipette
  class AspaceRequestError < StandardError; end
  class UnpublishedError < StandardError; end
  class ClassificationError < StandardError; end
end
