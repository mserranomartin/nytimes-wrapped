# parameters
chat_filepath <- file("Chat de WhatsApp con Alicia YoduroDaluminio.txt")

library(dplyr)
source("parser-functions.R")
connections <- chat_filepath |> readLines() |> parse_connections()
names <- names(connections)

overall <- connections |> lapply(\(x) {
  x$Points <- rowSums(x[,3:6])
  return(x[, c("Puzzle", "Tries", "Points")])
})
overall <- merge(overall[[1]], overall [[2]], by = "Puzzle", suffixes = paste0(".", names))
overall$Winner <- ifelse(overall[, paste0("Points.", names[1])] > overall[, paste0("Points.", names[2])], names[1],
                         ifelse(overall[, paste0("Points.", names[1])] < overall[, paste0("Points.", names[2])], names[2],
                                "Tie"))
subs <- overall$Winner == "Tie" & rowSums(overall[, paste0("Points.", names)]) != 0
overall$Winner[subs] <- ifelse(overall[subs, paste0("Tries.", names[1])] < overall[subs, paste0("Tries.", names[2])], names[1],
                               ifelse(overall[subs, paste0("Tries.", names[1])] > overall[subs, paste0("Tries.", names[2])], names[2],
                                      "Tie")) 

overall_winner <- table(Winner = overall$Winner) |> as.data.frame()
colors_abs <- connections |> sapply(\(x) colSums(x[,3:6])) |>
  as.data.frame()
colors_rel <- (colors_abs / nrow(connections[[1]]) ) |> round(3)
colors_abs <- colors_abs |> mutate(.before = 1, Color = rownames(colors_abs))
colors_rel <- colors_rel |> mutate(.before = 1, Color = rownames(colors_abs))
tries <- data.frame(Tries = 4:8)
tries_1 <- table(overall[, paste0("Tries.", names[1])]) |> as.data.frame()
colnames(tries_1) <- c("Tries", names[1])
tries_2 <- table(overall[, paste0("Tries.", names[2])]) |> as.data.frame()
colnames(tries_2) <- c("Tries", names[2])
tries <- tries |> merge(y = tries_1, by.x = "Tries") |> merge(y = tries_2, by.x = "Tries")
mistakes <- tries
colnames(mistakes)[1] <- "Mistakes"
mistakes$Mistakes <- tries$Tries - 4
rainbows <- c(sum(connections[[1]]$Rainbow), sum(connections[[2]]$Rainbow)) |> matrix(ncol = 2) |> as.data.frame()
colnames(rainbows) <- names


list(overall_winner = overall_winner,
     colors_abs = colors_abs,
     colors_rel = colors_rel,
     mistakes = mistakes,
     rainbows = rainbows) |> 
  openxlsx::write.xlsx("results_connections.xlsx")
