module PiecewisePlotting

using DelimitedFiles, PiecewiseTools, Plots, Glob
import Statistics

export load_pwc, load_pwc_dir, plot_pwcs!, plot_pwcs

"""
`load_pwc(path, range_bound)` loads a `Piecewise{T}` from the .csv file located
at `path`.

# File Format
- Each line of the .csv file describes one piece of the `Piecewise{T}` function.
- The pieces must be sorted from left to right.
- The first column of a line indicates the starting point for that piece.
- The second column of a line gives the value for the corresponding piece (and
  the ending point of the previous piece).

Since the file format does not specify an upper bound on the range of the
`Piecewise{T}`, an upper bound on the range is passed as the `range_bound`
argument to `load_pwc`.
"""
function load_pwc(path, range_bound)
    data = readdlm(path, ',')
    # Get the boundaries as the first column of the file. Since the file doesn't
    # contain the upper bound on the function value, we take that from the
    # `range_bound` argument.
    boundaries = data[:, 1]
    push!(boundaries, range_bound)
    # The values are given by the second column of the PWC file.
    values = data[:, 2]
    return Piecewise(boundaries, values)
end

"""
`load_pwc_dir(path, range_bound)` returns a dictionary mapping file names to
`Piecewise{T}` instances. Calls `load_pwc(filename, range_bound)` for each file
.txt file in the given directory.

Optionally you may provide a the `extension` keyword argument to change the type
of file loaded. For example `load_pwc_dir(path, range_bound; extension="csv")`
will read .csv files rather than .txt files. This does not change how the files
are interpreted.
"""
load_pwc_dir(path, range_bound; extension = "txt") = Dict(
    name => load_pwc(name, range_bound)
    for name in glob("*.$(extension)", path)
)

function plot_pwcs!(pwcs; samples = 1000, options...)
    pwcs = collect(values(pwcs))
    # Get the x points we will plot the function values at
    xs = sample(pwcs[1], samples)[1]
    # Sample y points from each pwc and average them
    ys = Statistics.mean(sample(pwc, samples)[2] for pwc in pwcs)
    # Plot the curve
    plot!(xs, ys; options...)
end

plot_pwcs(args...; options...) = (plot(); plot_pwcs!(args...; options...))

end
