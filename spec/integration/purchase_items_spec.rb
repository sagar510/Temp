# require 'swagger_helper'

# describe 'PurchaseItems API' do

#   path '/api/v1/purchase_items' do

#     post 'Creates a purchase_item' do
#       tags 'PurchaseItems'
#       consumes 'application/json', 'application/xml'
#       parameter name: :purchase_item, in: :body, schema: {
#         type: :object,
#         properties: {
#           name: { type: :string },
#           photo_url: { type: :string },
#           status: { type: :string }
#         },
#         required: [ 'name', 'status' ]
#       }

#       response '201', 'purchase_item created' do
#         let(:purchase_item) { { name: 'Dodo', status: 'available' } }
#         run_test!
#       end

#       response '422', 'invalid request' do
#         let(:purchase_item) { { name: 'foo' } }
#         run_test!
#       end
#     end
#   end

#   path '/api/v1/purchase_items/{id}' do

#     get 'Retrieves a purchase_item' do
#       tags 'PurchaseItems'
#       produces 'application/json', 'application/xml'
#       parameter name: :id, :in => :path, :type => :string

#       response '200', 'name found' do
#         schema type: :object,
#           properties: {
#             id: { type: :integer, },
#             name: { type: :string },
#             photo_url: { type: :string },
#             status: { type: :string }
#           },
#           required: [ 'id', 'name', 'status' ]

#         let(:id) { PurchaseItem.create(name: 'foo', status: 'bar', photo_url: 'http://example.com/avatar.jpg').id }
#         run_test!
#       end

#       response '404', 'purchase_item not found' do
#         let(:id) { 'invalid' }
#         run_test!
#       end
#     end
#   end
# end