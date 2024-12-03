# parameters
chat_filepath <- file("Chat de WhatsApp con Alicia YoduroDaluminio.txt")


library(dplyr)
source("parser-functions.R")
wordle <- chat_filepath |> readLines() |> parse_wordle()
names <- colnames(wordle)[-1]

wordle$Winner <- ifelse(wordle[, names[1]] < wordle[, names[2]],  names[1], 
                        ifelse(wordle[, names[1]] > wordle[, names[2]], names[2], "Tie"))
overall_winner <- table(Winner = wordle$Winner) |> as.data.frame()
distribution_abs <- data.frame(table(wordle[, names[1]]), table(wordle[, names[2]]))[, c(1,2,4)]
colnames(distribution_abs) <- c("Tries", names)
distribution_rel <- distribution_abs
distribution_rel[, 2:3] <- (distribution_abs[, 2:3] / nrow(wordle)) |> round(3)
table(wordle[, names])

list(overall_winner = overall_winner,
     distribution_abs = distribution_abs,
     distribution_rel = distribution_rel) |> 
  openxlsx::write.xlsx("results_wordle.xlsx")
