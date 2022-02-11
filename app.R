library('shiny')
library('shinythemes')
library('shinycssloaders')

library('gtrendsR')
library('ggplot2')

words <- scan("./data/words.txt", character(), quote = "")
first_word_date <- as.Date("2021-06-19") + 1

dates_to_now <- seq(first_word_date, Sys.Date(), by=1)

past_x_days_df <- data.frame(
    date = dates_to_now,
    word = words[0:length(dates_to_now)]
)

past_x_days_df$format = paste(past_x_days_df$date - 1, past_x_days_df$word, sep=": ")

# ui
ui <- fluidPage(
    theme=shinytheme("cerulean"),
    titlePanel("Effects of the Daily Wordle on Google Search Trends"),
    sidebarLayout(
        sidebarPanel(
            selectInput(
                "select", 
                label = h5("Select word/date"), 
                choices = rev(past_x_days_df$format),
                selected = 1
            ),
            hr(),
            p("The graph to the right displays the Google Search trends for a given wordle, with the date that that wordle appeared signified with a dashed line."),
            p("While many words (typically the more common) have no visible correlation with an increase in searches, several more recent and more unusual (ie: 'pleat', 'perky', 'knoll') experienced a significant gain."),
            p("The word list is updated every day, and will contain all words up to, but not including, the current day's word."),
            hr(),
            div(
                img(src="https://cdn-icons-png.flaticon.com/512/25/25231.png", height="18px"),
                a(href="https://github.com/louismeunier/wordle-trends", "Source Code")
            )
        ),
        mainPanel(
            withSpinner(
                plotOutput(outputId="distplot"),
                type=7,
                color="#317eac"
            )
        )
    )
)

# server
server <- function(input, output) {
    output$distplot <- renderPlot({
        # inputs
        selected <- input$select

        # get Google trends for word, during given range
        selected_row <- past_x_days_df[past_x_days_df$format == selected,]

        word <- selected_row$word
        date <- selected_row$date

        lower_date <- date - 14
        higher_date <- date + 14

        if (higher_date > Sys.Date()) {
            higher_date <- Sys.Date()
        }
        if (Sys.Date() - higher_date < 3) {
            showNotification(
                "You have a selected a fairly recent word. Trend data may be limited or non-existent.",
                type="warning"
            )
        }

        trend <- gtrends(
            keyword=word,
            time = paste(lower_date, higher_date, sep=" ")
        )

        iot <- trend$interest_over_time
        dates <- iot$date
        hits <- iot$hits

        # create pretty graph
        ggplot(
            iot, 
            aes(
                dates,
                hits
            )
        ) + 
        theme_classic() +
        geom_line(
            color="#317eac",
            size=1.5
        ) +
        geom_vline(
            xintercept = as.POSIXct.Date(date-1),
            linetype="dotted", 
            color="black",
            size=1.2
        ) +
        geom_text(
            aes(
                x=as.POSIXct.Date(selected_row$date-1.15),
                y=mean(hits), label=word
            ),
            color="black",
            angle=90
        )
    })
}

shinyApp(ui=ui, server=server)