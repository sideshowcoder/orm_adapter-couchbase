require "couchbase/model"
require "orm_adapter_couchbase/ext/couchbase_model_equality"
require "orm_adapter_couchbase/ext/couchbase_model_patches"

module Couchbase
  class Model
    extend OrmAdapter::ToAdapter

    class OrmAdapter < OrmAdapter::Base

      class MissingViewException < StandardError
        def initialize view_name
          message = "view named #{view_name} is not defined"
          super message
        end
      end

      def create! attrs
        # make sure our views produce consistent data
        klass.create! attrs
      end

      def destroy model
        return nil unless model.is_a? klass

        # Hack to get around delete removing the id from the model
        id = model.id
        model.delete
        model.id = id
      end

      def get! id
        klass.find wrap_key(id)
      end

      def get id
        klass.find_by_id wrap_key(id)
      end

      def find_all options = {}

        conditions, order, limit, offset = extract_conditions!(options)

        view_name, conditions = best_view_for_conditions(conditions)

        # make sure our views produce consistent data
        stream = klass.send(view_name, :stale => false)
        stream = apply_non_view_conditions(stream, conditions)
        stream = apply_order(stream, order)
      end

      def find_first options = {}
        find_all(options).first
      end

      private
      def apply_non_view_conditions stream, conditions
        return stream if conditions.empty?
        stream.select { |item| satisfies_conditions? item, conditions }
      end

      def satisfies_conditions? item, conditions
        conditions.all? { |field, value| item.send(field) == value }
      end

      def apply_order stream, order
        return stream if order.empty?

        case order.first
        when Array
          field, sort_order = order.shift
        else
          field = order.shift
          if [:asc, :desc].include? order.to_enum.peek 
            sort_order = order.shift
          else
            sort_order = :asc
          end
        end

        stream = stream.sort_by(&field.to_sym)
        stream = stream.reverse if sort_order == :desc

        apply_order(stream, order)
      end

      def best_view_for_conditions conditions
        view_name = :all

        new_conditions = conditions.reject { |c|
          view_name = "by_#{c}" if klass.respond_to?("by_#{c}")
        }

        raise MissingViewException.new(view_name) unless klass.respond_to?(view_name)

        [view_name, new_conditions]
      end

    end
  end
end


