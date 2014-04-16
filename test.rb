

array = []
10.times do
  array << rand(10)
end

players = []
array.each_with_index do |n,index|
  player = {
    value: n,
    rank: 1
  }
  players << player
end

#p players



players.each_with_index do |p1,index|
  players[index+1..-1].each do |p2|
    if p1[:value] < p2[:value]
      p1[:rank] = p1[:rank] + 1
    elsif p1[:value] > p2[:value]
      p2[:rank] = p2[:rank] + 1
    end
  end
end 

players.sort_by!{|player| player[:rank] }

puts '-----------------------'
players.each do |player|
  puts "#{player[:value]} #{player[:rank]}"
end


