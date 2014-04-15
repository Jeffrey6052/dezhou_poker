class CreateDezhouReports < ActiveRecord::Migration
  def change

    create_table :dezhou_reports do |t|

      #基本信息
      t.string :playerPokersSlug #倒序排列的牌值组+同色状态 3Q1 ---> Q31 (主键)
      t.integer :allGameTimes, default:0 #比赛中出现的次数
      t.string :playerPokers #倒序排列的牌值组 3Q ---> Q3
      t.boolean :isPlayerPokersFlush #是否相同色

      ###翻牌阶段统计
      t.integer :flopWinnerTimes, default:0 #第一名次数
      t.integer :flopSecondPlaceTimes, default:0 #第二名次数
      t.integer :flopThirdPlaceTimes, default:0 #第三名次数

      ###转牌阶段统计
      t.integer :turnWinnerTimes, default:0 #第一名次数
      t.integer :turnSecondPlaceTimes, default:0 #第二名次数
      t.integer :turnThirdPlaceTimes, default:0 #第三名次数

      ###河牌阶段统计
      t.integer :riverWinnerTimes, default:0 #第一名次数
      t.integer :riverSecondPlaceTimes, default:0 #第二名次数
      t.integer :riverThirdPlaceTimes, default:0 #第三名次数

      #其它
      t.integer :playerSum #玩家数
    end
    
    add_index :dezhou_reports, :playerPokersSlug
    add_index :dezhou_reports, :playerSum
  end
end
