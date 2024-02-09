# == Schema Information
#
# Table name: customers
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  customer_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe Customer, type: :model do
  context 'factory validation tests' do
    it "customer should be valid" do
      expect(FactoryBot.build(:customer)).to be_valid
    end

    it "customer_gt should be valid" do
      expect(FactoryBot.build(:customer_gt)).to be_valid
    end

    it "customer_mt should be valid" do
      expect(FactoryBot.build(:customer_mt)).to be_valid
    end

    it "customer_exp should be valid" do
      expect(FactoryBot.build(:customer_exp)).to be_valid
    end

    it "customer_lq should be valid" do
      expect(FactoryBot.build(:customer_lq)).to be_valid
    end
  end

  context 'associations test' do
    it { should have_many(:auction_users) }
    it { should have_many(:customer_locations) }
    it { should have_many(:locations).through(:customer_locations) }
    it { should have_many(:sale_orders) }
    it { should have_many(:overdue_invoices).class_name('ZohoBooks::Invoice').with_foreign_key('customer_id').with_primary_key('zoho_customer_id') }
    it { should have_many(:quality_reports) }
    it { should have_many(:customer_specs).dependent(:destroy) }
    it { should have_many(:payment_requests) }
    it { should have_one(:cds_customer_balance).class_name('Cds::CustomerBalance').with_foreign_key('customer_id').dependent(:destroy) }
    it { should have_many(:contact_activities).with_foreign_key('ext_num').with_primary_key('poc_phone_number').order(id: :desc) }
    it { should have_many(:wallet_sizes).dependent(:destroy) }
  end

  context 'validation tests' do
    let(:customer) { build(:customer_gt) }
  
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:short_code).allow_blank }
    it { should validate_presence_of(:poc_phone_number) }
    it { should validate_length_of(:poc_phone_number).is_equal_to(10) }
    it { should validate_presence_of(:customer_type) }
    it { should validate_inclusion_of(:customer_type).in_array(Customer::Type::ALL) }
  end

  context 'method test' do

    describe '#check_credit_type_conversion' do
      let(:cash_customer) { create(:customer,active: true, credit_limit: -1, payment_terms: 0) }
      let(:credit_customer){ create(:customer,credit_limit: 100) }
      context 'convert customer from credit to cash' do
        it 'is successful if customer_outstanding is 0' do
          new_credit_customer = create(:customer,credit_limit: 100)
          expect(new_credit_customer.update(credit_limit: -1)).to eq(true)
        end
      end
      context 'convert customer from cash to credit' do
        it 'is successful if customer_outstanding is 0 and payment terms > 0' do
          new_cash_customer = create(:customer,credit_limit:-1,payment_terms:0)
          expect(new_cash_customer.update(credit_limit: 100,payment_terms:10)).to eq(true)
        end
        it 'is successful if customer_outstanding <= credit_limit' do 
          cash_customer_with_outstanding = create(:customer,credit_limit:-1,payment_terms:0)
          cash_customer_with_outstanding.update_btr_outstanding(100)
          expect(cash_customer_with_outstanding.update(credit_limit: 100)).to eq(true)
        end
        it 'is unsuccessful if customer_outstanding > credit_limit' do 
          cash_customer_with_outstanding = create(:customer,credit_limit:-1,payment_terms:0)
          cash_customer_with_outstanding.update_btr_outstanding(100)
          expect{cash_customer_with_outstanding.update(credit_limit: 99)}.to raise_error(RuntimeError, "Outstanding is more than credit limit")
        end
        it 'is unsuccessful if payment terms < 0' do
          new_cash_customer = create(:customer,credit_limit:-1,payment_terms:0)
          expect{new_cash_customer.update(credit_limit: 100,payment_terms:-1)}.to raise_error(RuntimeError,"Payment terms should not be negative")
        end
      end
    end


    describe '#check_payment_terms' do
      context 'when payment terms is not present' do
        it 'does not raise an error' do
          customer = build(:customer, payment_terms: nil)
          expect { customer.check_payment_terms }.not_to raise_error
        end
      end
      
      context 'when customer is cash' do
        it 'raises an error if payment terms is not 0' do
          customer = build(:customer, is_cash_customer: true, payment_terms: 5, credit_limit: -1, active: true)
          puts "output of if is : #{customer.is_cash?}"
          expect { customer.check_payment_terms }.to raise_error("Payment terms should be 0 for cash customer")
        end

        it 'does not raise an error if payment terms is 0' do
          customer = build(:customer, is_cash_customer: true, payment_terms: 0)
          expect { customer.check_payment_terms }.not_to raise_error
        end
      end

      context 'when customer is not cash' do
        it 'raises an error if payment terms is negative' do
          customer = build(:customer, is_cash_customer: false, payment_terms: -5)
          expect { customer.check_payment_terms }.to raise_error("Payment terms should not be negative")
        end
  
        it 'does not raise an error if payment terms is non-negative' do
          customer = build(:customer, is_cash_customer: false, payment_terms: 10)
          expect { customer.check_payment_terms }.not_to raise_error
        end
      end
    end


    describe '#is_loader?' do
      context 'when customer type is LOADER' do
        it 'returns true' do
          customer = build(:customer, customer_type: Customer::Type::LOADER)
          expect(customer.is_loader?).to be_truthy
        end
      end

      context 'when customer type is not LOADER' do
        it 'returns false' do
          customer = build(:customer, customer_type: Customer::Type::GT) # Assuming GT is not LOADER
          expect(customer.is_loader?).to be_falsey
        end
      end
    end


    describe '#is_b2r?' do
      context 'when customer type is B2R' do
        it 'returns true' do
          customer = build(:customer, customer_type: Customer::Type::B2R)
          expect(customer.is_b2r?).to be_truthy
        end
      end

      context 'when customer type is not B2R' do
        it 'returns false' do
          customer = build(:customer, customer_type: Customer::Type::GT) # Assuming GT is not B2R
          expect(customer.is_b2r?).to be_falsey
        end
      end
    end


    describe '#is_credit?' do
      let(:credit_customer){ create(:customer,credit_limit: 100) }
      context 'customer is valid credit customer' do
        it 'returns true if credit >= 0' do
          expect(credit_customer.is_credit?).to eq(true)
        end
        it 'returns false if credit_limit < 0' do
          credit_customer.update(credit_limit: -100)
          expect(credit_customer.is_credit?).to eq(false)
        end
      end
    end


    describe '#is_cash?' do
      let(:cash_customer) { create(:customer,active: true, credit_limit: -1, payment_terms: 0) }
      context 'customer is valid cash customer' do
        it 'returns true if credit_limit = 1 and payment terms = 0' do
          expect(cash_customer.is_cash?).to eq(true)
        end
        it 'returns false if not active customer' do
          cash_customer.update(active:false)
          expect(cash_customer.is_cash?).to eq(false)
        end
      end
    end


    describe '#is_cash_customer?' do
      it 'returns true if the customer is a cash customer' do
        cash_customer = build(:customer, is_cash_customer: true)
        expect(cash_customer.is_cash_customer?).to be_truthy
      end

      it 'returns false if the customer is not a cash customer' do
        non_cash_customer = build(:customer, is_cash_customer: false)
        expect(non_cash_customer.is_cash_customer?).to be_falsey
      end
    end


    describe '#virtual_vpas' do
      it 'returns the correct virtual VPAs for a loader customer' do
        loader_customer = create(:customer, customer_type: Customer::Type::LOADER)
        expected_vpas = ["Fruitx#{sprintf("%06d", loader_customer.id)}@hsbc"]
        expect(loader_customer.virtual_vpas).to eq(expected_vpas)
      end

      it 'returns the correct virtual VPAs for a B2R customer' do
        b2r_customer = create(:customer, customer_type: Customer::Type::B2R)
        expected_vpas = ["Vegrow#{sprintf("%06d", b2r_customer.id)}@hsbc"]
        expect(b2r_customer.virtual_vpas).to eq(expected_vpas)
      end

      it 'returns the correct virtual VPAs for other customer types' do
        other_customer = create(:customer, customer_type: Customer::Type::GT)
        expected_vpas = [
          "Vegrow#{sprintf("%06d", other_customer.id)}@hsbc",
          "Fruitx#{sprintf("%06d", other_customer.id)}@hsbc"
        ]
        expect(other_customer.virtual_vpas).to eq(expected_vpas)
      end
    end

    
    describe '#net_zoho_overdue' do
      context 'when cds_customer_balance is present' do
        it 'returns net_zoho_outstanding from cds_customer_balance' do
          customer = create(:customer)
          allow(customer).to receive(:cds_customer_balance).and_return(double('cds_customer_balance', net_zoho_outstanding: 100))
          expect(customer.net_zoho_overdue).to eq(100)
        end
      end


      context 'when cds_customer_balance is not present' do
        it 'returns sum of overdue_invoices balances' do
          customer = create(:customer)
          allow(customer).to receive(:cds_customer_balance).and_return(nil)
          allow(customer).to receive_message_chain(:overdue_invoices, :sum).and_return(125)
          expect(customer.net_zoho_overdue).to eq(125)
        end
      end
    end


    describe '#due_and_invoices_value' do
      it 'calculates total outstanding correctly' do
        customer = create(:customer)

        allow(customer).to receive(:net_zoho_overdue).and_return(100)
        allow(customer.sale_orders).to receive_message_chain(:not_in_zoho, :filter_invalid, :sum).and_return(200)
        allow(customer).to receive(:btr_outstanding_amount).and_return(50)
        allow(customer).to receive(:mandi_outstanding).and_return(30)

        expect(customer.due_and_invoices_value).to eq(100 + 200 + 50 + 30)
      end
    end


    describe '#credit_limit_including_dcl' do
      it 'calculates credit limit including discretionary credit limit correctly' do
        customer = create(:customer, credit_limit: 1000)
        
        allow(DiscretionaryCreditLimit).to receive(:today_extra_limit).with(customer.id).and_return(200)

        expect(customer.credit_limit_including_dcl).to eq(1000 + 200)
      end
    end


    describe '#payment_terms_including_dcl' do
      it 'calculates payment terms including discretionary credit limit correctly' do
        customer = create(:customer, payment_terms: 30)
        
        allow(DiscretionaryCreditLimit).to receive(:today_extra_days).with(customer.id).and_return(5)

        expect(customer.payment_terms_including_dcl).to eq(30 + 5)
      end
    end


    describe '#passed_credit_limit?' do
      context 'when credit limit is not exceeded' do
        it 'returns false' do
          customer = create(:customer, credit_limit: 10)
          allow(customer).to receive(:due_and_invoices_value).and_return(500)
          allow(customer).to receive(:credit_limit_including_dcl).and_return(1000)

          expect(customer.passed_credit_limit?).to be_falsey
        end
      end


      context 'when credit limit is exceeded' do
        it 'returns true' do
          customer = create(:customer, credit_limit: 10)
          allow(customer).to receive(:due_and_invoices_value).and_return(1500)
          allow(customer).to receive(:credit_limit_including_dcl).and_return(1000)

          expect(customer.passed_credit_limit?).to be_truthy
        end
      end
    end
    

    describe '#passed_credit_days?' do
      context 'when overdue invoice date and payment terms are blank' do
        it 'returns false' do
          customer = build(:customer)
          allow(customer).to receive(:oldest_overdue_invoice_date).and_return(nil)

          expect(customer.passed_credit_days?).to be_falsey
        end
      end

      context 'when overdue invoice date and payment terms are present' do
        context 'when credit days are not exceeded' do
          it 'returns false' do
            customer = build(:customer, payment_terms: 10)
            allow(customer).to receive(:oldest_overdue_invoice_date).and_return(5.days.ago.to_date)
            allow(customer).to receive(:payment_terms_including_dcl).and_return(15)

            expect(customer.passed_credit_days?).to be_falsey
          end
        end

        context 'when credit days are exceeded' do
          it 'returns true' do
            customer = build(:customer, payment_terms: 10)
            allow(customer).to receive(:oldest_overdue_invoice_date).and_return(20.days.ago.to_date)
            allow(customer).to receive(:payment_terms_including_dcl).and_return(15)
  
            expect(customer.passed_credit_days?).to be_truthy
          end
        end
      end
    end


    describe '#credit_days_remaining' do
      context 'when oldest overdue invoice date is present' do
        it 'returns the remaining credit days' do
          customer = build(:customer)
          allow(customer).to receive(:oldest_overdue_invoice_date).and_return(5.days.ago.to_date) 
          allow(customer).to receive(:payment_terms_including_dcl).and_return(15)

          remaining_days = 15 - (Date.today - customer.oldest_overdue_invoice_date).to_i

          expect(customer.credit_days_remaining).to eq(remaining_days)
        end
      end

      context 'when oldest overdue invoice date is not present' do
        it 'returns the payment terms including DCL' do
          customer = build(:customer)
          allow(customer).to receive(:oldest_overdue_invoice_date).and_return(nil)
          allow(customer).to receive(:payment_terms_including_dcl).and_return(15)

          expect(customer.credit_days_remaining).to eq(15)
        end
      end
    end


    describe '#available_credit' do
      context 'when credit limit is present' do
        it 'calculates available credit correctly' do
          customer = create(:customer, credit_limit: 1000)
          allow(customer).to receive(:due_and_invoices_value).and_return(500)
          
          expect(customer.available_credit).to eq(1000 - 500)
        end
      end
      
      context 'when credit limit is not present' do
        it 'returns nil' do
          customer = create(:customer, credit_limit: nil)
          
          expect(customer.available_credit).to be_nil
        end
      end
    end



    describe '#overdue_days' do
      context 'when there is an overdue invoice date' do
        let(:customer) { create(:customer) }

        it 'returns the number of days overdue' do
          allow(customer).to receive(:oldest_overdue_invoice_date).and_return(Date.new(2023, 8, 1))
          allow(Date).to receive(:current).and_return(Date.new(2023, 8, 5))
          expect(customer.overdue_days).to eq(4)
        end
      end

      context 'when there is no overdue invoice date' do
        let(:customer) { create(:customer) }

        it 'returns nil' do
          allow(customer).to receive(:oldest_overdue_invoice_date).and_return(nil)
          expect(customer.overdue_days).to be_nil
        end
      end
    end

    

    describe '#is_sale_order_allowed?' do
      let(:customer) { build(:customer) }

      context 'when customer is not active' do
        it 'returns false' do
          customer.active = false
          expect(customer.is_sale_order_allowed?).to be_falsey
        end
      end

      context 'when customer is a cash customer' do
        it 'returns true' do
          customer.is_cash_customer = true
          expect(customer.is_sale_order_allowed?).to be_truthy
        end
      end

      context 'when customer is a credit customer and exceeds credit limit' do
        it 'returns false' do
          customer.is_cash_customer = false
          customer.credit_limit = 500
          allow(customer).to receive(:customer_outstanding).and_return(1000) 
  
          expect(customer.is_sale_order_allowed?).to be_falsey
        end
      end
  
      context 'when customer is a credit customer and overdue days exceed payment terms' do
        it 'returns false' do
          customer.is_cash_customer = false
          customer.credit_limit = 1000
          customer.payment_terms = 30
          allow(customer).to receive(:customer_outstanding).and_return(200) 
          allow(customer).to receive(:overdue_days).and_return(45) 
  
          expect(customer.is_sale_order_allowed?).to be_falsey
        end
      end

      context 'when customer is eligible for sale order' do
        it 'returns true' do
          customer.is_cash_customer = false
          customer.credit_limit = 1000
          customer.payment_terms = 30
          allow(customer).to receive(:customer_outstanding).and_return(200) 
          allow(customer).to receive(:overdue_days).and_return(15) 
  
          expect(customer.is_sale_order_allowed?).to be_truthy
        end
      end
    end
    

    describe '#customer_outstanding' do
      let(:customer) { create(:customer) }
      
      context 'when there are Zoho overdue invoices and non-Zoho customer outstanding' do
        it 'returns the sum of Zoho overdue invoices and non-Zoho customer outstanding' do
          allow_any_instance_of(Customer).to receive(:net_zoho_overdue).and_return(100)
          allow_any_instance_of(Customer).to receive(:non_zoho_customer_outstanding).and_return(200)
          
          expect(customer.customer_outstanding).to eq(300)
        end
      end
    end
  

    describe '#non_zoho_customer_outstanding' do
      let(:customer) { create(:customer) }
      
      context 'when there are GRN complete sale orders, Mandi outstanding, and BTR outstanding amount' do
        it 'returns the sum of GRN complete sale orders, Mandi outstanding, and BTR outstanding amount' do
          allow_any_instance_of(Customer).to receive(:grn_complete_so_value).and_return(100)
          allow_any_instance_of(Customer).to receive(:mandi_outstanding).and_return(200)
          allow_any_instance_of(Customer).to receive(:btr_outstanding_amount).and_return(150)
          
          expect(customer.non_zoho_customer_outstanding).to eq(450)
        end
      end
    end


    describe '#dues_to_be_collected' do
      let(:customer) { create(:customer) }
      
      context 'when there are Zoho overdue, GRN complete sale orders, and BTR outstanding amount' do
        it 'returns the sum of Zoho overdue, GRN complete sale orders, and BTR outstanding amount' do
          allow_any_instance_of(Customer).to receive(:net_zoho_overdue).and_return(100)
          allow_any_instance_of(Customer).to receive(:grn_complete_so_value).and_return(200)
          allow_any_instance_of(Customer).to receive(:btr_outstanding_amount).and_return(150)
          
          expect(customer.dues_to_be_collected).to eq(450)
        end
      end
    end


    context 'update_customer_locations method' do
      it 'when add location' do
        customer = create(:customer_mt)
        loc_params = {
           "0" => {"id"=>"6625", "full_address"=>"Pune"}
         }
        customer.update_customer_locations(loc_params)
        expect( customer.locations.length).to eq(2)
        expect(customer.locations.map(&:full_address)).to include("Pune")
      end
      it 'when update location' do
        customer = create(:customer_mt)
        location = build(:farm_location)
        loc_params = {
           "1" => {"id"=>"1233", "full_address"=>"Banglore"},
           "2"=> {"id"=>location.id, "full_address"=>"Chennai"},
         }
        customer.update_customer_locations(loc_params)
        expect(customer.locations.length).to eq(3)
        expect(customer.locations.map(&:full_address)).to include("Chennai")
        expect(customer.locations.map(&:full_address)).to include("Banglore")
      end
      
      it 'customer eligible to send invoice message' do
        customer = create(:customer)
        expect(customer.customer_eligible_to_send_invoice_message?).to eq(true)
        customer.update_columns({:customer_type => "Modern Retail" })
        expect(customer.customer_eligible_to_send_invoice_message?).to eq(false)
      end
    end


    describe '#customer_created_in_zoho?' do
      context 'when zoho_customer_id is present' do
        it 'returns true' do
          customer = build(:customer, zoho_customer_id: 'Z123')
          expect(customer.customer_created_in_zoho?).to be_truthy
        end
      end
    
      context 'when zoho_customer_id is nil' do
        it 'returns false' do
          customer = build(:customer, zoho_customer_id: nil)
          expect(customer.customer_created_in_zoho?).to be_falsey
        end
      end
    
      context 'when zoho_customer_id is empty' do
        it 'returns false' do
          customer = build(:customer, zoho_customer_id: '')
          expect(customer.customer_created_in_zoho?).to be_falsey
        end
      end
    end

    describe '#last_sale_order_date' do
      let(:customer) { create(:customer) }
      
      context 'when there are Velynk sale orders' do
        it 'returns the most recent Velynk sale order date' do
          velynk_so1 = create(:sale_order, customer: customer, order_created_time: 2.days.ago)
          velynk_so2 = create(:sale_order, customer: customer, order_created_time: 1.day.ago)

          expect(customer.last_sale_order_date.to_date).to eq(1.day.ago.to_date)
        end
      end

      context 'when there are no sale orders' do
        it 'returns nil' do
          expect(customer.last_sale_order_date).to be_nil
        end
      end
    end

  end

  context 'scope tests' do 
    let(:not_in_zoho) { Customer.customers_not_in_zoho.pluck(:id).to_a } #collecting from scope
    let(:in_zoho) { Customer.where('DATE(created_at) >= DATE("2023-03-01") AND LENGTH(zoho_customer_id) > 0').pluck(:id).to_a } 
    let(:in_zoho_diff) { (in_zoho - not_in_zoho).to_a } #removes if any same id present

    context 'active inactive filters' do 
      let!(:active_customer) { create(:customer, is_active: true, active: true) }
      let!(:inactive_customer) { create(:customer, is_active: false, active: false) }

      it 'is_active' do
        expect(Customer.is_active).to include(active_customer)
        expect(Customer.is_active).not_to include(inactive_customer)
      end
  
      it 'active' do
        expect(Customer.active).to include(active_customer)
        expect(Customer.active).not_to include(inactive_customer)
      end
  
      it 'inactive' do
        expect(Customer.inactive).to include(inactive_customer)
        expect(Customer.inactive).not_to include(active_customer)
      end
    end 

    it 'search' do
      searched_customer = create(:customer, name: 'John', poc_phone_number: '1234567890', short_code: 'abc')
      expect(Customer.search('John')).to include(searched_customer)
      expect(Customer.search('12345')).to include(searched_customer)
      expect(Customer.search('abc')).to include(searched_customer)
      expect(Customer.search('nonexistent')).not_to include(searched_customer)
    end

    it 'by_zoho_id' do
      zoho_customer = create(:customer, zoho_customer_id: 'Z123')
      expect(Customer.by_zoho_id('Z123')).to include(zoho_customer)
      expect(Customer.by_zoho_id('nonexistent')).not_to include(zoho_customer)
    end

    it 'customers_not_in_zoho scope test' do 
      expect(in_zoho).to eq(in_zoho_diff)
    end 
    let(:customer1) { create(:customer, poc_phone_number: "1234567891") }
    let(:customer2) { create(:customer, poc_phone_number: "1234567892") }
    let(:customer3) { create(:customer, poc_phone_number: "1234567893") }

    it 'created_after_date_filter scope test' do
      c1 = create(:customer, created_at: "2023-03-02") # A customer created after the specified date
      c2 = create(:customer, created_at: "2023-02-28") # A customer created before the specified date
    
      expect(Customer.created_after_date_filter("2023-03-01")).to include(c1)
      expect(Customer.created_after_date_filter("2023-03-01")).not_to include(c2)
    end


    it 'created_n_minutes_ago scope test' do 

      c1 = create(:customer, created_at: 50001.minutes.ago)
      c2 = create(:customer, created_at: 49999.minutes.ago)
    
      expect(Customer.created_n_minutes_ago(50000)).to include(c1)
      expect(Customer.created_n_minutes_ago(50000)).not_to include(c2)
    end 

    it 'of_id' do
      ids = [customer1.id,customer2.id]
      result = Customer.of_id(ids)
      expect(result).to include(customer1, customer2)
      expect(result).not_to include(customer3)
    end

    it 'not_of_id scope test' do 
      excluded_ids = [customer1.id, customer2.id]
      result = Customer.not_of_id(excluded_ids)
      expect(result).to include(customer3)
      expect(result).not_to include(customer1, customer2)
    end

    it 'of_poc_phone_number scope test' do 
      poc_phone_number = "1234567891"
      result = Customer.of_poc_phone_number(poc_phone_number)
      expect(result).to include(customer1)
      expect(result).not_to include(customer2, customer3)
    end

    it 'cash_customers' do
      sample_customers = create_list(:customer, 3)
      cash_customer = create(:customer, is_cash_customer: true)

      expect(Customer.cash_customers).to include(cash_customer)
      expect(Customer.cash_customers).not_to include(sample_customers)
    end

    it 'of_customer_types' do
      customer_gt =  create(:customer_gt) 
      customer_mt =  create(:customer_mt) 

      expect(Customer.of_customer_types(Customer::Type::GT)).to include(customer_gt)
      expect(Customer.of_customer_types(Customer::Type::GT)).not_to include(customer_mt)
    end

    it 'of_users' do
      user1 =  create(:user) 
      user2  = create(:user) 
      user_customers  = create_list(:customer, 2, user_id: user1.id) 

      expect(Customer.of_users([user1.id])).to include(*user_customers)
      expect(Customer.of_users([user2.id])).not_to include(*user_customers)
    end
  end 

  describe 'loc_proximity_sorting scope' do
    let(:ref_lat) { 37.7749 }
    let(:ref_lng) { -122.4194 }

    it 'orders customers by proximity to a given location' do
      
      customer1 = create(:customer)
      location1 = create(:location, lat: 37.7752, lng: -122.4197)
      customer1_location = create(:customer_location, customer: customer1, location: location1)

      customer2 = create(:customer)
      location2 = create(:location, lat: 37.7748, lng: -122.4193)
      customer2_location = create(:customer_location, customer: customer2, location: location2)

      # Customer 3 has no valid location (for testing exclusion) so should be last
      customer3 = create(:customer)
      
      result = Customer.loc_proximity_sorting(ref_lat, ref_lng)
      expect(result).to be_an(ActiveRecord::Relation)
      expect(result).to eq([customer2, customer1, customer3])

    end
  end


