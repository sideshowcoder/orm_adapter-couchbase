require "couchbase/model"
require "orm_adapter_couchbase/ext/couchbase_model_equality"

module Couchbase
  class Model
    extend OrmAdapter::ToAdapter

    class OrmAdapter < OrmAdapter::Base

      def get! id
        klass.find wrap_key(id)
      end

      def get id
        klass.find_by_id wrap_key(id)
      end

    end
  end
end


