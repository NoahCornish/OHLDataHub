source("scripts/update_current_playerstats.R")
source("scripts/update_current_goaliestats.R")
source("scripts/update_current_schedule.R")
source("scripts/update_current_evstats.R")
source("scripts/update_current_shstats.R")
source("scripts/update_current_rookies.R")
source("scripts/update_draft_players.R")

message("All current OHL data updated successfully.")

# ------------------------------------------------------------
# RECORD DATA REFRESH TIME
# ------------------------------------------------------------

refresh <- data.frame(
  refreshed_at = format(
    Sys.time(),
    tz = "America/Toronto",
    format = "%Y-%m-%d %I:%M:%S %p %Z"
  ),
  stringsAsFactors = FALSE
)

write.csv(
  refresh,
  "data/current/refresh.csv",
  row.names = FALSE
)

message(
  "Refresh time recorded: ",
  refresh$refreshed_at
)
