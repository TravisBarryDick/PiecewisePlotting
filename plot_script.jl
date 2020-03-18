using PiecewisePlotting, Plots

# There are two main functions in the PiecewisePlotting module:
# - load_pwc_dir reads a directory full of piecewise constant files and returns
#   a dictionary mapping from file names to `Piecewise{Float64}` instances.
# - plot_pwcs plots such a dictionary as a single curve by taking the average
#   of the piecewise functions.

# The following `plot_pwcs` and `plot_pwcs!` functions both forward their
# keyword arguments to the Plots.jl (http://docs.juliaplots.org/latest/)
# package, so you can style the lines, add labels, etc.

# this function creates a new plot
plot_pwcs(load_pwc_dir("./demo_data/plot1", 1.0; extension="out"); label="plot1")
# this function adds a curve to an existing plot
plot_pwcs!(load_pwc_dir("./demo_data/plot2", 1.0; extension="out"); label="plot2")
# save the plot
savefig("plot.pdf")
