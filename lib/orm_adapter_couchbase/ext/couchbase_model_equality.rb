module Couchbase
  class Model

    # define the equality as id equality this should be the default
    # but it isn't ...
    #
    # TODO file a bug about this!
    #
    def == other
      id == other.id
    end

  end
end
