# frozen_string_literal: true

module SharkOnLambda
  module Errors
    class BaseSerializer < JSONAPI::Serializable::Error
      id { @object.id }
      status { @object.status }
      code { @object.code }
      title { @object.title }
      detail { @object.detail }
      meta { @object.meta }
      source do
        pointer @object.pointer if @object.pointer.present?
        parameter @object.parameter if @object.parameter.present?
      end
    end
  end
end
