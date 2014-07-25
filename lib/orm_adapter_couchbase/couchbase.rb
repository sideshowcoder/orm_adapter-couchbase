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
        klass.create! attrs, :persisted => 1
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
        stream = klass.send view_name, :stale => false

        if conditions.empty?
          stream
        else
          stream.select { |e|
            conditions.all? { |field, value| e.send(field) == value }
          }
        end
      end

      private
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


