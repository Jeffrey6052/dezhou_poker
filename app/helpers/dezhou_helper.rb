# ♥8 ♥T ♦K ♠9 ♣4

# ♥7 ♣2 ♦5 ♦3 ♠A

# ♥ ♦ ♠ ♣

# 1 2 3 4 5 6 7 8 9 T J Q K A

#裁判
module Judgment

  Value_Hash={"A"=>14,"2"=>2,"3"=>3,"4"=>4,"5"=>5,"6"=>6,"7"=>7,"8"=>8,"9"=>9,"T"=>10,"J"=>11,"Q"=>12,"K"=>13}

  class << self

    def check_winner(poker1,poker2)
      peace=0
      win=0
      a_hand,b_hand=get_hand(poker1),get_hand(poker2)
      a_suit,b_suit=get_suit(poker1),get_suit(poker2)   #同色为1，不同色为0
      
      a_straight,b_straight=get_straight(a_hand),get_straight(b_hand)   #顺子为对应最小的牌，不是顺子为0
      
      a_combine,b_combine=a_hand.uniq.map{|i|i=a_hand.count(i)}.sort.reverse[0..1],b_hand.uniq.map{|i|i=b_hand.count(i)}.sort.reverse[0..1]   #牌的组合，四张相同的牌为[4,1]，三张+两张为[3,2],三张为[3,1],两张为[2,1],一张为[1,1]
      a_value,b_value=[],[]
      a_hand.uniq.each do |n|
        a_value<<[a_hand.count(n),n]
      end
      b_hand.uniq.each do |n|
        b_value<<[b_hand.count(n),n]
      end
      a_value,b_value=a_value.sort.reverse.map{|a|a=a[1]},b_value.sort.reverse.map{|a|a=a[1]}  #组合的牌，数量多的牌在前，少的牌在后，用于相同组合时比大小用
      #print "hand (#{a_hand} : #{b_hand})".ljust(50)+"suit (#{a_suit} : #{b_suit})".ljust(15)+"straight (#{a_straight} : #{b_straight})".ljust(19)+"combine #{a_combine} : #{b_combine}".ljust(28)+"value #{a_value} : #{b_value}".ljust(50)
      if a_suit==1&&b_suit==1   #都是同花
        if a_straight>b_straight #(1.顺子，B的顺子比A小，或者B不是顺子为赢)
          win+=1
          #print "win"
          return 1
        elsif a_value==b_value
          peace=1
          #print "peace"
          return 0
        end
        if a_straight==0&&b_straight==0 #（2.都不是顺子但牌值比B大为赢）
          (0..a_value.length-1).each do |index|   # 从大到小逐一比较牌值
            if a_value[index]>b_value[index]
              win+=1
              #print "win"
              return 1
            elsif a_value[index]<b_value[index]
              return -1
            end
          end
          if a_value==b_value
            peace=1
            #print "peace"
            return 0
          end
        end
      end

      if a_suit==1&&b_suit==0   #A是同花，B不是
        if a_straight>0    # (1. 同花顺，赢)
          win+=1
          #print "win"
          return 1
        end
        if b_combine!=[4,1]&&b_combine!=[3,2]  #(2. B没有摸到4+1或者3+2，赢)
          win+=1
          #print "win"
          return 1
        end
      end

      if a_suit==0&&b_suit==0   #都不是同花
        if a_straight>0&&b_straight>0
          if a_straight>b_straight   #都是顺子，且A大，赢
            win+=1
            #print "win"
            return 1
          elsif a_straight==b_straight
            peace=1
            #print "peace"
            return 0
          end
        end
        if a_straight>0&&b_straight==0&&b_combine!=[3,2]&&b_combine!=[4,1]  #A是顺子，B不是顺子，则B不能摸到3+2或者4+1,赢
          win+=1
          #print "win"
          return 1
        end
        if a_straight==0&&b_straight>0&&(a_combine==[3,2]||a_combine==[4,1])         #A不是顺子，B是顺子，则A必须摸到3+2或者4+1
          win+=1
          #print "win"
          return 1
        end
        if a_straight==0&&b_straight==0         #都不是顺子，
          (0..1).each do |index|                 #组合比B大，[4,1]>[3,2]>[3,1]>[2,2].[2,1]>[1,1]
            if a_combine[index]>b_combine[index]
              win+=1
              #print "win"
              return 1
            elsif a_combine[index]<b_combine[index]
              #print "lose"
              return -1
            end
          end
          if a_combine==b_combine         #组合都相同，比较牌值大小
            if a_value==b_value
              peace=1
              #print "peace"
              return 0
            end
            (0..a_value.length-1).each do |index|   # 从大到小逐一比较牌值
              if a_value[index]>b_value[index]
                win+=1
                #print "win"
                return 1
              elsif a_value[index]<b_value[index]
                #print "lose"
                return -1
              end
            end
          end
        end
      end

      if a_suit==0&&b_suit==1&&b_straight==0&&(a_combine==[4,1]||a_combine==[3,2])   #B是同花，A不是同花（B必须不是顺子，A的组合必须为[3,2]或者[4,1]才能取胜）
        win+=1
        #print "win"
        return 1
      end
      if win!=1&&peace!=1
        #print "lose"
        return -1
      end
    end

    def format_pokers(pokers)
      pokers.join(' ')
    end

    def show_pokers(pokers)
      puts format_pokers(pokers)
    end

    private

    def get_hand(poker)
      poker.map{|i|i=Value_Hash[i[1]]}
    end

    def get_suit(poker)
      poker.map{|i|i=i[0]}.uniq.length==1?1:0
    end

    def get_straight(hand)
      min = hand.min
      tmp = hand.map{|i|i=i-min+1}.sort.join("")
      case tmp
      when '123413'
        1
      when '12345'
        hand.min
      else
        0
      end
    end

  end
