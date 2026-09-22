library(OHLpkg)

season <- "2027 Season"

message("Downloading current rookie stats...")

rookies <- get_RKStats(
  season_name = season,
  min_games = 0
)

write.csv(
  rookies,
  "data/current/rookies.csv",
  row.names = FALSE
)

message("Done.")
