
#' @importFrom shiny NS dateInput checkboxInput textInput
#' @importFrom htmltools tagList
#' @importFrom R.utils capitalize
edit_user_ui <- function(id, credentials, username = NULL) {

  ns <- NS(id)

  lan <- use_language()

  if (!is.null(username) && username %in% credentials$user) {
    data_user <- credentials[credentials$user == username, ]
  } else {
    data_user <- list()
  }

  input_list <- lapply(
    X = names(credentials),
    FUN = function(x) {
      if (x %in% "start") {
        value <- data_user[[x]]
        if (is.null(value)) {
          # value <- Sys.Date()
          value <- NA
        }
        dateInput(inputId = ns(x), label = R.utils::capitalize(x), value = value, width = "100%")
      } else if (x %in% "expire") {
        value <- data_user[[x]]
        if (is.null(value)) {
          # value <- Sys.Date() + 60
          value <- NA
        }
        dateInput(inputId = ns(x), label = R.utils::capitalize(x), value = value, width = "100%")
      } else if (identical(x, "password")) {
        NULL
      } else if (identical(x, "admin")) {
        checkboxInput(inputId = ns(x), label = R.utils::capitalize(x), value = isTRUE(as.logical(data_user[[x]])))
      } else {
        textInput(inputId = ns(x), label = R.utils::capitalize(x), value = data_user[[x]], width = "100%")
      }
    }
  )

  if(is.null(username)){
    input_list[[length(input_list) + 1]] <- textInput(inputId = ns("password"), label = "Password", value = generate_pwd(), width = "100%")
    input_list[[length(input_list) + 1]] <- checkboxInput(inputId = ns("must_change"), label = lan$get("Ask to change password"), value = TRUE)
  }
  tagList(
    input_list
  )
}

#' @importFrom shiny reactiveValues observe reactiveValuesToList
edit_user <- function(input, output, session) {

  rv <- reactiveValues(user = NULL)

  observe({
    rv$user <- lapply(
      X = reactiveValuesToList(input),
      FUN = function(x){
        x <- as.character(x)
        ifelse(length(x) == 0, NA, x)
      }
    )
  })

  return(rv)
}


#' @importFrom utils modifyList
update_user <- function(df, value, username) {
  users_order <- factor(df$user, levels=unique(df$user))
  df <- split(df, f = users_order)
  user <- as.list(df[[username]])
  value <- lapply(value, function(x) ifelse(length(x) == 0, NA, x))
  new <-  modifyList(x = user, val = value)
  df[[username]] <- as.data.frame(new, stringsAsFactors = FALSE)
  do.call(rbind, c(df, list(make.row.names = FALSE)))
}
