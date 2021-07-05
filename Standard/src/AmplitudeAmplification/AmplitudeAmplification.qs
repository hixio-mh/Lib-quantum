// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.AmplitudeAmplification {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Oracles;

    /// # Summary
    /// Converts phases specified as single-qubit rotations to phases
    /// specified as partial reflections.
    ///
    /// # Input
    /// ## rotPhases
    /// Array of single-qubit rotations to be converted to partial
    /// reflections.
    ///
    /// # Output
    /// An operation that implements phases specified as partial reflections.
    ///
    /// # References
    /// We use the convention in
    /// - [ *G.H. Low, I. L. Chuang* ](https://arxiv.org/abs/1707.05391)
    /// for relating single-qubit rotation phases to reflection operator phases.
    function AmpAmpRotationToReflectionPhases (rotPhases : RotationPhases) : ReflectionPhases
    {
        let nPhasesRot = Length(rotPhases!);
        let nPhasesRef = (nPhasesRot + 1) / 2;
        
        if (nPhasesRot % 2 == 0)
        {
            fail $"Number of rotations must be odd.";
        }
        
        mutable phasesTarget = new Double[nPhasesRef];
        mutable phasesStart = new Double[nPhasesRef];
        set phasesTarget w/= 0 <- ((rotPhases!)[0] - (rotPhases!)[1]) - PI();
        set phasesStart w/= 0 <- -(rotPhases!)[0] + 0.5 * PI();
        
        for (idxPhases in 1 .. nPhasesRef - 2)
        {
            set phasesTarget w/= idxPhases <- ((rotPhases!)[2 * idxPhases] - (rotPhases!)[2 * idxPhases + 1]) - PI();
            set phasesStart w/= idxPhases <- ((rotPhases!)[2 * idxPhases - 1] - (rotPhases!)[2 * idxPhases]) + PI();
        }
        
        set phasesTarget w/= nPhasesRef - 1 <- (rotPhases!)[2 * nPhasesRef - 2] - 0.5 * PI();
        set phasesStart w/= nPhasesRef - 1 <- ((rotPhases!)[2 * nPhasesRef - 3] - (rotPhases!)[2 * nPhasesRef - 2]) + PI();
        return ReflectionPhases(phasesStart, phasesTarget);
    }
    
    
    /// # Summary
    /// Computes partial reflection phases for standard amplitude
    /// amplification.
    ///
    /// # Input
    /// ## nIterations
    /// Number of amplitude amplification iterations to generate partial
    /// reflection phases for.
    ///
    /// # Output
    /// An operation that implements phases specified as partial reflections
    ///
    /// # Remarks
    /// All phases are $\pi$, except for the first reflection about the start
    /// state and the last reflection about the target state, which are $0$.
    function AmpAmpPhasesStandard (nIterations : Int) : ReflectionPhases
    {
        mutable phasesTarget = new Double[nIterations + 1];
        mutable phasesStart = new Double[nIterations + 1];
        
        for (idxPhases in 0 .. nIterations)
        {
            set phasesTarget w/= idxPhases <- PI();
            set phasesStart w/= idxPhases <- PI();
        }
        
        set phasesTarget w/= nIterations <- 0.0;
        set phasesStart w/= 0 <- 0.0;
        return ReflectionPhases(phasesStart, phasesTarget);
    }
    
    
    // We use the phases in "Fixed-Point Amplitude Amplification with an
    // Optimal Number of Queires" [YoderLowChuang2014]
    // See also "Methodology of composite quantum gates" [LowYoderChuang2016]
    // for phases in the `RotationPhases` format
    
    /// # Summary
    /// Computes partial reflection phases for fixed-point amplitude
    /// amplification.
    ///
    /// # Input
    /// ## nQueries
    /// Number of queries to the state preparation oracle. Must be an odd
    /// integer.
    /// ## successMin
    /// Target minimum success probability.
    ///
    /// # Output
    /// Array of phases that can be used in fixed-point amplitude amplification
    /// quantum algorithm implementation.
    ///
    /// # References
    /// We use the phases in "Fixed-Point Amplitude Amplification with
    /// an Optimal Number of Queries"
    /// - [YoderLowChuang2014](https://arxiv.org/abs/1409.3305)
    /// See also "Methodology of composite quantum gates"
    /// - [LowYoderChuang2016](https://arxiv.org/abs/1603.03996)
    /// for phases in the `RotationPhases` format.
    function AmpAmpPhasesFixedPoint (nQueries : Int, successMin : Double) : ReflectionPhases
    {
        mutable phasesRot = new Double[nQueries];
        let nQueriesDouble = IntAsDouble(nQueries);
        set phasesRot w/= 0 <- 0.0;
        let beta = Cosh((1.0 / nQueriesDouble) * ArcCosh(Sqrt(successMin)));
        
        for (idxPhases in 1 .. nQueries - 1)
        {
            set phasesRot w/= idxPhases <- phasesRot[idxPhases - 1] + 2.0 * ArcTan(Tan((((2.0 * 1.0) * IntAsDouble(idxPhases)) * PI()) / nQueriesDouble) * Sqrt(1.0 - beta * beta));
        }
        
        return AmpAmpRotationToReflectionPhases(RotationPhases(phasesRot));
    }
    
    
    /// # Summary
    /// Oblivious amplitude amplification by specifying partial reflections.
    ///
    /// # Input
    /// ## phases
    /// Phases of partial reflections
    /// ## ancillaReflection
    /// Reflection operator about start state of ancilla register
    /// ## targetStateReflection
    /// Reflection operator about target state of ancilla register
    /// ## signalOracle
    /// Unitary oracle $O$ of type `ObliviousOracle` that acts jointly on the
    /// ancilla and system registers.
    /// ## ancillaRegister
    /// Ancilla register
    /// ## systemRegister
    /// System register
    ///
    /// # Remarks
    /// Given a particular ancilla start state $\ket{\text{start}}\_a$, a
    /// particular ancilla target state $\ket{\text{target}}\_a$, and any
    /// system state $\ket{\psi}\_s$, suppose that
    /// \begin{align}
    /// O\ket{\text{start}}\_a\ket{\psi}\_s= \lambda\ket{\text{target}}\_a U \ket{\psi}\_s + \sqrt{1-|\lambda|^2}\ket{\text{target}^\perp}\_a\cdots
    /// \end{align}
    /// for some unitary $U$.
    /// By a sequence of reflections about the start and target states on the
    /// ancilla register interleaved by applications of `signalOracle` and its
    /// adjoint, the success probability of applying U may be altered.
    ///
    /// In most cases, `ancillaRegister` is initialized in the state $\ket{\text{start}}\_a$.
    ///
    /// # References
    /// See
    /// - [ *D.W. Berry, A.M. Childs, R. Cleve, R. Kothari, R.D. Somma* ](https://arxiv.org/abs/1312.1414)
    /// for the standard version.
    /// See
    /// - [ *G.H. Low, I.L. Chuang* ](https://arxiv.org/abs/1610.06546)
    /// for a generalization to partial reflections.
    operation AmpAmpObliviousByReflectionPhasesImpl (phases : ReflectionPhases, ancillaReflection : ReflectionOracle, targetStateReflection : ReflectionOracle, signalOracle : ObliviousOracle, ancillaRegister : Qubit[], systemRegister : Qubit[]) : Unit
    {
        body (...)
        {
            let (phasesAncilla, phasesTarget) = phases!;
            let nphases = 2 * Length(phasesTarget);
            
            //FailOn(nphases != Length(phasesAncilla), "Phase array lengths not equal.")
            if (phasesAncilla[0] != 0.0)
            {
                ancillaReflection!(phasesAncilla[0], ancillaRegister);
            }
            
            for (idxPhases in 1 .. nphases - 1)
            {
                let idxPhaseAncilla = idxPhases / 2;
                let idxPhaseTarget = idxPhases / 2;
                
                if (idxPhases % 2 == 1)
                {
                    signalOracle!(ancillaRegister, systemRegister);
                    
                    if (phasesTarget[idxPhaseTarget] != 0.0)
                    {
                        targetStateReflection!(phasesTarget[idxPhaseTarget], ancillaRegister);
                    }
                }
                else
                {
                    Adjoint signalOracle!(ancillaRegister, systemRegister);
                    
                    if (phasesAncilla[idxPhaseAncilla] != 0.0)
                    {
                        ancillaReflection!(phasesAncilla[idxPhaseAncilla], ancillaRegister);
                    }
                }
            }
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    /// # Summary
    /// Returns a unitary that implements oblivious amplitude amplification by specifying for partial reflections.
    function AmpAmpObliviousByReflectionPhases (phases : ReflectionPhases, ancillaReflection : ReflectionOracle, targetStateReflection : ReflectionOracle, signalOracle : ObliviousOracle) : ((Qubit[], Qubit[]) => Unit is Adj + Ctl)
    {
        return AmpAmpObliviousByReflectionPhasesImpl(phases, ancillaReflection, targetStateReflection, signalOracle, _, _);
    }
    
    
    /// # Summary
    /// Oblivious amplitude amplification by oracles for partial reflections.
    ///
    /// # Input
    /// ## phases
    /// Phases of partial reflections
    /// ## ancillaOracle
    /// Unitary oracle $A$ that prepares ancilla start state
    /// ## signalOracle
    /// Unitary oracle $O$ of type `ObliviousOracle` that acts jointly on the ancilla and system register
    /// ## idxFlagQubit
    /// Index to single-qubit flag register
    ///
    /// # Output
    /// An operation that implements oblivious amplitude amplification based on partial reflections.
    ///
    /// # Remarks
    /// This imposes stricter conditions on form of the ancilla start and target states than in `AmpAmpObliviousByReflectionPhases`.
    /// It is assumed that $A\ket{0}\_f\ket{0}\_a= \ket{\text{start}}\_{fa}$ prepares the ancilla start state $\ket{\text{start}}\_{fa}$ from the computational basis $\ket{0}\_f\ket{0}$.
    /// It is assumed that the target state is marked by $\ket{1}\_f$.
    /// It is assumed that
    /// \begin{align}
    /// O\ket{\text{start}}\_{fa}\ket{\psi}\_s= \lambda\ket{1}\_f\ket{\text{anything}}\_a\ket{\text{target}}\_s U \ket{\psi}\_s + \sqrt{1-|\lambda|^2}\ket{0}\_f\cdots,
    /// \end{align}
    /// for some unitary $U$.
    function AmpAmpObliviousByOraclePhases (phases : ReflectionPhases, ancillaOracle : DeterministicStateOracle, signalOracle : ObliviousOracle, idxFlagQubit : Int) : ((Qubit[], Qubit[]) => Unit is Adj + Ctl)
    {
        let ancillaReflection = ReflectionStart();
        let targetStateReflection = TargetStateReflectionOracle(idxFlagQubit);
        let oracleObliviousNew = ObliviousOracleFromDeterministicStateOracle(ancillaOracle, signalOracle);
        return AmpAmpObliviousByReflectionPhases(phases, ancillaReflection, targetStateReflection, oracleObliviousNew);
    }
    
    
    /// # Summary
    /// Amplitude amplification by partial reflections.
    ///
    /// # Input
    /// ## phases
    /// Phases of partial reflections
    /// ## startStateReflection
    /// Reflection operator about start state
    /// ## targetStateReflection
    /// Reflection operator about target state
    /// ## startQubits
    /// Qubit register
    ///
    /// # Output
    /// An operation that implements amplitude amplification by partial reflections.
    ///
    /// # Remarks
    /// Amplitude amplification is a special case of oblivious amplitude amplification where there are no system qubits and the oblivious oracle is set to identity.
    /// In most cases, `startQubits` is initialized in the state $\ket{\text{start}}\_1$, which is the $-1$ eigenstate of `startStateReflection`.
    function AmpAmpByReflectionsPhases (phases : ReflectionPhases, startStateReflection : ReflectionOracle, targetStateReflection : ReflectionOracle) : (Qubit[] => Unit is Adj + Ctl)
    {
        // Pass empty qubit array using fact that NoOp does nothing.
        let qubitEmpty = new Qubit[0];
        let signalOracle = ObliviousOracle(NoOp<(Qubit[], Qubit[])>);
        return (AmpAmpObliviousByReflectionPhases(phases, startStateReflection, targetStateReflection, signalOracle))(_, qubitEmpty);
    }
    
    
    /// # Summary
    /// Amplitude amplification by oracles for partial reflections.
    ///
    /// # Input
    /// ## phases
    /// Phases of partial reflections
    /// ## stateOracle
    /// Unitary oracle $A$ that prepares start state
    /// ## idxFlagQubit
    /// Index to flag qubit
    /// ## qubits
    /// Start state register
    ///
    /// # Output
    /// An operation that implements amplitude amplification by oracles that are
    /// implemented by partial reflections.
    ///
    /// # Remarks
    /// This imposes stricter conditions on form of the start and target states than in `AmpAmpByReflectionPhases`.
    /// It is assumed that the target state is marked by $\ket{1}\_f$.
    /// It is assumed that
    /// \begin{align}
    /// A\ket{0}\_{f}\ket{0}\_s= \lambda\ket{1}\_f\ket{\text{target}}\_s + \sqrt{1-|\lambda|^2}\ket{0}\_f\cdots,
    /// \end{align}
    /// In most cases, `flagQubit` and `ancillaRegister` is initialized in the state $\ket{0}\_{f}\ket{0}\_s$.
    function AmpAmpByOraclePhases (phases : ReflectionPhases, stateOracle : StateOracle, idxFlagQubit : Int) : (Qubit[] => Unit is Adj + Ctl)
    {
        let qubitEmpty = new Qubit[0];
        let signalOracle = ObliviousOracle(NoOp<(Qubit[], Qubit[])>);
        let ancillaOracle = DeterministicStateOracleFromStateOracle(idxFlagQubit, stateOracle);
        return (AmpAmpObliviousByOraclePhases(phases, ancillaOracle, signalOracle, idxFlagQubit))(_, qubitEmpty);
    }
    
    
    /// # Summary
    /// Standard Amplitude Amplification algorithm
    ///
    /// # Input
    /// ## nIterations
    /// Number of iterations $n$ of amplitude amplification
    /// ## statePrepOracle
    /// Unitary oracle $A$ that prepares start state
    /// ## idxFlagQubit
    /// Index to flag qubit
    /// ## qubits
    /// Start state register
    ///
    /// # Output
    /// An operation that implements the standard amplitude amplification quantum algorithm
    ///
    /// # Remarks
    /// This is the standard amplitude amplification algorithm obtained by a choice of reflection phases computed by `AmpAmpPhasesStandard`
    /// Assuming that
    /// \begin{align}
    /// A\ket{0}\_{f}\ket{0}\_s= \lambda\ket{1}\_f\ket{\text{target}}\_s + \sqrt{1-|\lambda|^2}\ket{0}\_f\cdots,
    /// \end{align}
    /// this operation prepares the state
    /// \begin{align}
    /// \operatorname{AmpAmpByOracle}\ket{0}\_{f}\ket{0}\_s= \sin((2n+1)\sin^{-1}(\lambda))\ket{1}\_f\ket{\text{target}}\_s + \cdots\ket{0}\_f
    /// \end{align}
    /// In most cases, `flagQubit` and `ancillaRegister` is initialized in the state $\ket{0}\_f\ket{0}\_a$.
    ///
    /// # References
    /// - [ *G. Brassard, P. Hoyer, M. Mosca, A. Tapp* ](https://arxiv.org/abs/quant-ph/0005055)
    function AmpAmpByOracle (nIterations : Int, stateOracle : StateOracle, idxFlagQubit : Int) : (Qubit[] => Unit is Adj + Ctl)
    {
        let phases = AmpAmpPhasesStandard(nIterations);
        return AmpAmpByOraclePhases(phases, stateOracle, idxFlagQubit);
    }
    
    
    /// # Summary
    /// Fixed-Point Amplitude Amplification algorithm
    ///
    /// # Input
    /// ## statePrepOracle
    /// Unitary oracle that prepares the start state.
    /// ## startQubits
    /// Qubit register
    ///
    /// # Remarks
    /// The startQubits must be in the $\ket{0 \cdots 0}$ state. This operation iterates over a number of queries in powers of $2$ until either a maximal number of queries
    /// is reached, or the target state is found.
    operation AmpAmpRUSByOracle (statePrepOracle : StateOracle, startQubits : Qubit[]) : Unit
    {
        // Should be a power of 2
        let queriesMax = 999;
        let successMin = 0.99;
        mutable finished = Zero;
        mutable exponentMax = 0;
        mutable exponentCurrent = 0;
        
        //Complexity: Let \theta = \mathcal{O}(\sqrt{lambda})
        // Number of Measurements = O( Log^2(1/\theta) )
        // Number of Queries = O(1/\theta)
        using (flagQubit = Qubit[1])
        {
            let qubits = flagQubit + startQubits;
            let idxFlagQubit = 0;
            
            repeat
            {
                if (2 ^ exponentMax > queriesMax)
                {
                    fail $"Target state not found. Maximum number of queries exceeded.";
                }
                
                repeat
                {
                    let queries = 2 ^ exponentCurrent;
                    let phases = AmpAmpPhasesFixedPoint(queries, successMin);
                    (AmpAmpByOraclePhases(phases, statePrepOracle, idxFlagQubit))(qubits);
                    set finished = M(flagQubit[0]);
                    set exponentCurrent = exponentCurrent + 1;
                }
                until (finished == One or exponentCurrent > exponentMax)
                fixup
                {
                    // flagQubit is already in Zero for fixup to apply
                    ResetAll(startQubits);
                }
                
                set exponentCurrent = 0;
                set exponentMax = exponentMax + 1;
            }
            until (finished == One)
            fixup
            {
                ResetAll(startQubits);
            }
        }
    }
    
}


