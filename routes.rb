require 'sinatra'
require 'sinatra/cookies'
require 'httparty'
require 'json'
require 'set'

require './helpers'

get '/' do

  # I was previously storing the access_token as a cookie
  # redirect '/oauth/authorize' if cookies[:returnly_challenge] == nil
  # access_token = cookies[:returnly_challenge]

  # not a great idea to include the access_token here but I want to make sure it runs for Returnly
  access_token = 'afb1e4a004ad421610cf643e2640a871'

  # get all the orders from shopify store
  orders_url = 'https://returnly-challenge.myshopify.com/admin/orders.json'
  headers = { 'X-Shopify-Access-Token' => "#{access_token}" }
  response = HTTParty.get orders_url, headers: headers
  orders = JSON.parse(response.body)['orders']

  most_and_least_frequent_items = determine_most_and_least_frequent_items orders
  most_frequent_item = most_and_least_frequent_items[:most]
  least_frequent_item = most_and_least_frequent_items[:least]

  # render the index template with all the local vars
  erb :index, locals: { 
    num_orders: count_num_orders(orders), 
    num_unique_customers: calculate_num_unique_customers(orders),
    most_frequent_item: most_frequent_item,
    least_frequent_item: least_frequent_item,
    median_order_value: determine_median_order_value(orders),
    shortest_consecutive_order_interval: get_shortest_consecutive_order_interval(orders)
  }

end

# this stuff isn't needed anymore because I included the access_token in a .env

get '/oauth/authorize' do 

  api_key = '939978c19a72ee7a9f05e159ba1f42e4' # should consider moving this into dotenv

  redirect_url = 'http://localhost:4567/oauth/verify' # occurs after user authorizes the app; matches redirect setting in shopify partners page
  scope = 'read_orders,write_orders' # determines what the app can do with shopify data, once authorized
  nonce = Random.new # random value for uniquely identifying authorization requests; security mechanism

  auth_url = 'https://returnly-challenge.myshopify.com/admin/oauth/authorize'
  auth_params = "client_id=#{api_key}&scope=#{scope}&redirect_uri=#{redirect_url}&state=#{nonce}"
  redirect "#{auth_url}?#{auth_params}"

end

get '/oauth/verify' do

  api_key = '939978c19a72ee7a9f05e159ba1f42e4' # returnly-challenge app api key (from https://app.shopify.com/services/partners/api_clients/1542215)
  secret = '6c12380b71906ede171ef3e68b9eb804' # returnly-challenge app secret; see link above

  # skipping the nonce, hmac and shop validation for now
  # exchange the auhorization_code for a permanent access token via another request
  authorization_code = params['code']
  token_url = 'https://returnly-challenge.myshopify.com/admin/oauth/access_token'
  response = HTTParty.post token_url, body: { client_id: api_key, client_secret: secret, code: authorization_code }
  
  # parse the json to get the access token; store it in cookies for later (should consider using sessions instead)
  access_token = JSON.parse(response.body)['access_token']
  cookies[:returnly_challenge] = access_token # get rid of this!!! use dotenv instead
  
  redirect '/'

end