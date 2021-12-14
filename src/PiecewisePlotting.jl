module PiecewisePlotting

using DelimitedFiles, PiecewiseTools, Plots, Glob
import Statistics

export load_pwc, load_pwc_dir, plot_pwcs!, plot_pwcs, get_mean_pwc, find_minimizer
export plot_mean_with_stderr!, plot_geomean!, plot_mean!

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
load_pwc_dir(path, range_bound; extension = "txt") =
    Dict(name => load_pwc(name, range_bound) for name in glob("*.$(extension)", path))

function sample_pwcs(pwcs, samples)
    pwcs = collect(values(pwcs))
    xs = sample(pwcs[1], samples)[1]
    sample_vals = Array{Float64}(undef, length(pwcs), samples)
    for (i, pwc) in enumerate(pwcs)
        sample_vals[i, :] = sample(pwc, samples)[2]
    end
    return xs, sample_vals
end

function plot_mean!(pwcs; samples = 1000, options...)
    xs, sample_vals = sample_pwcs(pwcs, samples)
    ys = vec(Statistics.mean(sample_vals, dims = 1))
    plot!(xs, ys; options...)
end

function plot_mean_with_stderr!(pwcs; samples = 1000, options...)
    xs, sample_vals = sample_pwcs(pwcs, samples)
    ys = vec(Statistics.mean(sample_vals, dims = 1))
    σs = vec(Statistics.std(sample_vals, dims = 1))
    stderrs = σs / sqrt(length(pwcs))
    plot!(xs, ys; ribbon = stderrs, options...)
end

function plot_geomean!(pwcs; samples = 1000, options...)
    xs, sample_vals = sample_pwcs(pwcs, samples)
    ys = [geomean(sample_vals[:, i]) for i = 1:size(sample_vals, 2)]
    plot!(xs, ys; options...)
end

function geomean(xs)
    log_geomean = 0.0
    n = length(xs)
    for x in xs
        log_geomean += log(x)
    end
    log_geomean /= n
    return exp(log_geomean)
end

function get_mean_pwc(pwcs)
    # Drop the file names from the PWCs variable and "compress them".
    # Compressing merges neighboring intervals that have exactly the same value.
    pwcs = [compress(pwc) for pwc in values(pwcs)]
    # Return a compressed version of the mean PWC
    return compress(PiecewiseTools.mean(pwcs))
end

function find_minimizer(pwc)
    best_interval = Interval(0, 0)
    best_value = Inf
    for (ivl, v) in PieceIterator(pwc)
        if v < best_value
            best_interval = ivl
            best_value = v
        end
    end
    return best_interval, best_value
end

end
