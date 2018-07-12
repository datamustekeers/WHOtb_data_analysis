## app.R ##
library(shinydashboard)
library(RCurl)
library(ggplot2)

#Read data from GitHub
tb_data <-read.csv(text=getURL("https://raw.githubusercontent.com/datamustekeers/WHOtb_data_analysis/master/data/TB_burden_countries_2018-07-04.csv"), header=T)

ui <- dashboardPage(
  dashboardHeader(title = "Draft WHO Dashboard"),
  dashboardSidebar(
      sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Widgets", tabName = "widgets", icon = icon("th"))
  )),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                box(title = "Population Per year", status = "primary",solidHeader = TRUE, plotOutput("plot1", height = 250)),
                
                box(
                  title = "Controls",
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                )
              )
      ),
      
      # Second tab content
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )
  )
)

server <- function(input, output) {
  #select data before intiating selector.
  country_data = subset(tb_data,country == "Kenya")
  country_data  = country_data[,c("year","e_pop_num","e_inc_num")]

  output$plot1 <- renderPlot({
    ggplot(data = country_data, aes(x=year, y=e_pop_num)) +
      geom_line()
  })
}

shinyApp(ui, server)