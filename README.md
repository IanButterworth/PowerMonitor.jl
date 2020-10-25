# PowerMonitor.jl
 System power and battery status monitoring and automation in Julia

 Uses https://github.com/distatus/battery


## Installation

```
pkg> add PowerMonitor
```

## Power Monitoring
```julia
julia> import PowerMonitor
julia> PowerMonitor.status()
PowerMonitor.PowerStatus(:charging, 84.0)
```

## Automation
```julia
import PowerMonitor
PowerMonitor.automate(
        Dict(   :nobatteries => ()->println("Batteries not included"),
                :charging =>    ()->println("Plugged in"),
                :full =>        ()->println("Plugged in & full"),
                :discharging => ()->println("On battery & discharging"),
                :unknown =>     ()->nothing,
            );
            interval = 1
        )
```

To stop all automation:
```julia
PowerMonitor.stop_automation()
```

## Ready-made automation

Add this to `.julia/config/startup.jl` to disable Julia Pkg's auto-precompilation (requires v1.6) when on battery

```julia
import PowerMonitor
PowerMonitor.autoprecomp_notbattery()
```
