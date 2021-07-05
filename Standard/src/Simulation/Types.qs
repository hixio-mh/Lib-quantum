// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation {

    // For an overview of the simulation library, see [Hamiltonian
    // Simulation](applications#hamiltonian-simulation)

    /// # Summary
	/// Represents a time-independent simulation algorithm.
	/// 
    /// A time-independent simulation technique converts an
    ///  <xref:microsoft.quantum.canon.evolutiongenerator>
    /// to unitary time evolution for some time-interval.
    ///
    /// # Input
    /// ## First Parameter
    /// `Double` is time interval of simulation.
    /// ## Second Parameter
    /// `EvolutionGenerator` is a representation of the generator of dynamic evolution.
    /// ## Third Parameter
    /// `Qubit[]` is register encoding state of system.
    ///
    /// # Output
    /// Unitary evolution by generator for time `Double`.
    newtype SimulationAlgorithm = ((Double, EvolutionGenerator, Qubit[]) => Unit is Adj + Ctl);
    
    /// # Summary
	/// Represents a time-dependent simulation algorithm.
	/// 
    /// A time-dependent simulation technique converts an
    /// <xref:microsoft.quantum.canon.evolutionschedule>
    /// to unitary time-evolution for some time-interval.
    ///
    /// # Input
    /// ## First Parameter
    /// `Double` is time interval of simulation.
    /// ## Second Parameter
    /// `EvolutionSchedule` is a representation of the time-dependent generator of dynamic evolution.
    /// ## Third Parameter
    /// `Qubit[]` is register encoding state of system.
    ///
    /// # Output
    /// Unitary evolution by time-dependent generator for time `Double`.
    newtype TimeDependentSimulationAlgorithm = ((Double, EvolutionSchedule, Qubit[]) => Unit is Adj + Ctl);
    
}