end

# poker1 = '♥8 ♥T ♦K ♠9 ♣A'.split(' ')
# poker2 = '♥7 ♣2 ♦5 ♦3 ♠A'.split(' ')
# p Judgment.check_winner(poker1,poker2)

#牌局 允许2-12人
class DeZhouPoker

  attr_reader :players

  Value_Hash = Judgment::Value_Hash.dup

  #记录最后一场比赛的情况
  Last_Match = {}

  def initialize(playerSum)
    raise "need at least (2) players and at most (12) players" if ( playerSum = playerSum.to_i ) < 2 or playerSum > 12
    @publicPokers      = []
    @publicChoices     = []
    @stack             = set_poker_stack
    @playerSum         = playerSum
    @players           = set_players(playerSum)

    @all_steps = [:flop,:turn,:river]
    @step_num = 0
    

    #翻盘阶段 flop
    add_public_pokers(3)
    save_step_result

    #转盘阶段 turn
    add_public_pokers(1)
    save_step_result

    #河牌阶段 river 
    add_public_pokers(1)
    save_step_result
    
    save_result_report_to_database

    DeZhouPoker::Last_Match[@playerSum] = {players:@players,publicPokers:@publicPokers}

    # @players.each do |player|
    #   nuts = player[:nuts]
    #   Judgment.show_pokers(nuts)
    # end
  end

  #生成牌堆，一副牌，共52张 + 洗牌
  # ♥ ♦ ♠ ♣
  # 1 2 3 4 5 6 7 8 9 T J Q K A
  def set_poker_stack
    flowers = ['♥','♦','♠','♣']
    fonts = ['2','3','4','5','6','7','8','9','T','J','Q','K','A']
    stack = []
    flowers.each do |n|
      fonts.each do |m|
        stack << "#{n}#{m}"
      end
    end
    #洗牌，3-10次
    refresh_time = 3+rand(8)
    refresh_time.times do
      stack = stack.sample(52)
    end
    stack
  end

  #设置玩家，发初始的两张牌
  def set_players(players_sum)
    players = []
    (1..players_sum).each do |place|
      players << {place:place,pokers:[],flop:{},turn:{},river:{}}
    end

    #按顺序给每人发两张牌
    2.times do 
      players.each do |player|
        player[:pokers] << @stack.shift
      end
    end
    players
  end

  #翻公共牌
  def add_public_pokers(sum)
    sum.times do 
      break if @publicPokers.length >= 5
      @publicPokers << @stack.shift
    end
    #Judgment.show_pokers(@publicPokers)
    @publicPokers
  end

  #刷新公共牌的所有组合
  def refresh_public_choices
    raise "need at least (3) public pokers" if @publicPokers.count < 3
    raise "too many public pokers, the max allow sum is (5)" if @publicPokers.count > 5
    @publicPokers.combination(3).each do |choice|
      #Judgment.show_pokers(choice)
      @publicChoices << choice
    end
  end

  #结合手牌和公共牌，算出最优组合牌
  def find_nuts(player_pokers)
    choice_count = @publicChoices.count
    raise "did't find any public choice" if choice_count < 1
    case choice_count
    when 1
      return player_pokers + @publicChoices.first
    else
      all_hands = @publicChoices.collect{|choice| player_pokers + choice }
      all_hands.sort! {|x,y| Judgment.check_winner(y,x) }
      return all_hands.first
    end
  end

  #计算最终结果
  def save_step_result

    step = @all_steps[@step_num]

    raise "step didnt find,there maybe got too many steps" unless step

    @step_num += 1

    refresh_public_choices

    @players.each do |player|
      player[step][:rank] = 1
      player[step][:nuts] = find_nuts(player[:pokers])
    end

    @players.each_with_index do |p1,index|
      @players[index+1..-1].each do |p2|
        answer = Judgment.check_winner(p1[step][:nuts],p2[step][:nuts])
        case answer
        when -1
          p1[step][:rank] = p1[step][:rank] + 1
        when 1
          p2[step][:rank] = p2[step][:rank] + 1
        end
      end
    end

  end

  #保存结果数据，统计前三名的详细信息
  def save_result_report_to_database

    @players.each do |player|

      pokers = player[:pokers]
      v1,v2 = pokers[0][1],pokers[1][1]
      playerPokers = Value_Hash[v1] > Value_Hash[v2] ? "#{v1}#{v2}" : "#{v2}#{v1}"
      isPlayerPokersFlush = pokers[0][0]==pokers[1][0]
      playerPokersSlug = playerPokers + (isPlayerPokersFlush ? '1' : '0')

      report = DezhouReport.where(playerPokersSlug:playerPokersSlug,playerSum:@playerSum).first
      if report
        update_temp = {
          allGameTimes: report.allGameTimes+1,
        }

        @all_steps.each do |step|
          tmp_rank = player[step][:rank]
          case tmp_rank
          when 1
            case step
            when :flop
              update_temp[:flopWinnerTimes] = report.flopWinnerTimes + 1
            when :turn
              update_temp[:turnWinnerTimes] = report.turnWinnerTimes + 1
            when :river
              update_temp[:riverWinnerTimes] = report.riverWinnerTimes + 1
            end
          when 2
            case step
            when :flop
              update_temp[:flopSecondPlaceTimes] = report.flopSecondPlaceTimes + 1
            when :turn
              update_temp[:turnSecondPlaceTimes] = report.turnSecondPlaceTimes + 1
            when :river
              update_temp[:riverSecondPlaceTimes] = report.riverSecondPlaceTimes + 1
            end
          when 3  
            case step
            when :flop
              update_temp[:flopThirdPlaceTimes] = report.flopThirdPlaceTimes + 1
            when :turn
              update_temp[:turnThirdPlaceTimes] = report.turnThirdPlaceTimes + 1
            when :river
              update_temp[:riverThirdPlaceTimes] = report.riverThirdPlaceTimes + 1
            end
          end
        end

        report.update(update_temp)
      else
        create_temp = {
          playerPokersSlug:playerPokersSlug,
          allGameTimes:1,
          playerPokers:playerPokers,
          isPlayerPokersFlush:isPlayerPokersFlush,
          playerSum:@playerSum
        }

        @all_steps.each do |step|
          tmp_rank = player[step][:rank]
          case tmp_rank
          when 1
            case step
            when :flop
              create_temp[:flopWinnerTimes] = 1
            when :turn
              create_temp[:turnWinnerTimes] = 1
            when :river
              create_temp[:riverWinnerTimes] = 1
            end
          when 2
            case step
            when :flop
              create_temp[:flopSecondPlaceTimes] = 1
            when :turn
              create_temp[:turnSecondPlaceTimes] = 1
            when :river
              create_temp[:riverSecondPlaceTimes] = 1
            end
          when 3  
            case step
            when :flop
              create_temp[:flopThirdPlaceTimes] = 1
            when :turn
              create_temp[:turnThirdPlaceTimes] = 1
            when :river
              create_temp[:riverThirdPlaceTimes] = 1
            end
          end
        end

        DezhouReport.create(create_temp)
      end
    end
  end

end

#10 9 8 7 6 5 4 3 2 1


#DeZhouPoker.new(10)

#poker1 = %w[♥A ♥2 ♦3 ♠4 ♣5]
#poker2 = %w[♥A ♥A ♦A ♠5 ♣4]
#p Judgment.check_winner(poker1,poker2)

# ♥7 ♣2 ♦5 ♦3 ♠A






