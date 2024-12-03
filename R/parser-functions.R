regex_who <- "\\d{1,2}\\/\\d{1,2}\\/\\d{1,2}, \\d{1,2}:\\d{1,2} - (.+):"

parse_wordle <- function(chat, omit_na = FALSE) {
  wordle <- data.frame(Who = NA, Puzzle = NA, Tries = NA)
  i <- 1
  n <- length(chat)
  pb <- txtProgressBar(max = n, style = 3)
  while (i < n) {
    who_match <- regexec(regex_who, chat[i])
    if (who_match[[1]][1] != -1) {
      who <- regmatches(chat[i], who_match)[[1]][2]
    }
    is_wordle <- regexpr("Wordle \\d+ ./6", chat[i])
    if (is_wordle != -1) {
      details <- strsplit(substr(chat[i], is_wordle, nchar(chat[i])), split = "\\s+")[[1]]
      puzzle <- details[2]
      tries <- substr(details[3], 1, 1)
      if (nrow(subset(wordle, Who == who & Puzzle == puzzle & Tries == tries))<=0) {
        wordle <- rbind(wordle, c(who, puzzle, tries))
      }
    }
    i <- i + 1
    setTxtProgressBar(pb, i)
  }
  wordle <- wordle[-1,]
  wordle$Puzzle <- as.integer(wordle$Puzzle)
  wordle$Tries <- as.integer(wordle$Tries)
  wordle <- wordle |> tidyr::pivot_wider(names_from = Who, values_from = Tries) |> as.data.frame()
  wordle <- wordle[order(wordle$Puzzle),]
  if (omit_na) {
    wordle <- na.omit(wordle)
  } else {
    wordle[is.na(wordle)] <- "X"
  }
  return(wordle)
}

parse_connections <- function(chat, omit_na = FALSE) {
  connections_squares <- c("🟨", "🟩", "🟦", "🟪") |> utf8::utf8_encode()
  regex_is_connections <- paste0("[", paste(connections_squares, collapse = ""), "]")
  connections <- data.frame(Who = NA, Puzzle = NA, Tries = NA, Yellow = NA, Green = NA, Blue = NA, Purple = NA, Rainbow = NA)
  
  i <- 1
  n <- length(chat)
  pb <- txtProgressBar(max = n, style = 3)
  while (i < n) {
    setTxtProgressBar(pb, i)

    who_match <- regexec(regex_who, chat[i])
    if (who_match[[1]][1] != -1) {
      who <- regmatches(chat[i], who_match)[[1]][2]
    }
    is_connections <- regexpr("Puzzle #\\d+", chat[i])
    if (is_connections != -1) {
      puzzle <- strsplit(chat[i], split = "#")[[1]][2]
      colors <- c(Yellow = 0, Green = 0, Blue = 0, Purple = 0)
      rainbow <- 0
      j <- 1
      while ((is_connections != -1) & ((i+j) < n)) {
        if (gsub(regex_is_connections, "", utf8::utf8_encode(chat[i+j])) == "") {    # check para ver si es una línea de connections
          color_count <- connections_squares |> sapply(\(x) {
            stringr::str_count(utf8::utf8_encode(chat[i+j]), utf8::utf8_encode(x))
          })
          if (any(color_count == 4)) {
            colors <- colors + 0.25*color_count
          }
          if (all(color_count == 1)) {
            rainbow <- rainbow + 1
          }
          j <- j + 1
        } else {
          is_connections <- -1
        }
      }
      tries <- j-1
      if (nrow(subset(connections, Who == who & Puzzle == puzzle & Tries == tries & Rainbow == rainbow))<=0) {
        connections <- rbind(connections, c(who, puzzle, tries, colors, rainbow))
      }
      i <- i + j - 1
    }
    i <- i + 1
  }
  connections <- connections[-1,] |> as.data.frame()
  connections[, 2:8] <- connections[, 2:8] |> lapply(as.integer)
  connections_wide <- connections |> tidyr::pivot_wider(names_from = Who, values_from = 3:8) |> as.data.frame()
  names <- unique(connections$Who)
  if (omit_na) {
    connections_wide <- na.omit(connections_wide)
  } else {
    tries <- connections_wide[, paste0("Tries_", names)]
    tries[is.na(tries)] <- 8
    connections_wide[, paste0("Tries_", names)] <- tries
    connections_wide[is.na(connections_wide)] <- 0
  }
  connections_dfs <- lapply(names, \(x) {
    data.frame(Puzzle = connections_wide$Puzzle,
               Tries = connections_wide[, paste0("Tries_", x)],
               Yellow = connections_wide[, paste0("Yellow_", x)],
               Green = connections_wide[, paste0("Green_", x)],
               Blue = connections_wide[, paste0("Blue_", x)],
               Purple = connections_wide[, paste0("Purple_", x)],
               Rainbow = connections_wide[, paste0("Rainbow_", x)])
  }) |> setNames(names)
  return(connections_dfs)
}