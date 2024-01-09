using FlatViews
using Test

x = (a = 1, b = [2.0, 3.0], d = (4, 5f0))
v = @inferred flatten(x)
y = @inferred reconstruct_like(x, v)
@test x == y

using JET
@testset "static analysis with JET.jl" begin
    @test isempty(JET.get_reports(report_package(FlatViews, target_modules=(FlatViews,))))
end

@testset "QA with Aqua" begin
    import Aqua
    Aqua.test_all(FlatViews; ambiguities = false)
    # testing separately, cf https://github.com/JuliaTesting/Aqua.jl/issues/77
    Aqua.test_ambiguities(FlatViews)
end
