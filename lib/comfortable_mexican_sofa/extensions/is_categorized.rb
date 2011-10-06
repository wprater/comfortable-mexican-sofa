module ComfortableMexicanSofa::IsCategorized
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def cms_is_categorized
      include ComfortableMexicanSofa::IsCategorized::InstanceMethods
      
      has_and_belongs_to_many :categories,
        inverse_of: nil,
        class_name: 'Cms::Category'
        
      attr_accessor :tmp_category_ids

      before_save :sync_categories

      scope :for_category, lambda { |*categories|
        if (categories = [categories].flatten.compact).present?
          ids = Cms::Category.where(:label.in => categories, :categorized_type => name).map(&:id)
          where(:category_ids.in => ids)
        else
          all
        end
      }
    end
  end
  
  module InstanceMethods
    def sync_categories
      category_bits = self.tmp_category_ids
      (category_bits || {}).each do |category_id, flag|
        case flag.to_i
        when 1
          if category = Cms::Category.find(category_id)
            self.categories << category unless self.categories.include?(category)
          end
        when 0
          idx = self.category_ids.index(BSON::ObjectId.from_string(category_id))
          self.category_ids.delete_at(idx) unless idx.nil?
        end
      end
    end
  end
end
