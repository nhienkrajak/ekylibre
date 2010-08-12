# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2010 Brice Texier, Thibaud Mérigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: product_components
#
#  active       :boolean          not null
#  comment      :text             
#  company_id   :integer          not null
#  component_id :integer          not null
#  created_at   :datetime         not null
#  creator_id   :integer          
#  id           :integer          not null, primary key
#  location_id  :integer          not null
#  lock_version :integer          default(0), not null
#  name         :string(255)      not null
#  product_id   :integer          not null
#  quantity     :decimal(16, 4)   not null
#  started_at   :datetime         
#  stopped_at   :datetime         
#  updated_at   :datetime         not null
#  updater_id   :integer          
#

class ProductComponent < ActiveRecord::Base
  attr_readonly :company_id, :quantity, :content_id, :package_id, :name, :comment
  belongs_to :company
  belongs_to :component, :class_name=>Product.to_s
  belongs_to :location
  belongs_to :product

  autosave :product

  def prepare
    if self.quantity >= 2
      self.name = self.quantity.to_s+" "+self.component.unit.label+"s "+tc('of_product')+" "+self.component.name.to_s
    else
      self.name = self.quantity.to_s+" "+self.component.unit.label+" "+tc('of_product')+" "+self.component.name.to_s
    end
  end
  
  def prepare_on_create    
    self.active = true
    self.started_at = Time.now
  end

  def update_without_callbacks
    current_time = Time.now
    stamper_id = self.class.stamper_class.stamper.id rescue nil
    nc = self.class.create!(self.attributes.delete_if{|k,v| [:company_id].include?(k.to_sym)}.merge(:created_at=>current_time, :updated_at=>current_time, :creator_id=>stamper_id, :updater_id=>stamper_id))
    self.class.update_all({:active=>false}, {:id=>self.id})
    return nc
  end

  def destroy_without_callbacks
    unless new_record?
      self.class.update_all({:active=>false}, {:id=>self.id})
    end
  end

  def check_quantities(params, production_quantity)
    total = 0
    for p in params[self.id.to_s]
      total += p[1].to_d
    end
    value = (total == (self.quantity*production_quantity))
  end
  
#   def stocks_move_create(params, production_id)
#     for p in params
#       if p[1] > 0
#         StockMove.create!(:name=>tc('production')+" "+self.id.to_s, :quantity=>p[1], :location_id=>p[0], :product_id=>self.component_id, :company_id=>self.company_id, :planned_on=>Date.today, :moved_on=>Date.today, :virtual=>true, :input=>false, :origin_type=>Production.to_s, :origin_id=>production_id)
#       end
#     end

#   end

end
