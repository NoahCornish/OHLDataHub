library(OHLpkg)

dir.create(
  "data/current",
  recursive = TRUE,
  showWarnings = FALSE
)

season <- "2027 Season"

message("Downloading current skater stats...")

skaters <- get_RawStats(
  season_name = season
)

write.csv(
  skaters,
  "data/current/skaters.csv",
  row.names = FALSE
)

message("Done.")

