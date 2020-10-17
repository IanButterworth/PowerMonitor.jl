module PowerMonitor

Base.@kwdef mutable struct PowerStatus
    src::Symbol = :none
    perc::Float64 = 0
end

const timers = Timer[]

function status()
    @static if Sys.isapple()
        lines = collect(split(read(`pmset -g batt`, String), "\n"))
        src = split(lines[1], "'")[2] == "Battery Power" ? :Battery : :External
        perc = parse(Float64, split(split(lines[2], "\t")[2], "%")[1])
        return PowerStatus(src, perc)
    elseif Sys.islinux()
        lines = collect(split(read(`upower -i /org/freedesktop/UPower/devices/battery_BAT0`, String), "\n"))
        ps = PowerStatus()
        for line in lines
            if occursin("state:", line)
                ps.perc = parse(Float64, split(split(strip(line), "\t")[2], "%")[1]) == "discharging" ? :Battery : :External
            end
            if occursin("percentage:", line)
                ps.perc = parse(Float64, split(split(strip(line), "\t")[2], "%")[1])
            end
        end
        return ps
    end
end
#
function automate(src_map::Dict{Symbol, Function}; interval = 1)
    Timer((timer)->src_map[status().src](), 0, interval = interval)
end

function autopreomp_mainsonly()
    t = automate(
        Dict(   :Battery =>     ()->ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0,
                :External =>    ()->ENV["JULIA_PKG_PRECOMPILE_AUTO"]=1
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
