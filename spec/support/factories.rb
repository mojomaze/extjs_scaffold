FactoryGirl.define do
  # factory :order do
  #     sequence(:name){|n| "order #{n}" }
  #   end
  #   
  #   factory :item do
  #     sequence(:name){|n| "item #{n}" }
  #     order nil
  #   end
  #   
  #   factory :order_with_items, :parent => :order do |order|
  #     order.after_create {|o| 5.times { Factory.create(:item, :order => o) } }
  #   end
end