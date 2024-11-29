#' Calendar Heatmap
#'
#' Creates a colour coded calendar visualising time series data
#'
#' @param dates A vector containing the dates in `Date` format.
#' @param values A vector containing the corresponding values as numeric.
#' @param title Main plot title (optional).
#' @param subtitle Main plot subtitle (optional).
#' @param legendtitle Legend title (optional).
#'
#' @return ggplot object
calendarHeatmap <- function(dates, values, title = "", subtitle = "", legendtitle = "") {
  # Parameter checks
  if (missing(dates)) {
    stop("Need to specify a dates vector.")
  }
  if (missing(values)) {
    stop("Need to specify a values vector.")
  }
  if (!is.Date(dates)) {
    stop("dates vector need to be in Date format.")
  }
  if (length(dates) != length(values)) {
    stop("dates and values need to have the same length.")
  }


  # load required packages
  require(ggplot2)

  my_theme <- function() {
    # Colors
    color.background <- "white"
    color.text <- "#22211d"

    # Begin construction of chart
    theme_bw(base_size = 15) +

      # Format background colors
      theme(panel.background = element_rect(fill = color.background, color = color.background)) +
      theme(plot.background = element_rect(fill = color.background, color = color.background)) +
      theme(panel.border = element_rect(color = color.background)) +
      theme(strip.background = element_rect(fill = color.background, color = color.background)) +

      # Format the grid
      theme(panel.grid.major = element_blank()) +
      theme(panel.grid.minor = element_blank()) +
      theme(axis.ticks = element_blank()) +

      # Format the legend
      theme(legend.position = "bottom") +
      theme(legend.text = element_text(size = 8, color = color.text)) +
      theme(legend.title = element_text(size = 10, face = "bold", color = color.text)) +

      # Format title and axis labels
      theme(plot.title = element_text(color = color.text, size = 20, face = "bold")) +
      theme(axis.text.x = element_text(size = 12, color = "black")) +
      theme(axis.text.y = element_text(size = 12, color = "black")) +
      theme(axis.title.x = element_text(size = 14, color = "black", face = "bold")) +
      theme(axis.title.y = element_text(size = 14, color = "black", vjust = 1.25)) +
      theme(axis.text.x = element_text(size = 10, hjust = 0, color = color.text)) +
      theme(axis.text.y = element_text(size = 10, color = color.text)) +
      theme(strip.text = element_text(face = "bold")) +

      # Plot margins
      theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm"))
  }

  # create empty calendar
  min.date <- as.Date(paste(format(min(dates), "%Y"), "-1-1", sep = ""))
  max.date <- as.Date(paste(format(max(dates), "%Y"), "-12-31", sep = ""))
  df <- data.frame(date = seq(min.date, max.date, by = "days"), value = NA)

  # fill in values
  df$value[match(dates, df$date)] <- values

  df$year <- as.factor(format(df$date, "%Y"))
  df$month <- as.numeric(format(df$date, "%m"))
  df$doy <- as.numeric(format(df$date, "%j"))
  # df$dow  <- as.numeric(format(df$date, "%u"))
  # df$woy  <- as.numeric(format(df$date, "%W"))
  df$dow <- as.numeric(format(df$date, "%w"))
  df$woy <- as.numeric(format(df$date, "%U")) + 1

  df$dowmapped <- ordered(df$dow, levels = 6:0)
  levels(df$dowmapped) <- rev(c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

  g <- ggplot(df, aes(woy, dowmapped, fill = value)) +
    geom_tile(colour = "darkgrey") +
    facet_wrap(~year, ncol = 1) + # Facet for years
    coord_equal(xlim = c(2.5, 54)) + # square tiles
    scale_x_continuous(breaks = 53 / 12 * (1:12) - 1.5, labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
    my_theme() +
    scale_fill_gradientn(
      colours = c("#D61818", "#FFAE63", "#FFFFBD", "#B5E384"), na.value = "white",
      name = legendtitle,
      guide = guide_colorbar(
        direction = "horizontal",
        barheight = unit(2, units = "mm"),
        barwidth = unit(75, units = "mm"),
        title.position = "top",
        title.hjust = 0.5
      )
    ) +
    labs(
      x = NULL,
      y = NULL,
      title = title,
      subtitle = subtitle
    )

  my.lines <- data.frame(
    x = numeric(),
    y = numeric(),
    xend = numeric(),
    yend = numeric(),
    year = character()
  )

  for (years in levels(df$year)) {
    df.subset <- df[df$year == years, ]

    y.start <- df.subset$dow[1]
    x.start <- df.subset$woy[1]

    x.top.left <- ifelse(y.start == 0, x.start - 0.5, x.start + 0.5)
    y.top.left <- 7.5
    x.top.right <- df.subset$woy[nrow(df.subset)] + 0.5
    y.top.right <- 7.5

    x.mid.left01 <- x.start - 0.5
    y.mid.left01 <- 7.5 - y.start
    x.mid.left02 <- x.start + 0.5
    y.mid.left02 <- 7.5 - y.start

    x.bottom.left <- x.start - 0.5
    y.bottom.left <- 0.5
    x.bottom.right <- ifelse(y.start == 6, df.subset$woy[nrow(df.subset)] + 0.5, df.subset$woy[nrow(df.subset)] - 0.5)
    y.bottom.right <- 0.5

    my.lines <- rbind(
      my.lines,
      data.frame(
        x = c(x.top.left, x.bottom.left, x.mid.left01, x.top.left, x.bottom.left),
        y = c(y.top.left, y.bottom.left, y.mid.left01, y.top.left, y.bottom.left),
        xend = c(x.top.right, x.bottom.right, x.mid.left02, x.mid.left02, x.mid.left01),
        yend = c(y.top.right, y.bottom.right, y.mid.left02, y.mid.left02, y.mid.left01),
        year = years
      )
    )

    # lines to separate months
    for (j in 1:12) {
      df.subset.month <- max(df.subset$doy[df.subset$month == j])
      x.month <- df.subset$woy[df.subset.month]
      y.month <- df.subset$dow[df.subset.month]

      x.top.mid <- x.month + 0.5
      y.top.mid <- 7.5

      x.mid.mid01 <- x.month - 0.5
      y.mid.mid01 <- 7.5 - y.month - 1
      x.mid.mid02 <- x.month + 0.5
      y.mid.mid02 <- 7.5 - y.month - 1

      x.bottom.mid <- ifelse(y.month == 6, x.month + 0.5, x.month - 0.5)
      y.bottom.mid <- 0.5

      my.lines <- rbind(
        my.lines,
        data.frame(
          x = c(x.top.mid, x.mid.mid01, x.mid.mid01),
          y = c(y.top.mid, y.mid.mid01, y.mid.mid01),
          xend = c(x.mid.mid02, x.mid.mid02, x.bottom.mid),
          yend = c(y.mid.mid02, y.mid.mid02, y.bottom.mid),
          year = years
        )
      )
    }
  }

  # add lines
  g <- g + geom_segment(data = my.lines, aes(x, y, xend = xend, yend = yend), lineend = "square", color = "black", inherit.aes = FALSE)

  return(g)
}

#################
# Stock proce example

stock <- tibble::tribble(
         ~date,       ~adj_close,
  "2017-06-01", 67.0226669311523,
  "2017-06-02", 68.6097946166992,
  "2017-06-05", 69.1069717407227,
  "2017-06-06", 69.3364334106445,
  "2017-06-07", 69.2121429443359,
  "2017-06-08", 68.7914581298828,
  "2017-06-09", 67.2330169677734,
  "2017-06-12", 66.7167053222656,
  "2017-06-13", 67.5485229492188,
  "2017-06-14", 67.1852111816406,
  "2017-06-15", 66.8314590454102,
  "2017-06-16", 66.9270706176758,
  "2017-06-19", 67.7588653564453,
  "2017-06-20", 66.8410110473633,
  "2017-06-21", 67.1852111816406,
  "2017-06-22", 67.1756439208984,
  "2017-06-23", 68.0839385986328,
  "2017-06-26", 67.4337844848633,
  "2017-06-27", 66.1717376708984,
  "2017-06-28", 66.7358474731445,
  "2017-06-29", 65.4833526611328,
  "2017-06-30", 65.9040298461914,
  "2017-07-03", 65.1773910522461,
  "2017-07-05", 66.0474395751953,
  "2017-07-06", 65.5598373413086,
  "2017-07-07", 66.4107666015625,
  "2017-07-10", 66.9079437255859,
  "2017-07-11", 66.9174880981445,
  "2017-07-12", 68.0265884399414,
  "2017-07-13", 68.6193542480469,
  "2017-07-14", 69.5850296020508,
  "2017-07-17",  70.129997253418,
  "2017-07-18", 70.0821914672852,
  "2017-07-19", 70.6176071166992,
  "2017-07-20", 70.9618072509766,
  "2017-07-21", 70.5506820678711,
  "2017-07-24",  70.369026184082,
  "2017-07-25", 70.9331359863281,
  "2017-07-26", 70.7992630004883,
  "2017-07-27", 69.9483413696289,
  "2017-07-28", 69.8335952758789,
  "2017-07-31", 69.5085296630859,
  "2017-08-01", 69.3938140869141,
  "2017-08-02", 69.0878524780273,
  "2017-08-03", 68.9826812744141,
  "2017-08-04", 69.4894180297852,
  "2017-08-07", 69.2217102050781,
  "2017-08-08", 69.5945816040039,
  "2017-08-09", 69.2886352539062,
  "2017-08-10", 68.2751541137695,
  "2017-08-11", 69.3173141479492,
  "2017-08-14", 70.3594589233398,
  "2017-08-15", 70.3786926269531,
  "2017-08-16", 70.7919998168945,
  "2017-08-17", 69.5905075073242,
  "2017-08-18", 69.6770172119141,
  "2017-08-21",  69.350212097168,
  "2017-08-22", 70.3210296630859,
  "2017-08-23", 69.8981018066406,
  "2017-08-24",  69.869255065918,
  "2017-08-25", 69.9941940307617,
  "2017-08-28", 70.0038223266602,
  "2017-08-29", 70.2152786254883,
  "2017-08-30", 71.1380233764648,
  "2017-08-31", 71.8685455322266,
  "2017-09-01", 71.0707473754883,
  "2017-09-05", 70.7535552978516,
  "2017-09-06", 70.5517044067383,
  "2017-09-07", 71.4552154541016,
  "2017-09-08", 71.1091995239258,
  "2017-09-11", 71.8589248657227,
  "2017-09-12", 71.7820358276367,
  "2017-09-13", 72.2914733886719,
  "2017-09-14", 71.8685455322266,
  "2017-09-15", 72.3875732421875,
  "2017-09-18",  72.243408203125,
  "2017-09-19", 72.5125503540039,
  "2017-09-20", 72.0319442749023,
  "2017-09-21", 71.3302612304688,
  "2017-09-22", 71.5225067138672,
  "2017-09-25", 70.4171295166016,
  "2017-09-26", 70.4171295166016,
  "2017-09-27", 70.9842376708984,
  "2017-09-28", 71.0034713745117,
  "2017-09-29", 71.5994033813477,
  "2017-10-02", 71.7147369384766,
  "2017-10-03", 71.3783340454102,
  "2017-10-04", 71.7916412353516,
  "2017-10-05", 73.0219650268555,
  "2017-10-06", 73.0508117675781,
  "2017-10-09", 73.3295593261719,
  "2017-10-10", 73.3295593261719,
  "2017-10-11", 73.4545059204102,
  "2017-10-12", 74.1273345947266,
  "2017-10-13", 74.4829788208008,
  "2017-10-16", 74.6367797851562,
  "2017-10-17", 74.5791091918945,
  "2017-10-18", 74.5983276367188,
  "2017-10-19", 74.8866958618164,
  "2017-10-20", 75.7517700195312,
  "2017-10-23", 75.7709884643555,
  "2017-10-24", 75.7998199462891,
  "2017-10-25", 75.5787582397461,
  "2017-10-26", 75.7036972045898,
  "2017-10-27",  80.557731628418,
  "2017-10-30",  80.634635925293,
  "2017-10-31", 79.9521865844727,
  "2017-11-01", 79.9521865844727,
  "2017-11-02", 80.7884292602539,
  "2017-11-03", 80.8749313354492,
  "2017-11-06",  81.192138671875,
  "2017-11-07", 80.9998779296875,
  "2017-11-08", 81.2786254882812,
  "2017-11-09", 80.8268585205078,
  "2017-11-10", 80.6154174804688,
  "2017-11-13", 80.6730804443359,
  "2017-11-14", 80.7884292602539,
  "2017-11-15", 80.1605224609375,
  "2017-11-16", 80.3730316162109,
  "2017-11-17",  79.600227355957,
  "2017-11-20", 79.7257995605469,
  "2017-11-21", 80.8753662109375,
  "2017-11-22", 80.2861099243164,
  "2017-11-24", 80.4309921264648,
  "2017-11-27", 81.0202789306641,
  "2017-11-28", 81.9959564208984,
  "2017-11-29", 80.5082778930664,
  "2017-11-30", 81.3100738525391,
  "2017-12-01", 81.3970260620117,
  "2017-12-04",  78.325080871582,
  "2017-12-05", 78.8177337646484,
  "2017-12-06", 79.9673004150391,
  "2017-12-07", 79.6871490478516,
  "2017-12-08",  81.300422668457,
  "2017-12-11", 82.3340606689453,
  "2017-12-12", 82.6721649169922,
  "2017-12-13", 82.4499816894531,
  "2017-12-14", 81.8124008178711,
  "2017-12-15", 83.8990173339844,
  "2017-12-18", 83.4449844360352,
  "2017-12-19", 82.9136810302734,
  "2017-12-20", 82.6142120361328,
  "2017-12-21", 82.5948944091797,
  "2017-12-22", 82.6045379638672,
  "2017-12-26", 82.4982833862305,
  "2017-12-27", 82.7977447509766,
  "2017-12-28", 82.8074111938477,
  "2017-12-29",  82.633544921875
  ) |> 
  mutate(date = ymd(date))



dates <- stock$date
values <- stock$adj_close

calendarHeatmap(dates, values, title = "Microsoft Stock Price", subtitle = "Yahoo Finance API", legendtitle = "Price")

###############################
# CTFM trajectories
library(fs)

src <- 'G:/HQ/dgof-pru/Data/Application/Complexity_version_C/Data/Traffic'

lll <- dir_info(
  path = src,
  # glob = "*.so6"
  regexp = "[TRAFFIC_CTFM_]\\d{8}[.]so6$"
  ) |>
  mutate(filename = path_file(path), .before = size) |> 
  separate_wider_delim(
    filename, 
    delim = "_",
    names = c("base", "model", "date"),
    cols_remove = FALSE) |> 
  mutate(date = date |> str_sub(1L, 8L) |> ymd()) |> 
  select(date, size) |> 
  filter(("2019-01-01" <= date & date < "2020-01-01") | ("2023-01-01" <= date & date < "2024-01-01"))
  
dates <- lll$date
values <- lll$size

calendarHeatmap(dates, values, title = "CFTM daily file size", subtitle = "NM", legendtitle = "Size")


##############################
# FR24 files
src <- "G:/HQ/dgof-pru/Data/DataSource/FR24/global_utilisation"

lll <- dir_info(
  path = src,
  # glob = "*.so6"
  regexp = "\\d{8}-\\d{8}[.]csv.zip$"
) |>
  mutate(filename = path_file(path), .before = size) |> 
  separate_wider_delim(
    filename, 
    delim = "-",
    names = c("date", "rest"),
    cols_remove = FALSE) |> 
  mutate(date = date |> str_sub(1L, 8L) |> ymd()) |> 
  select(date, size) |> 
  filter("2021-05-01" <= date & date < today())

dates <- lll$date
values <- lll$size

calendarHeatmap(dates, values, title = "FR24 daily file size", subtitle = "FR24", legendtitle = "Size")
