library(OHLpkg)

season <- "2027 Season"

message("Downloading current draft-eligible stats...")

draft <- get_DYStats(
  season_name = season,
  min_games = 0
)

write.csv(
  draft,
  "data/current/draft.csv",
  row.names = FALSE
)

message("Done.")
