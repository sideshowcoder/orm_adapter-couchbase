require "spec_helper"
require "example_app_shared"


if !defined?(Couchbase::Model) || !(Couchbase.connect(:bucket => "orm_adapter") rescue nil)
  puts "** require 'couchbase-model' and start couchbase with a bucket 'orm_adapter' created to run the specs in #{__FILE__}"
else

  # this is needed to get around the circular dependency since we need to
  # constantize Note as well as User to have has_many and belongs_to of damn
  # circular dependency
  class Note < Couchbase::Model
  end

  class User < Couchbase::Model
    attribute :name
    attribute :rating
    has_many :notes
    view :all, :by_name
  end

  class Note < Couchbase::Model
    attribute :body, :default => "made by orm"
    belongs_to :owner, :class_name => "User"
    view :all
  end

  module OrmAdapterCouchbaseSpec

    Couchbase.connection_options = { :bucket => "orm_adapter" }
    Couchbase::Model::Configuration.design_documents_paths = [File.dirname(__FILE__) + "/design_documents/"]


    # here be the specs!
    describe Couchbase::Model::OrmAdapter do
      before do
        Couchbase.bucket.flush
        User.ensure_design_document!
        Note.ensure_design_document!
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end
