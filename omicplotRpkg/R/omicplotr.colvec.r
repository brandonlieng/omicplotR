#' Generate colour vector from metadata
#'
#' Generates vector of colours from metadata file to be used to colour sample
#' names in \code{omicplotr.colouredPCA} using \code{xlabs.col}.
#'
#' @param data prcomp objected generated by \code{omicplotr.clr}.
#' @param meta metadata associated with data.
#' @param column column by which to generate a unique colour for each unique
#'  value.
#' @param type colouring type for data. 1 = numeric (continuous), 2 = quartile,
#'  3 = categorical (numeric or nonnumeric), default 3.
#'
#' @export

omicplotr.colvec <- function(data, meta, column, type = 3) {

    df <- as.data.frame(unlist(dimnames(data$x)[1]))

    colnames(df) <- "samples"
    #add empty column (which is gonna be the ample list for colouring)
    df$correct <- NA
    #introduces NA where metadata is not present for sample
    #the important thing is that this keeps the order of the data
    for (i in 1:length(df$samples)) {
      if (df$samples[i] %in% rownames(meta)) {
        df$correct[i] <- as.character(df$samples[i])
      } else {
        df$correct[i] <- NA
      }
    }

    #colour column
    df$colour <- NA

    #if correct != present, colour black
    #this means metadata was missing for data point
    for (i in 1:length(df$correct)) {
      if (is.na(df$correct[i])) {
        df$colour[i] <- "black"
      }
    }

    #get unique features of columns in metadata
    u <- unique(meta[[column]])
    #get rid of NAs
    u <- u[!is.na(u)]

    #default colour palette
    colours <- c("indianred1", "steelblue3",  "skyblue1", "mediumorchid",
                 "royalblue4", "olivedrab3", "pink", "#FFED6F", "mediumorchid3",
                 "ivory2"
    )

    #colour the colour column for up to ten colours
    for (i in 1:length(df$correct)) {
      if (is.na(meta[column][df$correct[i], ])) {
        df$colour[i] <- "black"
      } else if (meta[column][df$correct[i], ] == as.character(u[1])) {
        df$colour[i] <- colours[1]
      } else if (meta[column][df$correct[i], ] == as.character(u[2])) {
        df$colour[i] <- colours[2]
      } else if (meta[column][df$correct[i], ] == as.character(u[3])) {
        df$colour[i] <- colours[3]
      } else if (meta[column][df$correct[i], ] == as.character(u[4])) {
        df$colour[i] <- colours[4]
      } else if (meta[column][df$correct[i], ] == as.character(u[5])) {
        df$colour[i] <- colours[5]
      } else if (meta[column][df$correct[i], ] == as.character(u[6])) {
        df$colour[i] <- colours[6]
      } else if (meta[column][df$correct[i], ] == as.character(u[7])) {
        df$colour[i] <- colours[7]
      } else if (meta[column][df$correct[i], ] == as.character(u[8])) {
        df$colour[i] <- colours[8]
      } else if (meta[column][df$correct[i], ] == as.character(u[9])) {
        df$colour[i] <- colours[9]
      } else if (meta[column][df$correct[i], ] == as.character(u[10])) {
        df$colour[i] <- colours[10]
      }
  }

  #different colouringtype
  if (type == 1) {

      #TODO get rid of this if using command line
    validate(need(is.integer(meta[[column]]), "Nonnumeric data detected. Please
    click 'Nonnumeric metadata'"))

    #get rid of old column made
    df$colour <- NULL

    #make age column
    df$age <- NA

    #get the age of each sample
    for (i in 1:length(df$correct)) {
      if (is.na(meta[column][df$correct[i], ])) {
        df$age[i] <- NA
      } else {
        df$age[i] <- meta[column][df$correct[i], ]
      }
    }

    #order data frame in order of age (there is one dropped for some reason now)
    df.sort <- df[order(df$age), ]

    df.sort$col <- NA

    #colour each unique number seperately
    df.u <- unique(df.sort$age)

    len <- length(df.u)

    #generate colour function
    c <- colorRampPalette(c("red", "blue"))(len)

    #colour each unique age
    for (i in 1:length(df.sort$age)) {
      df.sort$col[df.sort$age == df.u[i]] <- c[i]
    }

    #colour the NAs black. these are missing data points.
    for (i in 1:length(df.sort$age)) {
      if (is.na(df.sort$col[i])) {
        df.sort$col[i] <- "#000000"
      }
    }

    #reorder the df by sample now so it matches the data
    df.sort <- df.sort[order(df.sort$samples), ]

    #voila, c'est le colour!
    sorted <- c()
    sorted$col <- df.sort$col

  } else if (type == 2) {

    validate(need(is.integer(meta[[column]]), "Nonnumeric data detected. Please
    click 'Nonnumeric metadata'"))

    #quartile
    df$colour <- NULL

    #make age column
    df$age <- NA

    #get the age of each sample
    for (i in 1:length(df$correct)) {
      if (is.na(meta[column][df$correct[i], ])) {
        df$age[i] <- NA
      } else {
        df$age[i] <- meta[column][df$correct[i], ]
      }
    }

    df$col <- NA

    c <- colorRampPalette(c("green", "blue"))(4)

    #make quartile rank column
    sorted <-
      within(df, col <-
               as.integer(cut(
                 df$age, quantile(df$age, na.rm = TRUE), include.lowest = TRUE
               )))

    #replace quartile rank with colours
    sorted$col[sorted$col == 1] <- c[1]
    sorted$col[sorted$col == 2] <- c[2]
    sorted$col[sorted$col == 3] <- c[3]
    sorted$col[sorted$col == 4] <- c[4]

    #replace any NAs with black
    for (i in 1:length(sorted$col)) {
      if (is.na(sorted$col[i])) {
        sorted$col[i] <- "#000000"
      }
    }

  } else if (type == 3) {
    sorted <- c()
    sorted$col <- df$colour
  } else {
    return("")
  }
return(sorted$col)
}
