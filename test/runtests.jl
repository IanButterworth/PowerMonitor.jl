using Test, PowerMonitor

CI = get(ENV, "CI", "false") === "true"

@show PowerMonitor.status(show_raw = true)
@testset "No batteries on CI platforms" begin
    if CI
        res = PowerMonitor.status(show_raw = true)
        @test res.pow_stat == :nobatteries
        @test res.perc == 100
    end
end

@testset "Automation: Auto-precomp" begin
    if CI
        @test_throws ErrorException PowerMonitor.autopreomp_notbattery()
    end
    PowerMonitor.stop_automation()
end
