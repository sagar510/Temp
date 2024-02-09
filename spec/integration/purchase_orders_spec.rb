# require 'swagger_helper'

# describe 'PurchaseOrders API' do
#   let(:user_id) do
#     User.create(name: "TestUser",
#                 phone_number: "777778888",
#                 role: "Admin",
#                 skip_password_validation: true).id
#   end

#   let(:partner_id) do
#     Partner.create(name: "TestPartner",
#                   phone_number: "7777799999",
#                   role: "Farmer").id
#   end

#   let(:services_details) do
#     {
#       labour_cost_rs: 100,
#       packaging_cost_rs: 50,
#       commision_rs: 20,
#       unit: 'kg'
#     }
#   end

#   let(:purchase_order_id) do
#     PurchaseOrder.create(
#                   buyer_id: user_id,
#                   field_executive_id: user_id,
#                   farmer_id: partner_id,
#                   service_provider_id: user_id,
#                   services_details: services_details).id
#   end

#   path '/purchase_orders.json' do
#     post 'Creates a purchase_order' do
#       tags 'PurchaseOrders'
#       consumes 'application/json'
#       produces 'application/json'
#       parameter name: :purchase_order, in: :body, schema: {
#         type: :object,
#         properties: {
#           buyer_id: { type: :integer },
#           field_executive_id: { type: :integer },
#           farmer_id: { type: :integer },
#           service_provider_id: { type: :integer },
#           services_details: { type: :object }
#         },
#         required: [ 'buyer_id', 'field_executive_id', 'farmer_id', 'service_provider_id', 'services_details' ]
#       }

#       response '200', 'ok' do
#         schema  type: :object,
#                   properties: {
#                     id: { type: :integer },
#                     identifier: { type: :string },
#                     buyer: { type: :object,
#                       properties: {
#                         id: { type: :integer },
#                         name: { type: :string }
#                     }},
#                     field_executive: { type: :object,
#                       properties: {
#                         id: { type: :integer },
#                         name: { type: :string }
#                     }},
#                     message: { type: :string }
#                   },
#                 required: [ 'id', 'identifier', 'buyer', 'field_executive', 'message' ]

#         let(:purchase_order) {{ buyer_id: user_id, field_executive_id: user_id, farmer_id: partner_id, service_provider_id: partner_id, services_details: services_details }}
#         run_test!
#       end
#     end
#   end

#   path '/purchase_orders/{id}.json' do

#     get 'Retrieves a Purchase Order' do
#       tags 'PurchaseOrders'
#       produces 'application/json'
#       parameter name: :id, :in => :path, :type => :string
#       response '200', 'ok' do
#         schema  type: :object,
#                   properties: {
#                   id: { type: :integer },
#                   identifier: { type: :string },
#                   buyer: { type: :object,
#                     properties: {
#                       id: { type: :integer },
#                       name: { type: :string }
#                   }},
#                   field_executive: { type: :object,
#                     properties: {
#                       id: { type: :integer },
#                       name: { type: :string }
#                   }},
#                   farmer: { type: :object,
#                     properties: {
#                       id: { type: :integer },
#                       name: { type: :string }
#                   }},
#                   service_provider: { type: :object,
#                     properties: {
#                       id: { type: :integer },
#                       name: { type: :string }
#                   }},
#                   services_details: { type: :object,
#                     properties: {
#                       labour_cost_rs: { type: :integer },
#                       packaging_cost_rs: { type: :integer },
#                       commision_rs: { type: :integer },
#                       unit: { type: :string }
#                   }},
#                   purchase_items: { type: :array,
#                     items: :object,
#                       properties: {
#                         id: { type: :integer },
#                         identifier: { type: :string },
#                         name: { type: :string },
#                         tonnage: { type: :string },
#                         agreed_value: { type: :string }
#                   }},
#                   message: { type: :string }
#                 },
#           required: [ 'id', 'identifier', 'buyer', 'farmer', 'field_executive', 'service_provider', 'purchase_items', 'message', 'services_details' ]
#         let(:id) { purchase_order_id }
#         run_test!
#       end
#     end
#   end
# end