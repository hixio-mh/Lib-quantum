// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.AmplitudeAmplification;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Math;

    ///Here we consider the smallest example of amplitude amplification
    ///Suppose we have a single-qubit oracle that prepares the state
    /// O |0> = \lambda |1> + \sqrt{1-|\lambda|^2} |0>
    /// The goal is to amplify the |1> state
    /// We can do this either by synthesizing the reflection about the start and target states ourselves,
    /// We can also do it by passing the oracle for state preparation
    operation ExampleStatePrepImpl (lambda : Double, idxFlagQubit : Int, qubitStart : Qubit[]) : Unit is Adj + Ctl {
        let rotAngle = 2.0 * ArcSin(lambda);
        Ry(rotAngle, qubitStart[idxFlagQubit]);
    }
    
    
    function ExampleStatePrep (lambda : Double) : StateOracle {
        
        return StateOracle(ExampleStatePrepImpl(lambda, _, _));
    }
    
    
    /// In this minimal example, there are no system qubits, only a single flag qubit.
    /// ExampleStatePrep is already of type  StateOracle, so we call
    /// AmpAmpByOracle(iterations: Int, stateOracle : StateOracle, idxFlagQubit : Int startQubits: Qubit[]) : ()
    operation AmpAmpByOracleTest () : Unit {
        
        using (qubits = Qubit[1]) {
            ResetAll(qubits);
            
            for (nIterations in 0 .. 5) {
                
                for (idx in 1 .. 20) {
                    let lambda = IntAsDouble(idx) / 20.0;
                    let rotAngle = ArcSin(lambda);
                    let idxFlag = 0;
                    let startQubits = qubits;
                    let stateOracle = ExampleStatePrep(lambda);
                    (AmpAmpByOracle(nIterations, stateOracle, idxFlag))(startQubits);
                    let successAmplitude = Sin(IntAsDouble(2 * nIterations + 1) * rotAngle);
                    let successProbability = successAmplitude * successAmplitude;
                    AssertProb([PauliZ], [startQubits[idxFlag]], One, successProbability, $"Error: Success probability does not match theory", 1E-10);
                    ResetAll(qubits);
                }
            }
        }
    }
    
    
    operation AmpAmpObliviousByOraclePhasesTest () : Unit {
        
        using (qubits = Qubit[1]) {
            ResetAll(qubits);
            
            for (nIterations in 0 .. 5) {
                let phases = AmpAmpPhasesStandard(nIterations);
                
                for (idx in 0 .. 20) {
                    let rotAngle = (IntAsDouble(idx) * PI()) / 20.0;
                    let idxFlag = 0;
                    let ancillaRegister = qubits;
                    let systemRegister = new Qubit[0];
                    let ancillaOracle = DeterministicStateOracle(Exp([PauliY], rotAngle * 0.5, _));
                    let signalOracle = ObliviousOracle(NoOp<(Qubit[], Qubit[])>(_, _));
                    (AmpAmpObliviousByOraclePhases(phases, ancillaOracle, signalOracle, idxFlag))(ancillaRegister, systemRegister);
                    let successAmplitude = Sin((IntAsDouble(2 * nIterations + 1) * rotAngle) * 0.5);
                    let successProbability = successAmplitude * successAmplitude;
                    AssertProb([PauliZ], [ancillaRegister[idxFlag]], One, successProbability, $"Error: Success probability does not match theory", 1E-10);
                    ResetAll(qubits);
                }
            }
        }
    }
    
    
    operation AmpAmpTargetStateReflectionOracleTest () : Unit {
        
        using (qubits = Qubit[1]) {
            ResetAll(qubits);
            
            for (idx in 0 .. 20) {
                let rotangle = (IntAsDouble(idx) * PI()) / 20.0;
                let targetStateReflection = TargetStateReflectionOracle(0);
                let success = Cos(0.5 * rotangle) * Cos(0.5 * rotangle);
                H(qubits[0]);
                targetStateReflection!(rotangle, qubits);
                AssertProb([PauliX], qubits, Zero, success, $"Error: Success probability does not match theory", 1E-10);
                ResetAll(qubits);
            }
        }
    }
    
}


