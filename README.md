# PowerMonitor.jl
 System power monitoring and automation


## Installation

```
pkg> add https://github.com/ianshmean/PowerMonitor.jl
```

## Power Monitoring
```julia
julia> import PowerMonitor
julia> PowerMonitor.status()
PowerMonitor.PowerStatus(:External, 84.0)
```

## Automation
```julia
import PowerMonitor
PowerMonitor.automate(Dict(:Battery => ()->println("On Battery"), :External => ()->println("charging")); interval = 1)
```

To stop all automation:
```julia
PowerMonitor.stop_automation()
```

## Ready-made automation

Add this to `.julia/config/startup.jl` to disable Julia Pkg's auto-precompilation (requires v1.6) when on battery

```julia
import PowerMonitor
PowerMonitor.autopreomp_notbattery()
```