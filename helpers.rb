def count_num_orders orders
  orders.length
end

def calculate_num_unique_customers orders
  
  unique_customers = Set.new

  orders.each do |order|
    customer_id = order['customer']['id'].to_i
    unique_customers.add(customer_id)
  end

  unique_customers.size()

end

def determine_most_and_least_frequent_items orders

  counts = get_item_frequency_counts orders

  max_id = nil
  max_count = 0
  min_id = counts.keys.first
  min_count = counts.values.first

  counts.each { |id, count| 
    if count > max_count
      max_id = id
      max_count = count
    end
    if count < min_count
      min_id = id
      min_count = count
    end
  }

  { most: max_id, least: min_id }

end

def determine_median_order_value orders

  values = get_order_values orders

  if values.size > 0
    values.sort! # do this in place for memory conservation; uses a quicksort implementation i think
    midpoint = (values.size / 2).to_i
    output = values[midpoint]
  else 
    output = nil
  end

  output

end

# it would be faster to combine get_item_frequency_counts and get_order_values into a single loop

def get_item_frequency_counts orders

  counts = {}

  orders.each do |order|
    items = order['line_items']
    items.each do |item|
      id = item['product_id']
      if counts[id]
        counts[id] += 1
      else
        counts[id] = 1
      end
    end
  end

  counts

end

def get_order_values orders

    values = []
    orders.each do |order|
      value = order['total_line_items_price'].to_i
      values.push value
    end

    values

end

def get_shortest_consecutive_order_interval orders

  customer_timestamps = get_customers_and_order_timestamps orders

  intervals = []
  customer_timestamps.each do | customer_id, timestamps_array |

    # need at least two entries for an interval to exist
    if timestamps_array.size >= 2
      shortest_interval = get_shortest_interval_from_timestamps_array timestamps_array
      intervals.push shortest_interval
    end

  end

  # return the minimum from intervals
  intervals.min

end

def get_shortest_interval_from_timestamps_array timestamps
  # sort timestamps
  timestamps.sort!

  # timestamps are now sorted earliest to latest, so subtract earlier values from later values
  # initialize the min value with difference between the first pair
  min = get_diff_between_timestamps_in_seconds timestamps[1], timestamps[0]
  timestamps.each_slice(2) do |earlier, later|
    # compare each timestamp difference with the min
    current = get_diff_between_timestamps_in_seconds later, earlier
    min = current if current < min
  end

  min

end

def get_diff_between_timestamps_in_seconds a, b

  diff_in_rational = a - b
  seconds_in_a_day = 24 * 60 * 60
  diff_in_seconds = diff_in_rational * seconds_in_a_day
  diff_in_seconds.to_i

end

def get_customers_and_order_timestamps orders

    output = {} # e.g. { customer_id: [ timestamp, timestamp, timestamp ]}

    orders.each do |order|
      customer_id = order['customer']['id']
      timestamp = DateTime.parse(order['created_at'])
      output[customer_id] = [] if output[customer_id] == nil
      output[customer_id].push timestamp
    end

    output
end

def calculate_diff_between_timestamps timestamps
  diff = 0
  timestamp1 = timestamp[0].to_time
  timestamp2 = timestamp[1].to_time
  if timestamp1 > timestamp2
    diff = timestamp1 - timestamp2 #
  else
  end
end