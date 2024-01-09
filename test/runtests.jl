using FlatViews
using Test

@testset "inferred roundtrip" begin
    x = (a = 1, b = [2.0, 3.0], d = (4, 5f0))
    v = @inferred flatten(x)
    @test v == 1:5
    y = @inferred reconstruct_like(x, v)
    @test x == y
end

@testset "errors" begin
    x = (a = 1, b = 2)
    @test_throws BoundsError flatten_into!(zeros(1), x)
    @test_throws DimensionMismatch flatten_into!(zeros(3), x)
    @test_throws BoundsError reconstruct_like(x, zeros(1))
    @test_throws DimensionMismatch reconstruct_like(x, zeros(3))
end

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
