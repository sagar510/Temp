# == Schema Information
#
# Table name: payment_request_advance_payment_adjustments
#
#  id                      :bigint           not null, primary key
#  from_payment_request_id :bigint
#  to_payment_request_id   :bigint
#  amount                  :decimal(12, 3)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require 'rails_helper'

RSpec.describe PaymentRequestAdjustment, type: :model do

end
