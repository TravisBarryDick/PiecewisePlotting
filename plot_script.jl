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
plot1_pwcs = load_pwc_dir("./demo_data/plot1", 1.0; extension = "out")
plot()
plot_mean_with_stderr!(
    plot1_pwcs,
    label = "plot1 mean with stderr";
    xlabel = "the x label!",
    ylabel = "the y label!",
)

# this function adds a curve to an existing plot
plot_geomean!(
    load_pwc_dir("./demo_data/plot2", 1.0; extension = "out");
    label = "plot2 geomean",
)
plot_mean!(load_pwc_dir("./demo_data/plot2", 1.0; extension = "out"); label = "plot2 mean")
# save the plot
savefig("plot.pdf")

plot1_mean_pwc = get_mean_pwc(plot1_pwcs)
# this line finds the interval with minimum value and shows it
plot1_min_interval, plot1_min_value = find_minimizer(plot1_mean_pwc)
println("Plot 1 min interval = $(plot1_min_interval) has value $(plot1_min_value)")
println("Plot 1 value at x=0.5 is $(plot1_mean_pwc(0.5))")
