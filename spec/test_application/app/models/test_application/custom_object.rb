# frozen_string_literal: true

module TestApplication
  class CustomObject
    def id
      SecureRandom.uuid
    end
  end
end