end



    # describe '#overdue_days' do
    #   let (:customer) {create(:customer)}
    #   let (:invoice1) {ZohoBooks::Invoice.create(invoice_id: 1,invoice_number:1,total: 100,balance: 100,status: "created",date: "2022-10-11")}
    #   let (:invoice2) {ZohoBooks::Invoice.create(invoice_id: 2,invoice_number:2,total: 100,balance: 100,status: "created",date: "2023-10-11")}
    #   let (:invoice3) {ZohoBooks::Invoice.create(invoice_id: 1, invoice_number: 1, date: 2022-10-11, total: 100, balance: 100, customer_name: "invoice1", customer_id: 1, salesperson_name: "invoice1", cf_velynk_so_id: '123', cf_cost_center: '123', status: 'overdue')}
    #   context 'customer having no invoices' do
    #     it 'returns nil if customer has no invoices' do
    #       expect(customer.overdue_days).to be_nil
    #     end 
    #   end
    #   context 'customer having one invoice' do
    #     it 'returns overdue days if customer has invoice' do
    #       customer.update(zoho_customer_id: '1')
    #       invoice1.update(customer_id: '1')
    #       date = customer.overdue_invoices.first.date
    #       oldest_date = customer.oldest_overdue_invoice_date.to_date
    #       days = (Date.current.to_date - oldest_date).to_i
    #       expect(customer.overdue_days).to eq(days)
    #       expect(date).to eq(oldest_date)
    #     end
    #   end
    #   context 'customer having multiple invoices' do 
    #     it 'returns oldest overdue days for invoice' do
    #       customer.update(zoho_customer_id: '1')
    #       invoice1.update(customer_id: '1')
    #       invoice2.update(customer_id: '1')
    #       overdue_days_1 = (Date.current.to_date - customer.overdue_invoices.first.date.to_date).to_i
    #       overdue_days_2 = (Date.current.to_date - customer.overdue_invoices.second.date.to_date).to_i
    #       oldest_days = (Date.current.to_date - customer.oldest_overdue_invoice_date.to_date).to_i
    #       expect(customer.overdue_days).not_to eq(nil)
    #       expect(customer.overdue_days).to eq(oldest_days)
    #       expect(customer.overdue_days).to eq(overdue_days_1) if overdue_days_1 > overdue_days_2
    #       expect(customer.overdue_days).to eq(overdue_days_2) if overdue_days_2 > overdue_days_1
    #     end
    #   end
    #   context 'After deleting customer invoices' do 
    #     it 'returns nil as overdue days' do
    #       customer.update(zoho_customer_id: '1')
    #       invoice1.update(customer_id: '1')
    #       invoice2.update(customer_id: '1')
    #       invoice1.destroy
    #       invoice2.destroy
    #       expect(customer.overdue_days).to eq(nil)
    #     end
    #   end

    # end


