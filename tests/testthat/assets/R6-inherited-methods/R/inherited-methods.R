#' @title super class for all animals
#' @export
Animal <- R6::R6Class(
  "Animal",
  public = list(
    #' @description create an animal
    #' @param name The name of the animal
    initialize = function(name) {
      private$name_ <- name
    }
  ),
  private = list(
    name_ = ""
  )
)

#' @title super class for all dogs
#' @export
Dog <- R6::R6Class(
  "Dog",
  inherit = Animal,
  public = list(
    #' @description the noise made by dogs
    bark = function() {
      print(sprintf("I'm %s", private$name_))
    }
  )
)
