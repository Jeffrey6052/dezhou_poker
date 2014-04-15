
class DezhouReport < Sequel::Model

  set_allowed_columns :playerPokersSlug,:allGameTimes,:playerPokers,:isPlayerPokersFlush,
                      :flopWinnerTimes,:flopSecondPlaceTimes,:flopThirdPlaceTimes,
                      :turnWinnerTimes,:turnSecondPlaceTimes,:turnThirdPlaceTimes,
                      :riverWinnerTimes,:riverSecondPlaceTimes,:riverThirdPlaceTimes,
                      :playerSum

end
