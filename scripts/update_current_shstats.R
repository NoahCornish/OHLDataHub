library(OHLpkg)

season <- "2027 Season"

message("Downloading current short-handed stats...")

sh_stats <- get_SHStats(
  season_name = season,
  min_games = 0
)

write.csv(
  sh_stats,
  "data/current/sh.csv",
  row.names = FALSE
)

message("Done.")
