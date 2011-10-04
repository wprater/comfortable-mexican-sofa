class Cms::Categorization
  include Mongoid::Document

  ComfortableMexicanSofa.establish_connection(self)
  
  store_in :cms_categorizations

  field  :categorized_type, type: String
  
  # -- Relationships --------------------------------------------------------
  belongs_to :category, class_name: 'Cms::Category'
  belongs_to :categorized,
    :class_name => 'Cms::Layout',
    :polymorphic => true
    
  # -- Validations ----------------------------------------------------------
  validates :categorized_type, :categorized_id,
    :presence   => true
  validates :category_id,
    :presence   => true,
    :uniqueness => { :scope => [:categorized_type, :categorized_id] }
  
end
