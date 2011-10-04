class Cms::Revision
  include Mongoid::Document
  include Mongoid::Timestamps

  ComfortableMexicanSofa.establish_connection(self)
  
  store_in :cms_revisions
  
  field :data, type: Hash
  
  # -- Relationships --------------------------------------------------------
  belongs_to :record, :polymorphic => true
  
  # -- Scopes ---------------------------------------------------------------
  default_scope order_by(:created_at, :desc)
  
end