# NYT Games Wrapped

This repository has the tools to create a wrap-up of your Wordle and Connections results against a friend from a WhatsApp chat where you have been sharing them with one another. Download or clone the repository to your computer and follow the instructions.

There are two folders in the repository. The `/R` folder contains the code to extract the results form your WhatsApp export file. It will produce two Excel files of results, `results_connections.xlsx` and `results_wordle.xlsx`. The `/PowerPoint` folder contains the PowerPoint template for the wrap-up. This presentation is linked to the said Excel files.

The R code works by feeding it the export .txt file from a WhatsApp chat. You only need to change the `chat_filepath` parameter in line 2 of the `results_connections.R` and `results_wordle.R` scripts, and run them. The two output Excels will be (over)written in the `/R` folder.

Once the output Excels have been updated, you need to open the PowerPoint presentation and update the charts. Supposedly the presentation will ask you whether you want to update the links on opening, but just to be sure, I would [update each chart](https://support.microsoft.com/en-us/office/change-the-data-in-an-existing-chart-539c9840-7412-4da3-ab06-fcf318e996df) individually.

Finally, feel free to modify the code as you see fit for it to accept other formats or produce other metrics.