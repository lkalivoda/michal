
# INSTALL & LOAD PACKAGES

install.packages("bupaR", dependencies = TRUE)
install.packages("edeaR", dependencies = TRUE)
install.packages("processmapR", dependencies = TRUE)
install.packages("xesreadR", dependencies = TRUE)
install.packages("processmonitR", dependencies = TRUE)
install.packages("petrinetR", dependencies = TRUE)
install.packages("tidyverse")
install.packages("DiagrammeR")
devtools::install_github('rich-iannone/DiagrammeRsvg')
install.packages("rsvg")
install.packages("readr")
install.packages("dplyr")
install.packages("shiny")


require(bupaR)
require(edeaR)
require(processmapR)
require(xesreadR)
require(processmonitR)
require(petrinetR)
require(tidyverse)
require(DiagrammeR)
require(DiagrammeRsvg)
require(rsvg)
require(readr)
require(dplyr)
require(shiny)

install.packages("shiny")
require(shiny)

install.packages("DiagrammeRsvg")
install.packages("svg")
require(DiagrammeRsvg)
require(svg)

install.packages("dplyr")
require(dplyr)

# LOAD DATA
events_0 <- read_delim("events.csv", delim = "\t", locale = locale(encoding = "cp1250"))

dim(events_0)

# PREPROCESS DATA: formatting timestamp and orderig records

events_0$DATUM <- as.POSIXct(events_0$DATUM, format = "%Y-%m-%d")
events_0 <- events_0 %>% group_by(CRM_ITMGUI) %>% arrange(PORADI, .by_group = TRUE) %>% dplyr::ungroup()

colnames(events_0)

# CREATE EVENT LOG

events <- events_0 %>% 
  mutate(status = "complete",
           activity_instance = 1:nrow(.)) %>% 
  eventlog(
    case_id = "CRM_ITMGUI",
    activity_id = "AKTIVITA",
    activity_instance_id = "activity_instance",
    lifecycle_id = "status",
    timestamp = "DATUM",
    resource_id = "ORG_UNIT")

dim(events)

# str(events)

# chcs <- unique(events$'Způsob uzavření smlouvy')

# ui <- fluidPage(
#   titlePanel("test"),
#   sidebarLayout(
#     sidebarPanel(
#       selectInput(inputId = "Způsob uzavření smlouvy",
#                   label = "Způsob uzavření smlouvy:",
#                   choices = c(chcs),
#                   selected = c(chcs),
#                   multiple = TRUE)
#     ),
#     mainPanel(
#       grVizOutput(outputId = "prc_map")
#     )
#   )
# )

# # ...............................................

# server <- function(input, output) {


#   output$prc_map <- renderGrViz({
#     events.upd <- events_0[events_0$'Způsob uzavření smlouvy' %in% input$'Způsob uzavření smlouvy',]
# events <- events.upd %>% 
#   mutate(status = "complete",
#            activity_instance = 1:nrow(.)) %>% 
#   eventlog(
#     case_id = "CRM_ITMGUI",
#     activity_id = "AKTIVITA",
#     activity_instance_id = "activity_instance",
#     lifecycle_id = "status",
#     timestamp = "DATUM",
#     resource_id = "ORG_UNIT")

#     # PLOT PROCESS MAP
#     events %>% process_map(rankdir = "TB") 
#   })
# }

# # ...............................................

# runApp(shinyApp(ui = ui, server = server))

chcs <- unique(events$'Způsob uzavření smlouvy')

ui <- fluidPage(
  titlePanel("test"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(inputId = "ZPUSOB",
                  label = "Způsob uzavření smlouvy:",
                  choices = chcs,
                  selected = chcs)
    ),
    mainPanel(
      grVizOutput(outputId = "prc_map")
    )
  )
)

# ...............................................

server <- function(input, output) {


  output$prc_map <- renderGrViz({
    events.upd <- events_0[which(events_0$'Způsob uzavření smlouvy' %in% input$ZPUSOB),]
events.eventlog <- events.upd %>% 
  mutate(status = "complete",
           activity_instance = 1:nrow(.)) %>% 
  eventlog(
    case_id = "CRM_ITMGUI",
    activity_id = "AKTIVITA",
    activity_instance_id = "activity_instance",
    lifecycle_id = "status",
    timestamp = "DATUM",
    resource_id = "ORG_UNIT")

    # PLOT PROCESS MAP
    events.eventlog %>% process_map(rankdir = "TB")
  })
}

# ...............................................

runApp(shinyApp(ui = ui, server = server))


# PLOT PROCESS MAP

events %>% process_map()

# PLOT PROCESS MAP

events %>% process_map(rankdir = "TB")

# events %>% process_map(render = F) %>% DiagrammeR::export_graph(paste("process_map_", Sys.Date(), ".png", sep = ""))
