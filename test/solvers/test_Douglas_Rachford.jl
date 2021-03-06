@testset "DouglasRachford" begin
    # Though this seems a strange way, it is a way to compute the mid point
    M = Sphere(2)
    p = [1., 0., 0.]
    q = [0., 1., 0.]
    r = [0., 0., 1.]
    start = [0.,0.,1.]
    result = geodesic(M, p, q, 0.5)
    F(x) = distance(M, x, p)^2 + distance(M, x, q)^2
    prox1 = (η,x) -> prox_distance(M, η, p, x)
    prox2 = (η,x) -> prox_distance(M, η, q, x)
    @test_throws ErrorException DouglasRachford(M,F,Array{Function,1}([prox1,]),start) # we need more than one prox
    xHat = DouglasRachford(M,F,[prox1,prox2],start)
    @test F(start) > F(xHat)
    @test_broken distance(M, xHat, result) ≈ 0
    # but we can also compute the riemannian center of mass (locally) on Sn
    # though also this is not that useful, but easy to test that DR works
    F2(x) = distance(M,x,p)^2 + distance(M,x,q)^2 + distance(M,x,r)^2
    prox3 = (η,x) -> prox_distance(M,η,r,x)
    o = DouglasRachford(M,F2,[prox1,prox2,prox3],start;
    debug = [DebugCost(), DebugIterate(), DebugProximalParameter(),100],
    record = [RecordCost(), RecordProximalParameter()],
    return_options=true
    )
    xHat2 = get_solver_result(o)
    drec2 = get_record(o)
    xCmp = 1/sqrt(3)*ones(3)
    # since the default does not run that long -> rough estimate
    @test_broken distance(M,xHat2,xCmp) ≈ 0 atol = 10^(-5)
end
