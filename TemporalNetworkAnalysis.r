
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
#Edges List
PHStaticEdges <- read.csv("/Users/crboatwright/Downloads/TNAWR_StaticEdgelist.csv")

#Tutorial recommended using read.csv(file.choose()) to interactively choose file.
#Supposed to produce a dialog box, but wasn't able to get it to work.
#Dragged file into VS Code and then copied path into read.csv()

#Import Static Vertex Atrribute List
PHVertexAttributes <- read.csv("/Users/crboatwright/Downloads/TNAWR_VertexAttributes.csv",
    stringsAsFactors = FALSE
)

# Make and visualize our static network
thenetwork <- network(
  PHStaticEdges,
  vertex.attr = PHVertexAttributes,
  vertex.attrnames = c("vertex.id", "name", "region"),
  directed = FALSE,
  bipartite = FALSE,
  multiple = FALSE
)
plot(thenetwork)

#Produced an error because we set multiple to FALSE but parallel edges exist.
#Changed multiple to TRUE and a graph very similar to example was produced.

#Repeat process with Dynamic data

# Import Temporal Network Data
PHDynamicNodes <- read.csv("/Users/crboatwright/Downloads/TNAWR_DynamicNodes.csv")
PHDynamicEdges <- read.csv("/Users/crboatwright/Downloads/TNAWR_DynamicEdges.csv")

# Make the temporal network
dynamicCollabs <- networkDynamic(
  thenetwork,
  edge.spells = PHDynamicEdges,
  vertex.spells = PHDynamicNodes
)

# Check the temporal network
network.dynamic.check(dynamicCollabs)

#All values returned TRUE so ok to proceed

# Plot network dynamic object as a static image
plot(dynamicCollabs)

#Tutorial says it will produce graph similar to static, 
#but mine was pretty dramatically different

# Plot our dynamic network as a filmstrip
filmstrip(dynamicCollabs, displaylabels = FALSE)

#Got error tutorial said I would.
#Says it can be ignored, but
#in my code no filmstrip was produced

# Calculate how to plot an animated version of the dynamic network
compute.animation(
  dynamicCollabs,
  animation.mode = "kamadakawai",
  slice.par = list(
    start = 1260,
    end = 1300,
    interval = 1,
    aggregate.dur = 20,
    rule = "any"
  )
)

# Specify the full path for the output file
output_file <- "/Users/crboatwright/NetworkAnalysis/dynamic_network_animation.html"

# Ensure the output directory exists
output_dir <- dirname(output_file)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Render the animation and save it to a file
tryCatch({
  render.d3movie(
    dynamicCollabs,
    filename = output_file,
    displaylabels = FALSE,
    # This slice function makes the labels work
    vertex.tooltip = function(slice) {
      paste(
        "<b>Name:</b>", (slice %v% "name"),
        "<br>",
        "<b>Region:</b>", (slice %v% "region")
      )
    }
  )
}, error = function(e) {
  cat("Error during render.d3movie: ", e$message, "\n")
}, warning = function(w) {
  cat("Warning during render.d3movie: ", w$message, "\n")
})

# Check if the file was created
if (file.exists(output_file)) {
  # Open the generated HTML file in the default web browser
  browseURL(output_file)
} else {
  cat("Error: The file was not created.\n")
}


# Specify the full path for the output file
output_file <- "/Users/crboatwright/NetworkAnalysis/dynamic_network_animation.html"

# Render the animation and open it in a web brower
render.d3movie(
  dynamicCollabs,
  displaylabels = FALSE,
  # This slice function makes the labels work
  vertex.tooltip = function(slice) {
    paste(
      "<b>Name:</b>", (slice %v% "name"),
      "<br>",
      "<b>Region:</b>", (slice %v% "region")
    )
  }
)
# Check if the file was created
if (file.exists(output_file)) {
  # Open the generated HTML file in the default web browser
  browseURL(output_file)
} else {
  cat("Error: The file was not created.\n")
}



#Using other visualizations to examine data

# Plot formation of edges over time
plot(tEdgeFormation(dynamicCollabs, time.interval = .25))

# Calculate and graph the rolling betweenness centralization of the network
dynamicBetweenness <- tSnaStats(
  dynamicCollabs,
  snafun = "centralization",
  start = 1260,
  end = 1320,
  time.interval = 1,
  aggregate.dur = 20,
  FUN = "betweenness"
)
plot(dynamicBetweenness)

# Calculate and store the sizes of
# forward and backward reachable sets for each node
fwd_reach <- tReach(dynamicCollabs)
bkwd_reach <- tReach(dynamicCollabs, direction = "bkwd")
plot(fwd_reach, bkwd_reach)

# Calculate and plot the forward reachable paths
# of node number 3 (the Hospitaller Master)
HospitallerFwdPath <- tPath(
  dynamicCollabs,
  v = 3,
  direction = "fwd"
)
plotPaths(
  dynamicCollabs,
  HospitallerFwdPath,
  displaylabels = FALSE,
  vertex.col = "white"
)