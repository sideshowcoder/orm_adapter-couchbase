require "couchbase/model"
require "orm_adapter_couchbase/ext/couchbase_model_equality"
require "orm_adapter_couchbase/ext/couchbase_model_patches"
require "orm_adapter_couchbase/ext/couchbase_model_has_many"

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

        view_name, view_options, options = view_for_options(options)

        conditions, order, limit, offset = extract_conditions!(options)

        stream = klass.send(view_name, view_options)

        # deal with everything which wasn't handled via the view
        stream = apply_conditions(stream, conditions)
        stream = apply_order(stream, order)
        stream = stream.drop(offset) if offset
        stream = stream.take(limit) if limit

        stream.to_a # make sure to return an array
      end

      def find_first options = {}
        id = options.delete(:id)
        conditions, _ = extract_conditions!(options.dup)

        if id
          apply_conditions([get(id)], conditions).first
        else
          find_all(options).first
        end
      end

      private
      def apply_conditions stream, conditions
        return stream if conditions.empty?
        stream.select { |item| satisfies_conditions? item, conditions }
      end

      def satisfies_conditions? item, conditions
        conditions.all? { |field, value| item.send(field) == value }
      end

      def apply_order stream, order
        return stream if order.empty?

        stream.to_a.sort_by do |item|
          sort = []
          order = order.to_enum
          o = order.next
          loop do
            case o
            when Array
              value = item.send(o[0])
              value = invert_value(value) if o[1] == :desc
              sort.push(value)
            else
              value = item.send(o[0])
              case order.peek
              when :asc
                begin
                  order.next
                rescue StopIteration
                  break
                end
              when :desc
                value = invert_value(value)
                begin
                  order.next
                rescue StopIteration
                  break
                end
              end
              sort.push(value)
            end
            begin
              o = order.next
            rescue StopIteration
              break
            end
          end
          sort
        end
      end

      def invert_value value
        case value
        when String
          inverse = []
          value.each_codepoint { |c| inverse.push(-c) }
          inverse
        else
          -value
        end
      end

      def view_for_options options
        view_name = :all
        view_options = { :stale => false }
        conditions, order, limit, offset = extract_conditions!(options.dup)

        # TODO would be nice to merge multiple conditions into one view name
        # for example users have a rating, and the comprised key is [user,
        # rating] if the view is named "by_user_and_rating" we could then merge
        # this into one and even apply the ordering in one go
        remaining_conditions = conditions.reject { |condition, value|
          if klass.respond_to?("by_#{condition}")
            view_name = "by_#{condition}".to_sym
            view_options[:key] = value
          end
        }

        options = { :conditions => remaining_conditions, :order => order }

        if remaining_conditions.empty?
          # merge limit, and offset conditions into view query
          view_options[:limit] = limit if limit
          view_options[:skip] = offset if offset
        else
          options[:limit] = limit if limit
          options[:offset] = offset if offset
        end

        raise MissingViewException.new(view_name) unless klass.respond_to?(view_name)

        p [view_name, view_options, options]
      end

    end
  end
end


