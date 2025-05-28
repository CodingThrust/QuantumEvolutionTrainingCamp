using Test, YaoBlocks, RydbergToolkit
using RydbergToolkit: SVector, interaction_strength, P1

@testset "exact simulation" begin
    sys = RydbergSystem([[0.0], [5.72]])
    @test sys.coordinates == [SVector(0.0), SVector(5.72)]
    @test sys.C == 2π * 862690
    @test interaction_strength(sys, 1, 2) ≈ 154.7599067895149
end

@testset "exact simulation" begin
    sys = RydbergSystem([[0.0], [8.72]])
    detuning = GlobalPulse(piecewise_linear([0.0, 1.0, 2.0], [1.0, 2.0, 3.0]), natoms(sys))
    rabi = GlobalPulse(piecewise_linear([0.0, 1.0, 2.0], [1.0, 2.0, 3.0]), natoms(sys))
    tspan = (0.0, 0.5)
    reg = create_zero_state(ExactSimulator(), sys)
    reg = simulate(reg, ExactSimulator(), sys, detuning, rabi, tspan; dt=1e-3)
    op = kron(P1, P1)
    @test expect(op, reg) ≈ 0.002247748148724942 rtol=1e-5
end

@testset "scar simulation" begin
    Δ1 = piecewise_linear([0.0, 0.3, 1.6, 2.2, 2.2+1e-10, 4.2], 2π * [-10.0, -10.0, 10.0, 10.0, 0.0, 0.0]);
    Ω1 = piecewise_linear([0.0, 0.05, 1.6, 2.2, 2.2+1e-10, 4.2], 2π * [0.0, 4.0, 4.0, 0.0, 2.0, 2.0]);

    nsites = 9
    atoms = [[5.72 * c] for c in 0:nsites-1]

    total_time = 4.2
    dt = 1e-2
    backend = ExactSimulator()
    # blockade radius = Inf
    reg = create_zero_state(backend, RydbergSystem(atoms))
    iter = SimulationIterator(reg, backend, RydbergSystem(atoms), GlobalPulse(Δ1, nsites), GlobalPulse(Ω1, nsites); tstart=0.0, tstop=total_time, dt, pxp_cutoff=0.0, longtail_cutoff=Inf)
    for (t, reg) in iter end
    densities = [RydbergToolkit.density(iter.reg, i) for i in 1:nsites]
    entropy = RydbergToolkit.entropy(iter.reg, 5) # compute entropy from the reduced density matrix
    @test densities ≈ [0.2598224211464548, 0.25691051826391303, 0.24020715632057033, 0.30400998171888216, 0.26496131568316517, 0.30400998171888216, 0.24020715632057038, 0.25691051826391287, 0.2598224211464548] rtol=1e-2
    @test entropy ≈ 1.5223686310447104 rtol=1e-2

    # cutoff radius = 6.0
    reg = create_zero_state(backend, RydbergSystem(atoms))
    iter = SimulationIterator(reg, backend, RydbergSystem(atoms), GlobalPulse(Δ1, nsites), GlobalPulse(Ω1, nsites); tstart=0.0, tstop=total_time, dt, pxp_cutoff=0.0, longtail_cutoff=6.0)
    for (t, reg) in iter end
    densities = [RydbergToolkit.density(iter.reg, i) for i in 1:nsites]
    entropy = RydbergToolkit.entropy(iter.reg, 5) # compute entropy from the reduced density matrix
    @test densities ≈ [0.1690996125650822, 0.1414575823037829, 0.13802681371406433, 0.49548533825001323, 0.11308459533104748, 0.4954853382500129, 0.1380268137140644, 0.141457582303783, 0.16909961256508232] rtol=1e-2
    @test entropy ≈ 0.9569576469229166 rtol=1e-2
end