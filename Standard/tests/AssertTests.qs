// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;


    // This file contains very simple tests that should trivially pass
    // with the intent of testing the assert and testing harness mechanisms themselves.
    operation EmptyTest () : Unit { }

    operation PreparationTest () : Unit {
        using (qubit = Qubit()) {
            AssertProb([PauliZ], [qubit], Zero, 1.0, $"Freshly prepared qubit was not in |0〉 state.", 1E-10);
        }
    }

    operation OperationTestShouldFail () : Unit {
        fail $"OK";
    }

    function FunctionTestShouldFail () : Unit {
        fail $"OK";
    }

    function AssertEqualTestShouldFail () : Unit {
        NearEqualityFact(1.0, 0.0);
    }
    
    
    function AssertBoolArrayEqualTestShouldFail () : Unit {
        
        AllEqualityFactB([true, false], [false, true], $"OK");
    }
    
    
    function AssertBoolEqualTestShouldFail () : Unit {
        EqualityFactB(true, false, $"OK");
    }
    
    
    function EqualityFactRTestShouldFail () : Unit {
        EqualityFactR(Zero, One, $"OK");
    }
    
    
    function EqualityFactITestShouldFail () : Unit {
        
        EqualityFactI(12, 42, $"OK");
    }
    
    
    /// # Summary
    /// Tests whether common built-in operations are self adjoint.
    /// These tests are already performed in Solid itself, such that
    /// this operation tests whether we can reproduce that using our
    /// operation equality assertions.
    operation SelfAdjointOperationsTest () : Unit {
        for (op in [I, X, Y, Z, H]) {
            AssertOperationsEqualReferenced(3, ApplyToEach(op, _), ApplyToEachA(op, _));
        }
    }
    
    
    /// # Summary
    /// Performs the same test as SelfAdjointOperationsTest,
    /// but using Bound to gather the self-adjoint operations.
    ///
    /// # Remarks
    /// Marked as ex-fail due to known issues with Bound.
    operation BindSelfAdjointOperationsTestExFail () : Unit {
        for (op in [I, X, Y, Z, H]) {
            let arr = [op, Adjoint op];
            let bound = BoundCA(arr);
            AssertOperationsEqualReferenced(3, ApplyToEachCA(BoundCA(arr), _), ApplyToEachA(I, _));
        }
    }
    
    
    operation AssertProbIntTest () : Unit {
        
        let theta = 0.123;
        let prob = 0.015052858190174602;
        let tolerance = 1E-09;
        
        using (qubits = Qubit[4]) {
            X(qubits[0]);
            X(qubits[2]);
            Exp([PauliX], theta, [qubits[3]]);
            AssertProbInt(5, 1.0 - prob, LittleEndian(qubits), tolerance);
            AssertProbInt(13, prob, LittleEndian(qubits), tolerance);
            ResetAll(qubits);
        }
    }
    
    
    operation AssertPhaseTest () : Unit {
        
        let phase = 0.456;
        let tolerance = 1E-09;
        
        using (qubits = Qubit[1]) {
            H(qubits[0]);
            Exp([PauliZ], phase, qubits);
            AssertPhase(phase, qubits[0], tolerance);
            ResetAll(qubits);
        }
    }
    
}


