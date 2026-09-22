library(OHLpkg)

season <- "2027 Season"

message("Downloading current even-strength stats...")

ev_stats <- get_EVStats(
  season_name = season,
  min_games = 0
)

write.csv(
  ev_stats,
  "data/current/ev.csv",
  row.names = FALSE
)

message("Done.")
