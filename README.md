# Quantum Evolution Training Camp

Training materials for the training camp about using tensor network methods for time evolution.
- **Time**: 
    - Discussion and planning: June 3-5, 2025, 10:00-17:00
    - Coding and writing: June 6-11, 2025
    - Sharing: June 12, 2025, 10:00-17:00
- **Location**: W4-202, HKUST-GZ

## Objectives

Participants will be divided into two groups, one group implements the GSE-TDVP method, the other group implements the simple update with gauge fixing method.

1. Implement either of the following methods (with OMEinsum):
   - Group 1: GSE-TDVP method,
   - Group 2: Simple update with gauge fixing method.
2. Challenge! Simulated a Rydberg atoms array with the implemented methods, test with the exact simulation results. The winning group will get a souvenir (TBD).
   Score: Speed to reach $10^{-2}$ precision in the simulation task detailed in [this page](https://queracomputing.github.io/Bloqade.jl/dev/tutorials/6.MWIS/main/), the target lattice size is $10 \times 10$.
3. Practical challenge! Simulate the 2D kicked Ising dynamics in IBM's quantum experiment [this page](https://www.nature.com/articles/s41586-023-06096-3) by classical computation. Can you simulate the dynamics for $\pi/2-\epsilon$ pulse of Ising interaction i.e. away from the maximally entangling $CZ$ gate?
  

## References

### Group 1
- TDVP method basics[^Vanderstraeten2019]
- GSE-TDVP method[^Yang2020] (code: https://github.com/ITensor/ITensorMPS.jl)

### Group 2
- Belief propagation for gauging tensor networks[^Tindall2023]. It can be generalized the arbitrary geometry[^Gray2024] (code: https://github.com/ITensor/ITensorNetworks.jl)
- Methods to resolve the small loop problem: It depends on the loop size and loop correlations, lattices in 2D with smaller loop sizes probably would need something beyond BP like block BP[^Guo2023], boundary MPS, or loop corrections[^Evenbly2024]. In practice, it can be sufficient to use BP to evolve the state and then use approximations beyond BP to perform measurements, see for example[^Tindall2025].
- For Rydberg atoms, there will be the added complexity of handling long range interactions. Related work that I'm aware of is:[^O’Rourke2020] and[^O’Rourke2023].
- Background knowledge about adiabatic dynamics scaling, across or near the Ising CFTs: 1+1D latest quantum experiment [^Miessen24]; 2+1D latest classical simulation [^Schmitt22] on 16-by-16 lattice combining TDVP, neural quantum state, iPEPS methods. 

[^Yang2020]: Yang, M., White, S.R., 2020. Time Dependent Variational Principle with Ancillary Krylov Subspace. Phys. Rev. B 102, 094315. https://doi.org/10.1103/PhysRevB.102.094315
[^Vanderstraeten2019]: Vanderstraeten, L., Haegeman, J., Verstraete, F., 2019. Tangent-space methods for uniform matrix product states. SciPost Physics Lecture Notes 7, 1–77. https://doi.org/10.21468/scipostphyslectnotes.7
[^Gray2024]: Gray, J., Chan, G.K.-L., 2024. Hyper-optimized approximate contraction of tensor networks with arbitrary geometry. Phys. Rev. X 14, 011009. https://doi.org/10.1103/PhysRevX.14.011009
[^Tindall2023]: Tindall, J., Fishman, M.T., 2023. Gauging tensor networks with belief propagation. SciPost Phys. 15, 222. https://doi.org/10.21468/SciPostPhys.15.6.222
[^Guo2023]: Guo, C., Poletti, D., Arad, I., 2023. Block belief propagation algorithm for two-dimensional tensor networks. Phys. Rev. B 108, 125111. https://doi.org/10.1103/PhysRevB.108.125111
[^Evenbly2024]: Evenbly, G., Pancotti, N., Milsted, A., Gray, J., Chan, G.K.-L., 2024. Loop Series Expansions for Tensor Networks. https://doi.org/10.48550/arXiv.2409.03108
[^Tindall2025]: Tindall, J., Mello, A., Fishman, M., Stoudenmire, M., Sels, D., 2025. Dynamics of disordered quantum systems with two- and three-dimensional tensor networks. https://doi.org/10.48550/arXiv.2503.05693

[^O’Rourke2020]: O’Rourke, M.J., Chan, G.K.-L., 2020. A simplified and improved approach to tensor network operators in two dimensions. Phys. Rev. B 101, 205142. https://doi.org/10.1103/PhysRevB.101.205142
[^O’Rourke2023]: O’Rourke, M.J., Chan, G.K.-L., 2023. Entanglement in the quantum phases of an unfrustrated Rydberg atom array. Nat Commun 14, 5397. https://doi.org/10.1038/s41467-023-41166-0

[^Miessen24]: Alexander Miessen, Daniel J. Egger, Ivano Tavernelli and Guglielmo Mazzola, Benchmarking Digital Quantum Simulations Above Hundreds of Qubits Using Quantum Critical Dynamics, PRX Quantum 5, 040320 (2024). https://journals.aps.org/prxquantum/abstract/10.1103/PRXQuantum.5.040320
[^Schmitt22]: Markus Schmitt, Marek M. Rams, Jacek Dziarmaga, Markus Heyl, Wojciech H. Zurek, Quantum phase transition dynamics in thetwo-dimensional transverse-field Ising model, Science Advance 8, 6850 (2022). https://www.science.org/doi/10.1126/sciadv.abl6850
