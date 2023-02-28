## libraries
library(dplyr)
library(stringr)
library(readxl)
library(plotly)


ace_graph_data <- read_xlsx(
  path  = here::here ("content","economics","ace_landing_page_data.xlsx"),
  sheet = "ACE_landing_page_data",
  range = cell_limits(c(1, 1), c(NA, NA))
)%>%
  as_tibble%>%
  mutate_all(as.numeric)%>%
  rename(year_data=1)

plot_ACE <- ace_graph_data %>%
  plot_ly(
    # width = 500, 
    height = 330,
    x = ~ year_data,
    y = ~ costs_per_cph,
    yaxis = "y1",
    marker = list(color =('#4F81BD')),
    text = ~ paste("  <b>",round(costs_per_cph,0),"</b>"),
    textangle = -90,
    textposition = "inside",
    insidetextanchor =  "start",
    textfont = list(color = '#FFFFFF', size = 14),
    type = "bar",
    hoverinfo = "none",
    showlegend = F
  )%>%
  add_trace(
    inherit = FALSE,
    x = ~ year_data,
    y = ~ costs_per_cph+20,
    yaxis = "y1",
    # colors = c('#4F81BD'),
    mode = 'text',
    text = paste0("<b>",if_else(ace_graph_data$costs_per_cph_change_perc >0, "+", ""),format(round(ace_graph_data$costs_per_cph_change_perc*100,1), 1), "%","</b>"),
    textfont = list(color = 'black', size = 14),
    type = 'scatter',  mode = 'lines',
    hoverinfo = "none",
    showlegend = F
    
  )%>%
  add_trace(
    x = ~ year_data,
    y = ~ round(index_costs,1), 
    inherit = FALSE,
    yaxis = "y2",
    type = 'scatter',  mode = 'lines', name = 'ATM/CNS provision costs',
    line = list(color = "#1F497D"),
    hovertemplate = paste('<b>ATM/CNS costs index</b>: <br>%{y}',
                          "<extra></extra>",
                          sep = "")
  )%>%
  add_trace(
    x = ~ year_data,
    y = ~ round(index_cph,1), 
    inherit = FALSE,
    yaxis = "y2",
    type = 'scatter',  mode = 'lines', name = 'Composite flight-hours',
    line = list(color = "#E46C0A"),
    hoverlabel=list(bgcolor="#F8A662",font=list(color='black')),
    hovertemplate = paste('<b>Composite flight-hours index</b>: <br>%{y}',
                          "<extra></extra>",
                          sep = "")
  )%>%
  layout(
    autosize = T,
    xaxis = list(
      title = "",
      fixedrange = TRUE,
      # automargin = T,
      # tickvals = 2014:2019,
      autotick = F,
      showgrid = F
    ),
    
    yaxis = list(
      title = paste("\U20AC","per composite flight-hour"),
      titlefont   = list(size = 13),
      fixedrange = TRUE,
      # tickformat=",.0%", ticks = 'outside',
      zeroline = T, showline = F, showgrid = T
    ),
    yaxis2 = list (
      overlaying = "y",
      side = "right",
      title = paste ("Index of costs and traffic", "<br>","(", min(ace_graph_data$year_data), " = 100)",sep = ""),
      titlefont = list(size = 13),
      range = list(40, 10+round(max(ace_graph_data$index_costs, ace_graph_data$index_cph)/10)*10),
      automargin = T,
      showgrid = F
    ),
    bargap = 0.4,
    legend = list(orientation = 'h', xanchor = "left", x = -0.05, y = -0.05),
    # hovermode = "x unified",
    uniformtext=list(minsize=10, mode='show')
  ) %>%
  config(displaylogo = FALSE, modeBarButtons = list(list("toImage"))
  )

plot_ACE


