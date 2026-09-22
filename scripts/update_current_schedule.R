library(OHLpkg)

message("Downloading current OHL schedule...")

schedule <- get_Schedule()

write.csv(
  schedule,
  "data/current/schedule.csv",
  row.names = FALSE
)

message("Done.")
