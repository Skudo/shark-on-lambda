# frozen_string_literal: true

module SharkOnLambda
  module Concerns
    module FilterActions
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def after_action(symbol, only: [], except: [])
          @after_actions ||= []
          @after_actions << {
            symbol: symbol,
            only: Array(only),
            except: Array(except)
          }
        end

        def after_actions
          @after_actions || []
        end

        def before_action(symbol, only: [], except: [])
          @before_actions ||= []
          @before_actions << {
            symbol: symbol,
            only: Array(only),
            except: Array(except)
          }
        end

        def before_actions
          @before_actions || []
        end
      end

      def call_with_filter_actions(method, *args)
        run_before_actions(method)
        result = send(method, *args)
        run_after_actions(method)
        result
      end

      protected

      def after_actions
        self.class.after_actions
      end

      def before_actions
        self.class.before_actions
      end

      def run_actions(method, actions)
        actions.each do |action|
          next if skip_filter_action?(method, action)

          send(action[:symbol])
        end
      end

      def run_after_actions(method)
        run_actions(method, after_actions)
      end

      def run_before_actions(method)
        run_actions(method, before_actions)
      end

      def skip_filter_action?(method, filter_action)
        only = filter_action[:only]
        except = filter_action[:except]

        return true if only.any? && !only.include?(method)
        return true if except.any? && except.include?(method)

        false
      end
    end
  end
end
