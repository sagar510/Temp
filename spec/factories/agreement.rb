FactoryBot.define do
    factory :agreement, class: Agreement do
      start_date { Date.today }
      end_date { Date.today + 1.month }
      status { Agreement::Status::ACTIVE }
      association :dc_cost_head, factory: :dc_cost_head
      agreement_type { Agreement::Type::VARIABLE_COST }
      details { {} }
    end
  end
  