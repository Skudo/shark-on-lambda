# frozen_string_literal: true

module SharkOnLambda
  module Cacheable
    delegate :cache, :global_cache, to: SharkOnLambda

    def cache_duration(item)
      cache_durations[item] || cache_durations[:default]
    end

    private

    def cache_durations
      return @cache_durations if defined?(@cache_durations)

      settings = SharkOnLambda.application.config_for(:settings) || {}
      @cache_durations = settings.fetch(:cache_durations, {})
      @cache_durations = @cache_durations.with_indifferent_access
    end
  end
end
