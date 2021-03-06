## app.R ##
library(shinydashboard)
library(RCurl)
library(ggplot2)

#Read data from GitHub
tb_data <-
  read.csv(
    text = getURL(
      "https://raw.githubusercontent.com/datamustekeers/WHOtb_data_analysis/master/data/TB_burden_countries_2018-07-04.csv"
    ),
    header = T
  )
all_countries = unique(tb_data$country)

ui <- dashboardPage(
  dashboardHeader(title = "Draft WHO Dashboard"),
  dashboardSidebar(sidebarMenu(
    menuItem(
      "Dashboard",
      tabName = "dashboard",
      icon = icon("dashboard")
    ),
    menuItem("Widgets", tabName = "widgets", icon = icon("th")),
    uiOutput("Choose_country")
  )),
  dashboardBody(tabItems(
    # First tab content
    tabItem(
      tabName = "dashboard",
      fluidRow(
        # A static infoBox
        infoBox("Number of Countries", 221, icon = icon("globe", lib = "glyphicon")),
        # Dynamic infoBoxes
        infoBoxOutput("PopulationBox"),
        infoBoxOutput("TBBox")
      ),
      
      fluidRow(
        box(
          title = "Population Per Year",
          status = "primary",
          solidHeader = TRUE,
          plotOutput("plot1", height = 300)
        ),
        box(
          title = "TB Occurance Per Year",
          status = "primary",
          solidHeader = TRUE,
          plotOutput("plot2", height = 300)
        )
        
      )
    ),
    
    # Second tab content
    tabItem(tabName = "widgets",
            h2("Widgets tab content"))
  ))
)

server <- function(input, output) {
  output$Choose_country <- renderUI({
    selectInput("select",
                "Select a country",
                choices = all_countries,
                selected = all_countries[1])
  })
  
  
  get_data <- reactive({
    #Get User selection
    country_selected = input$select
    #select data before intiating selector.
    country_data = subset(tb_data, country == country_selected)
    country_data  = country_data[, c("year", "e_pop_num", "e_inc_num")]
    return(country_data)
  })
  
  output$PopulationBox <- renderInfoBox({
    country_data = get_data()
    infoBox(
      "Population Growth",
      paste0(round((((country_data[17, 2] - country_data[1, 2]) / (country_data[1, 2])
      ) * 100), 0), "%"),
      icon = icon("user", lib = "glyphicon"),
      color = "purple"
    )
  })
  output$TBBox <- renderInfoBox({
    country_data = get_data()
    infoBox(
      "Growth in TB Occurance",
      paste0(round((((country_data[17, 3] - country_data[1, 3]) / (country_data[1, 3])
      ) * 100), 0), "%"),
      icon = icon("dashboard", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  
  output$plot1 <- renderPlot({
    country_data = get_data()
    ggplot(data = country_data, aes(x = year, y = e_pop_num/100)) +
      geom_line(linetype="dashed", color="#900C3F")+
      geom_point(color="#900C3F")+
      labs(x = "Year", y = "Population in '000'")+
      theme(
        axis.text = element_text(face="bold", color="#340B02", size=14),
        axis.title = element_text(face="bold", color="#340B02", size=14)
      )
  })
  
  output$plot2 <- renderPlot({
    country_data = get_data()
    ggplot(data = country_data, aes(x = year, y = e_inc_num)) +
      geom_line(linetype="dashed", color="#900C3F")+
      geom_point(color="#900C3F")+
      labs(x = "Year", y = "All Incurrences of TB")+
      theme(
        axis.text = element_text(face="bold", color="#340B02", size=14),
        axis.title = element_text(face="bold", color="#340B02", size=14)
      )
  })
}

shinyApp(ui, server)