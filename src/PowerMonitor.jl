module PowerMonitor

import battery_cli_jll: battery

Base.@kwdef mutable struct PowerStatus
    pow_stat::Symbol = :none
    perc::Float64 = 0
end

function status(;show_raw = false)
    pow_stat = nothing
    perc = 0
    iob = IOBuffer()
    good = battery() do battery_cmd
        success(pipeline(`$(battery_cmd)`, iob))
    end
    !good && return PowerStatus(:nobatteries, 100)
    lines = split(String(take!(iob)), "\n")
    st = lines[1] # just use first battery for now
    show_raw && @info lines
    pow_stat = parse_charge_status(st)
    perc = parse_perc(st)
    return PowerStatus(pow_stat, perc)
end

function parse_charge_status(st::AbstractString)::Union{Symbol,Nothing}
    occursin("Charging", st) && return :charging
    occursin("Full", st) && return :full
    occursin("Discharging", st) && return :discharging
    occursin("Unknown", st) && return :unknown
    error("Cannot find charge st in: $st")
end
function parse_perc(st::AbstractString)::Float64
    parse(Float64, split(split(st, ",")[2], "%")[1])
end

### AUTOMATION
const timers = Timer[]

function automate(src_map::Dict{Symbol, Function}; interval = 1)
    Timer((timer)->src_map[status().pow_stat](), 0, interval = interval)
end

function autoprecomp_notbattery()
    status().pow_stat == :nobatteries && error("This system reports that no batteries are present")
    t = automate(
        Dict(   :nobatteries => ()->ENV["JULIA_PKG_PRECOMPILE_AUTO"]=1,
                :charging =>    ()->ENV["JULIA_PKG_PRECOMPILE_AUTO"]=1,
                :full =>        ()->ENV["JULIA_PKG_PRECOMPILE_AUTO"]=1,
                :discharging => ()->ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0,
                :unknown =>     ()->ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0,
            );
            interval = 1
        )
    push!(timers, t)
    nothing
end

function stop_automation()
    close.(timers)
    empty!(timers)
    nothing
end

end # module
