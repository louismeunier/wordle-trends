library('shiny')
library('shinythemes')
library('shinycssloaders')

library('gtrendsR')
library('dplyr')
library('ggplot2')

words <- c("cigar", "rebut", "sissy", "humph", "awake", "blush", "focal", "evade", "naval", "serve", "heath", "dwarf", "model", "karma", "stink", "grade", "quiet", "bench", "abate", "feign", "major", "death", "fresh", "crust", "stool", "colon", "abase", "marry", "react", "batty", "pride", "floss", "helix", "croak", "staff", "paper", "unfed", "whelp", "trawl", "outdo", "adobe", "crazy", "sower", "repay", "digit", "crate", "cluck", "spike", "mimic", "pound", "maxim", "linen", "unmet", "flesh", "booby", "forth", "first", "stand", "belly", "ivory", "seedy", "print", "yearn", "drain", "bribe", "stout", "panel", "crass", "flume", "offal", "agree", "error", "swirl", "argue", "bleed", "delta", "flick", "totem", "wooer", "front", "shrub", "parry", "biome", "lapel", "start", "greet", "goner", "golem", "lusty", "loopy", "round", "audit", "lying", "gamma", "labor", "islet", "civic", "forge", "corny", "moult", "basic", "salad", "agate", "spicy", "spray", "essay", "fjord", "spend", "kebab", "guild", "aback", "motor", "alone", "hatch", "hyper", "thumb", "dowry", "ought", "belch", "dutch", "pilot", "tweed", "comet", "jaunt", "enema", "steed", "abyss", "growl", "fling", "dozen", "boozy", "erode", "world", "gouge", "click", "briar", "great", "altar", "pulpy", "blurt", "coast", "duchy", "groin", "fixer", "group", "rogue", "badly", "smart", "pithy", "gaudy", "chill", "heron", "vodka", "finer", "surer", "radio", "rouge", "perch", "retch", "wrote", "clock", "tilde", "store", "prove", "bring", "solve", "cheat", "grime", "exult", "usher", "epoch", "triad", "break", "rhino", "viral", "conic", "masse", "sonic", "vital", "trace", "using", "peach", "champ", "baton", "brake", "pluck", "craze", "gripe", "weary", "picky", "acute", "ferry", "aside", "tapir", "troll", "unify", "rebus", "boost", "truss", "siege", "tiger", "banal", "slump", "crank", "gorge", "query", "drink", "favor", "abbey", "tangy", "panic", "solar", "shire", "proxy", "point", "robot", "prick", "wince", "crimp", "knoll", "sugar", "whack", "mount", "perky", "could", "wrung", "light", "those", "moist", "shard", "pleat", "aloft", "skill", "elder", "frame")
first_word_date <- as.Date("2021-06-19")
latest_word_date <- as.Date("2022-02-08")

past_x_days_df <- data.frame(
    date = seq(latest_word_date-(length(words)-1), latest_word_date, by=1),
    word = words
)

past_x_days_df$format = paste(past_x_days_df$date, past_x_days_df$word, sep=": ")

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
            p("While many words (typically the more common) have no visible correlation with an increase in searches, several more recent and more unusual (ie: 'pleat', 'perky', 'knoll') experienced a significant gain.")
         ),
        mainPanel(
            withSpinner(
                plotOutput(outputId="distplot"),
                type=7,
                color="#317eac"
            ),
            textOutput("test")
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

        output$test <- renderText({word})

        lower_date <- date - 14
        higher_date <- date + 14

        if (higher_date > Sys.Date()) {
            higher_date <- Sys.Date()
        }
        if (Sys.Date() - higher_date < 3) {
            showNotification(
                "You have a selected a fairly recent word. Trend data may be limited or non-existent.",
                type='warning'
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
            xintercept = as.POSIXct.Date(date),
            linetype="dotted", 
            color="black",
            size=1.2
        ) +
        geom_text(
            aes(
                x=as.POSIXct.Date(selected_row$date-0.15),
                y=mean(hits), label=word
            ),
            color="black",
            angle=90
        )
    })
}

shinyApp(ui=ui, server=server)