library(OHLpkg)

season <- "2027 Season"

message("Downloading current goalie stats...")

goalies <- get_GoalieStats(
  season_name = season,
  min_games = 0
)

write.csv(
  goalies,
  "data/current/goalies.csv",
  row.names = FALSE
)

message("Done.")
