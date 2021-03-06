library(tidyverse)
library(lubridate)

df <- read_delim('household_power_consumption.txt', delim=';', na='?', col_types=cols(Date=col_date(format="%d/%m/%Y")))
df.sub <- subset(df, subset=(Date >= "2007-02-01" & Date <= "2007-02-02"))
rm(df)

df.sub$Datetime <- with(df.sub, as.POSIXct(paste(Date, Time)))
df.gat <- df.sub %>% gather(Sub_metering_1, Sub_metering_2, Sub_metering_3, key='Sub_metering', value='Energy')

feature_ylab_pairs <- with(df.sub, list(list(Global_active_power, 'Global Active Power'), 
                        list(Voltage, 'Voltage (volt)'), 
                        list(Global_reactive_power, 'Global Reactive Power')))
uni_plot <- function(df, feature_ylab_pair){
    ggplot(data=df) + 
        geom_line(mapping=aes(x=Datetime, y=feature_ylab_pair[[1]])) + 
        labs(x='', y=feature_ylab_pair[[2]]) + 
        scale_x_datetime(date_breaks='day', date_labels='%a')
}
plots <- purrr::map(feature_ylab_pairs, ~uni_plot(df.sub, .))
p3 <- ggplot(data=df.gat, mapping=aes(x=Datetime, y=Energy)) + 
    geom_line(mapping=aes(color=Sub_metering)) +
    labs(x='', y='Energy sub metering') + 
    theme(legend.title=element_blank(), legend.position=c(0.75, 0.84)) + 
    scale_x_datetime(date_breaks='day', date_labels='%a') + 
    scale_color_manual(values=c('black', 'red', 'blue'))

png(filename="plot4.png", width=480, height=480)
gridExtra::grid.arrange(plots[[1]], plots[[2]], p3, plots[[3]], nrow=2)
dev.off()
