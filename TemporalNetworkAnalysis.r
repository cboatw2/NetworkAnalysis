
#This tutorial is available through the Programming Historian
# website: https://programminghistorian.org/en/lessons/temporal-network-analysis-with-r

#Load necessary packages
install.packages("sna")
install.packages("tsna")
install.packages("ndtv")

#Confirm loading
library(sna)
library(tsna)
library(ndtv)

#Additional packages may be necessary for tsna and ndtv. See terminal messages.

#Tutorial uses a unimodal network: all nodes are of the same type. 
#Most historians want a bimodal or multimodal dataset, but will have to project 
#onto a unimodal visualization in order to produce something useful and readable.

#Temporal networks have the added layer of onset and terminus data.
#This allows for change over time and for nodes/relationships to enter and exit the network.

#Begin by setting up a static network visualization

#Import Static Network Data
PHStaticEdges <- read.csv(TNAWR_StaticEdgelist.csv)
