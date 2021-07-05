// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Oracles;

    /// # Summary
    /// Interpolates between two generators with a uniform schedule,
    /// returning an operation that applies simulated evolution under
    /// the resulting time-dependent generator to a qubit register.
    ///
    /// # Input
    /// ## interpolationTime
    /// Time to perform the interpolation over.
    /// ## evolutionGeneratorStart
    /// Initial generator to simulate evolution under.
    /// ## evolutionGeneratorEnd
    /// Final generator to simulate evolution under.
    /// ## timeDependentSimulationAlgorithm
    /// A time-dependent simulation algorithm that will be used
    /// to simulate evolution during the uniform interpolation schedule.
    ///
    /// # Remarks
    /// If the interpolation time is chosen to meet the adiabatic conditions,
    /// then this function returns an operation which performs adiabatic
    /// state preparation for the final dynamical generator.
    function InterpolatedEvolution(
            inerpolationTime : Double,
            evolutionGeneratorStart : EvolutionGenerator,
            evolutionGeneratorEnd : EvolutionGenerator,
            timeDependentSimulationAlgorithm : TimeDependentSimulationAlgorithm
    ) : (Qubit[] => Unit is Adj + Ctl) {
        //   evolutionSetStart and evolutionSetEnd must be identical
        let (evolutionSetStart, generatorSystemStart) = evolutionGeneratorStart!;
        let (evolutionSetEnd, generatorSystemEnd) = evolutionGeneratorEnd!;
        let generatorSystemTimeDependent = InterpolateGeneratorSystems(generatorSystemStart, generatorSystemEnd);
        let evolutionSchedule = EvolutionSchedule(evolutionSetStart, generatorSystemTimeDependent!);
        return timeDependentSimulationAlgorithm!(inerpolationTime, evolutionSchedule, _);
    }
    
    
    /// # Summary
    /// Performs state preparation by applying a
    /// `statePrepUnitary` on the input state, followed by adiabatic state
    /// preparation using a `adiabaticUnitary`, and finally phase estimation
    /// with respect to `qpeUnitary`on the resulting state using a
    /// `phaseEstAlgorithm`.
    ///
    /// # Input
    /// ## statePrepUnitary
    /// An oracle representing state preparation for the initial dynamical
    /// generator.
    /// ## adiabaticUnitary
    /// An oracle representing the adiabatic evolution algorithm to be used
    /// to implement the sweeps to the final state of the algorithm.
    /// ## qpeUnitary
    /// An oracle representing a unitary operator $U$ representing evolution
    /// for time $\delta t$ under a dynamical generator with ground state
    /// $\ket{\phi}$ and ground state energy $E = \phi\\,\delta t$.
    /// ## phaseEstAlgorithm
    /// An operation that performs phase estimation on a given unitary operation.
    /// See [iterative phase estimation](/quantum/libraries/characterization#iterative-phase-estimation)
    /// for more details.
    /// ## qubits
    /// A register of qubits to be used to perform the simulation.
    ///
    /// # Output
    /// An estimate $\hat{\phi}$ of the ground state energy $\phi$
    /// of the generator represented by $U$.
    operation AdiabaticStateEnergyUnitary(statePrepUnitary : (Qubit[] => Unit), adiabaticUnitary : (Qubit[] => Unit), qpeUnitary : (Qubit[] => Unit is Adj + Ctl), phaseEstAlgorithm : ((DiscreteOracle, Qubit[]) => Double), qubits : Qubit[]) : Double {
        statePrepUnitary(qubits);
        adiabaticUnitary(qubits);
        let phaseEst = phaseEstAlgorithm(OracleToDiscrete(qpeUnitary), qubits);
        return phaseEst;
    }


    /// # Summary
    /// Performs state preparation by applying a
    /// `statePrepUnitary` on an automatically allocated input state, 
	/// followed by adiabatic state preparation using a
    /// `adiabaticUnitary`, and finally phase estimation with respect to
    /// `qpeUnitary`on the resulting state using a `phaseEstAlgorithm`.
    ///
    /// # Input
    /// ## nQubits
    /// Number of qubits used for the simulation.
    /// ## statePrepUnitary
    /// An oracle representing state preparation for the initial dynamical
    /// generator.
    /// ## adiabaticUnitary
    /// An oracle representing the adiabatic evolution algorithm to be used
    /// to implement the sweeps to the final state of the algorithm.
    /// ## qpeUnitary
    /// An oracle representing a unitary operator $U$ representing evolution
    /// for time $\delta t$ under a dynamical generator with ground state
    /// $\ket{\phi}$ and ground state energy $E = \phi\\,\delta t$.
    /// ## phaseEstAlgorithm
    /// An operation that performs phase estimation on a given unitary operation.
    /// See [iterative phase estimation](/quantum/libraries/characterization#iterative-phase-estimation)
    /// for more details.
    ///
    /// # Output
    /// An estimate $\hat{\phi}$ of the ground state energy $\phi$
    /// of the generator represented by $U$.
    operation EstimateEnergyWithAdiabaticEvolution(nQubits : Int, statePrepUnitary : (Qubit[] => Unit), adiabaticUnitary : (Qubit[] => Unit), qpeUnitary : (Qubit[] => Unit is Adj + Ctl), phaseEstAlgorithm : ((DiscreteOracle, Qubit[]) => Double)) : Double {
        using (qubits = Qubit[nQubits]) {
            let phaseEst = AdiabaticStateEnergyUnitary(statePrepUnitary, adiabaticUnitary, qpeUnitary, phaseEstAlgorithm, qubits);
            ResetAll(qubits);
            return phaseEst;
        }
    }


    /// # Summary
    /// Performs state preparation by applying a
    /// `statePrepUnitary` on an automatically allocated input state
    /// phase estimation with respect to `qpeUnitary`on the resulting state
    /// using a `phaseEstAlgorithm`.
    ///
    /// # Input
    /// ## nQubits
    /// Number of qubits used to perform simulation.
    /// ## statePrepUnitary
    /// An oracle representing state preparation for the initial dynamical
    /// generator.
    /// ## qpeUnitary
    /// An oracle representing a unitary operator $U$ representing evolution
    /// for time $\delta t$ under a dynamical generator with ground state
    /// $\ket{\phi}$ and ground state energy $E = \phi\\,\delta t$.
    /// ## phaseEstAlgorithm
    /// An operation that performs phase estimation on a given unitary operation.
    /// See [iterative phase estimation](/quantum/libraries/characterization#iterative-phase-estimation)
    /// for more details.
    ///
    /// # Output
    /// An estimate $\hat{\phi}$ of the ground state energy $\phi$
    /// of the ground state energy of the generator represented by $U$.
    operation EstimateEnergy (nQubits : Int, statePrepUnitary : (Qubit[] => Unit), qpeUnitary : (Qubit[] => Unit is Adj + Ctl), phaseEstAlgorithm : ((DiscreteOracle, Qubit[]) => Double)) : Double
    {
        // We can estimate the energy of the state prepared by statePrepUnitary
        // in this case by passing a NoOp as the adiabatic evolution step.
        let phaseEst = EstimateEnergyWithAdiabaticEvolution(nQubits, statePrepUnitary, NoOp<Qubit[]>, qpeUnitary, phaseEstAlgorithm);
        return phaseEst;
    }

}
