require "spec_helper"
require "example_app_shared"


if !defined?(Couchbase::Model) || !(Couchbase.connect(:bucket => "orm_adapter") rescue nil)
  puts "** require 'couchbase-model' and start couchbase with a bucket 'orm_adapter' created to run the specs in #{__FILE__}"
else

  class User < Couchbase::Model
    attribute :name
    attribute :rating
    design_document :user
    view :notes
    view :all
  end

  class Note < Couchbase::Model
    attribute :owner_id
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
