class Advertisement < ApplicationRecord

  # Matches size of the format 1*1, 1*2 .... 3*3
  validates :size, format: { with: /[1-3]\*[1-3]/ } 
  validates :price, presence: true

  # Selects unique ad sizes with max value and prioritize by area of coverage
  # Calls most_lucrative method in loop with ordered_ads rotate
  #
  def self.ads 
    most_lucrative_combination, advertisements, prioritized_hash = {}, {}, {}
    total_blocks, flag = 0, false

    all.each do |ad|
      if advertisements[ad.size] 
        if advertisements[ad.size] < ad.price.to_f
          advertisements[ad.size] =  ad.price.to_f
        end
      else
        advertisements = advertisements.merge({ad.size => ad.price.to_f})
      end
    end

    advertisements.each do |k,v|
      i = multiply_dimentions(k)
      for_one_area = v/((i.to_f/9)*100)
      prioritized_hash = prioritized_hash.merge({k => for_one_area})
    end
    ordered_ads = Hash[prioritized_hash.sort_by{|k, v| v}.reverse].keys

      if ordered_ads.present?
        rotated_ordered_ads = ordered_ads
        rotate = false

        while true
          if rotated_ordered_ads == ordered_ads && rotate
            break
          else
            rotate = true
            ret_val = most_lucrative(rotated_ordered_ads)
            rotated_ordered_ads = rotated_ordered_ads.rotate(1)

            total = 0
            ret_val[0].each do |size, value|
              total +=  advertisements[size] * value
            end
            most_lucrative_combination.merge!({ret_val[0] => total})
          end
        end
      end
    return most_lucrative_combination.max_by{|k,v| v}
  end

  # Multiplies the size values
  # Returns for example '3X3'=9
  #
  def self.multiply_dimentions size
    size.scan(/\d+/).map(&:to_i).inject(:*)
  end

  # Gets the prioritized array of sizes
  # By checking total number of blocks and horizontalXvertical blocks spaces -
  # left it will fill up most lucrative combination.
  # Returns most lucrative combination and total blocks count
  #
  def self.most_lucrative ads
    @x, @y = 0, 0
    total_blocks, most_lucrative_combination = 0, {}

    ads.each do |a|
      count = multiply_dimentions(a)
      while true
        if (( most_lucrative_combination[a].to_i > 0 if a == '2*2') || (most_lucrative_combination[a].to_i >= 3 if a != '1*1')) || count+total_blocks > 9 || limit_exceeded?(a)#count+total_blocks > 9 || limit_exceeded?(a)
          break
        else
          total_blocks += count
          if most_lucrative_combination[a]
            most_lucrative_combination[a] += 1
          else
            most_lucrative_combination = most_lucrative_combination.merge({a => 1})
          end
        end
      end
    end
    return [most_lucrative_combination, total_blocks]
  end

  # Receives ad size
  # Checks if horizontaXverticle limit or block space exceeded
  # Returns return_value, true or false
  #
  def self.limit_exceeded? size
    return_value = false
    xandy = size.scan(/\d+/).map(&:to_i)
    first = xandy.first
    last = xandy.last
    first_last = first * last

    if first > last
      if @x+first_last > 9
        return_value = true
      else
        @x += first_last
      end
    elsif first < last
      if @y+first_last > 9
        return_value = true
      else
        @y += last
      end
    else
      if @x+first_last > 9 && @y+first_last > 9
        return_value = true
      else
        @x += first_last
        @y += first_last
      end
    end

    return return_value
  end
end
