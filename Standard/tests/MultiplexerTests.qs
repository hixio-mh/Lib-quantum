// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;

    operation MultiplexZTestHelper (coefficients : Double[], multiplexerControl : LittleEndian, additionalControl : Qubit[], target : Qubit, tolerance : Double) : Unit {
        let nCoefficients = Length(coefficients);
        let nQubits = (Length(multiplexerControl!) + Length(additionalControl)) + 1;

        // Measure phase shift due to Exp^PauliZ rotation.
        H(target);

        // Generate uniform superposition over control inputs.
        ApplyToEachCA(H, multiplexerControl! + additionalControl);

        // For deterministic test of particular number state `idx', we could use the following
        //let bits = Reversed(IntAsBoolArray (idx, Length(multiplexerControl)));
        //for(idxBits in IndexRange(bits)){
        //    if(bits[idxBits]){
        //        X(multiplexerControl[idxBits]);
        //    }
        //}
        
        // Apply MultiplexZ circuit
        if (Length(additionalControl) == 0) {
            MultiplexZ(coefficients, multiplexerControl, target);
        }
        elif (Length(additionalControl) == 1) {
            Controlled (MultiplexZ(coefficients, multiplexerControl, _))(additionalControl, target);
        }
        else {
            fail $"Test for more than one control on MultiplexZ not implemented.";
        }
        
        // Sample from control registers and check phase using AssertProb.
        let multiplexerControlInteger = MeasureInteger(multiplexerControl);
        let additionalControlResults = ForEach(MResetZ, additionalControl);
        
        if (Length(additionalControlResults) == 1 and additionalControlResults[0] == Zero) {
            
            // Case where Identity operation is performed.
            Message($"Controlled MultiplexZ test. coefficient {multiplexerControlInteger} of {nCoefficients-1}.");
            AssertPhase(0.0, target, tolerance);
        }
        else {
            mutable coeff = 0.0;
            
            if (multiplexerControlInteger < nCoefficients) {
                set coeff = coefficients[multiplexerControlInteger];
            }
            
            if (Length(additionalControl) == 0) {
                Message($"MultiplexZ test. Qubits: {nQubits}; coefficient {multiplexerControlInteger} of {nCoefficients-1}.");
                AssertPhase(coeff, target, tolerance);
            }
            else {
                Message($"Controlled MultiplexZ test. Qubits: {nQubits}; coefficient {multiplexerControlInteger} of {nCoefficients-1}.");
                AssertPhase(coeff, target, tolerance);
            }
            //AssertPhase(coeff, target, tolerance);
        }
        
        // Note that MeasureInteger has the effect of resetting its target, so
        // that we only need to ret target here.
        Reset(target);
    }
    
    
    operation MultiplexZTest () : Unit {
        
        let maxQubits = 6;
        
        // Loop over controlled & un-controlled Multiplexer
        for (nAdditionalControl in 0 .. 1) {
            
            // Loop over number of Multiplexer qubits
            for (nMultiplexerControl in 0 .. maxQubits - 2) {
                
                //Loop over some number of missing coefficients
                for (missingCoefficients in 0 .. nMultiplexerControl) {
                    
                    // Generate some coefficients
                    let maxCoefficients = 2 ^ nMultiplexerControl;
                    let nCoefficients = maxCoefficients - missingCoefficients;
                    mutable coefficients = new Double[nCoefficients];
                    
                    for (idx in IndexRange(coefficients)) {
                        set coefficients w/= idx <- (1.0 * IntAsDouble(idx + 1)) * 0.2;
                    }
                    
                    // Allocate qubits
                    using (qubits = Qubit[(nMultiplexerControl + 1) + nAdditionalControl]) {
                        let multiplexerControl = LittleEndian(qubits[0 .. nMultiplexerControl - 1]);
                        let target = qubits[nMultiplexerControl];
                        mutable additionalControl = new Qubit[1];
                        
                        if (nAdditionalControl == 0) {
                            set additionalControl = new Qubit[0];
                        }
                        elif (nAdditionalControl == 1) {
                            set additionalControl = [qubits[Length(qubits) - 1]];
                        }
                        
                        let tolerance = 1E-09;
                        
                        // Repeat test some number of times
                        for (idxCoeff in 0 .. maxCoefficients / 2) {
                            MultiplexZTestHelper(coefficients, multiplexerControl, additionalControl, target, tolerance);
                        }
                    }
                }
            }
        }
    }
    
    
    operation ApplyDiagonalUnitaryTestHelper (coefficients : Double[], qubits : LittleEndian, tolerance : Double) : Unit {
        
        let nCoefficients = Length(coefficients);
        let nQubits = Length(qubits!);
        
        // The absolute phase of a diagonal unitary can only be characterized
        // using a controlled operation.
        using (control = Qubit()) {
            
            for (idxCoeff in IndexRange(coefficients)) {
                H(control);
                
                //for(idxQubit in 0..nQubits-1){
                //    H(qubits[idxQubit]);
                //}
                ApplyXorInPlace(idxCoeff, qubits);
                
                // Apply MultiplexZ circuit
                Controlled (ApplyDiagonalUnitary(coefficients, _))([control], qubits);
                Message($"ApplyDiagonalUnitary test. Qubits: {nQubits}; coefficient {idxCoeff} of {nCoefficients-1}.");
                AssertPhase(-0.5 * coefficients[idxCoeff], control, tolerance);
                Reset(control);
                ResetAll(qubits!);
            }
        }
    }
    
    
    operation ApplyDiagonalUnitaryTest () : Unit {
        
        let maxQubits = 4;
        
        for (nqubits in 1 .. maxQubits) {
            
            // Generate some coefficients
            let maxCoefficients = 2 ^ nqubits;
            
            //let nCoefficients = maxCoefficients - missingCoefficients;
            mutable coefficients = new Double[maxCoefficients];
            
            for (idx in IndexRange(coefficients)) {
                set coefficients w/= idx <- (1.0 * IntAsDouble(idx + 1)) * 0.3;
            }
            
            // Allocate qubits
            using (qubits = Qubit[nqubits]) {
                let tolerance = 1E-09;
                ApplyDiagonalUnitaryTestHelper(coefficients, LittleEndian(qubits), tolerance);
            }
        }
    }
    
    
    function MultiplexOperationsTestUnitary (nStates : Int, idx : Int) : (Qubit => Unit is Adj + Ctl)[] {
        
        mutable unitaries = new (Qubit => Unit is Adj + Ctl)[nStates];
        
        for (idxUnitary in 0 .. nStates - 1) {
            set unitaries w/= idxUnitary <- I;
        }
        
        set unitaries w/= idx <- X;
        return unitaries;
    }
    
    
    operation MultiplexOperationsTestHelper (idxTest : Int, idxTarget : Int, nQubits : Int, idxControl : Int, nControls : Int) : Result {
        
        let unitaries = MultiplexOperationsTestUnitary(2 ^ nQubits, idxTarget);
        
        // LittleEndian
        let bits = IntAsBoolArray(idxTest, nQubits);
        let controlBits = IntAsBoolArray(idxControl, nControls);
        mutable result = Zero;
        
        if (nControls == 0) {
            
            using (target = Qubit[1]) {
                
                using (index = Qubit[nQubits]) {
                    
                    for (idxBits in IndexRange(bits)) {
                        
                        if (bits[idxBits]) {
                            X(index[idxBits]);
                        }
                    }
                    
                    MultiplexOperations(unitaries, LittleEndian(index), target[0]);
                    set result = M(target[0]);
                    ResetAll(target);
                    ResetAll(index);
                }
            }
        }
        else {
            
            using (control = Qubit[nControls]) {
                
                using (target = Qubit[1]) {
                    
                    if (nQubits == 0) {
                        let index = new Qubit[0];
                        
                        for (idxControlBits in IndexRange(controlBits)) {
                            
                            if (controlBits[idxControlBits]) {
                                X(control[idxControlBits]);
                            }
                        }
                        
                        Controlled (MultiplexOperations(unitaries, LittleEndian(index), _))(control, target[0]);
                        set result = M(target[0]);
                        ResetAll(target);
                        ResetAll(control);
                    }
                    else {
                        
                        using (index = Qubit[nQubits]) {
                            
                            for (idxBits in IndexRange(bits)) {
                                
                                if (bits[idxBits]) {
                                    X(index[idxBits]);
                                }
                            }
                            
                            for (idxControlBits in IndexRange(controlBits)) {
                                
                                if (controlBits[idxControlBits]) {
                                    X(control[idxControlBits]);
                                }
                            }
                            
                            Controlled (MultiplexOperations(unitaries, LittleEndian(index), _))(control, target[0]);
                            set result = M(target[0]);
                            ResetAll(target);
                            ResetAll(index);
                            ResetAll(control);
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
    
    function MultiplexOperationsTestMissingUnitary (nStates : Int, nUnitaries : Int) : (Qubit => Unit is Adj + Ctl)[] {
        
        mutable unitaries = new (Qubit => Unit is Adj + Ctl)[nStates];
        
        for (idxUnitary in 0 .. nUnitaries - 1) {
            set unitaries w/= idxUnitary <- X;
        }
        
        for (idxUnitary in nUnitaries .. nStates - 1) {
            set unitaries w/= idxUnitary <- I;
        }
        
        return unitaries;
    }
    
    
    operation MultiplexOperationsTestMissingUnitaryHelper (idxTest : Int, nUnitaries : Int, nQubits : Int) : Result {
        
        let unitaries = MultiplexOperationsTestMissingUnitary(2 ^ nQubits, nUnitaries);
        
        // LittleEndian
        let bits = IntAsBoolArray(idxTest, nQubits);
        mutable result = Zero;
        
        using (target = Qubit[1]) {
            
            if (nQubits == 0) {
                let index = new Qubit[0];
                
                for (idxBits in IndexRange(bits)) {
                    
                    if (bits[idxBits]) {
                        X(index[idxBits]);
                    }
                }
                
                MultiplexOperations(unitaries, LittleEndian(index), target[0]);
                set result = M(target[0]);
                ResetAll(target);
            }
            else {
                
                using (index = Qubit[nQubits]) {
                    
                    for (idxBits in IndexRange(bits)) {
                        
                        if (bits[idxBits]) {
                            X(index[idxBits]);
                        }
                    }
                    
                    MultiplexOperations(unitaries, LittleEndian(index), target[0]);
                    set result = M(target[0]);
                    ResetAll(target);
                    ResetAll(index);
                }
            }
        }
        
        return result;
    }
    
    
    operation MultiplexOperationsTest () : Unit {
        
        mutable result = Zero;
        
        // Test version with fewer unitaries than states
        // Test uncontrolled version
        for (missingTestQubits in 1 .. 3) {
            
            for (nUnitaries in 0 .. 2 ^ missingTestQubits) {
                
                for (idxTest in 0 .. 2 ^ missingTestQubits - 1) {
                    set result = MultiplexOperationsTestMissingUnitaryHelper(idxTest, nUnitaries, missingTestQubits);
                    
                    if (result == One) {
                        Message($"MultiplexOperations test with missing unitaries. Qubits: {missingTestQubits}; idxTest {idxTest} of nUnitaries {nUnitaries} result {result}.");
                        
                        if (idxTest >= nUnitaries) {
                            fail $"MultiplexOperations failed.";
                        }
                    }
                    
                    if (result == Zero) {
                        Message($"MultiplexOperations test with missing unitaries. Qubits: {missingTestQubits}; idxTest {idxTest} of nUnitaries {nUnitaries} result {result}.");
                        
                        if (idxTest < nUnitaries) {
                            fail $"MultiplexOperations failed.";
                        }
                    }
                }
            }
        }
        
        let nQubits = 3;
        let nIdxMax = 2 ^ nQubits;
        
        // Test uncontrolled version
        for (idxTarget in 0 .. nIdxMax - 1) {
            
            for (idxTest in 0 .. nIdxMax - 1) {
                set result = MultiplexOperationsTestHelper(idxTest, idxTarget, nQubits, 0, 0);
                
                if (result == One) {
                    Message($"MultiplexOperations test. Qubits: {nQubits}; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                    EqualityFactI(idxTarget, idxTest, $"MultiplexOperations failed.");
                }
            }
        }
        
        // Test Controlled version
        for (idxTarget in 0 .. nIdxMax - 1) {
            
            for (idxTest in 0 .. nIdxMax - 1) {
                set result = MultiplexOperationsTestHelper(idxTest, idxTarget, nQubits, 0, 1);
                
                if (result == One) {
                    Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 0; nControls = 1; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                    EqualityFactI(idxTarget, idxTest, $"MultiplexOperations failed.");
                }
                
                set result = MultiplexOperationsTestHelper(idxTest, idxTarget, nQubits, 1, 1);
                
                if (result == One) {
                    Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 1; nControls = 1; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                    EqualityFactI(idxTarget, idxTest, $"MultiplexOperations failed.");
                }
                
                set result = MultiplexOperationsTestHelper(idxTest, idxTarget, nQubits, 1, 2);
                
                if (result == One) {
                    Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 1; nControls = 2; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                    EqualityFactI(idxTarget, idxTest, $"MultiplexOperations failed.");
                }
                
                set result = MultiplexOperationsTestHelper(idxTest, idxTarget, nQubits, 3, 2);
                
                if (result == One) {
                    Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 3; nControls = 2; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                    EqualityFactI(idxTarget, idxTest, $"MultiplexOperations failed.");
                }
            }
        }
    }

    function MultiplexOperationsFromGeneratorTestUnitary_(nStates: Int, idx: Int, idxX: Int) : (Qubit[] => Unit is Adj + Ctl) {
        if(idx == idxX ){
            return ApplyToEachCA(X,_);
        }
        elif(idx < nStates){
            return ApplyToEachCA(I,_);
        }
        else{
            fail "Index out of range";
        }
    }

    function MultiplexOperationsFromGeneratorTestUnitary(nStates: Int, idx: Int) : (Int, (Int -> (Qubit[] => Unit is Adj + Ctl))) {
        return (nStates, MultiplexOperationsFromGeneratorTestUnitary_(nStates, _, idx));
    }

    operation MultiplexOperationsFromGeneratorTestHelper(idxTest: Int, idxTarget: Int, nQubits: Int, idxControl: Int, nControls: Int) : Result {
        body (...) {
            let unitaries = MultiplexOperationsFromGeneratorTestUnitary(2^nQubits, idxTarget);
    
            // LittleEndian
            let bits = IntAsBoolArray (idxTest, nQubits);
            let controlBits = IntAsBoolArray (idxControl, nControls);

            mutable result = Zero;

            if(nControls == 0){
                using(target = Qubit[1]){
                    using(index = Qubit[nQubits]){
                        for(idxBits in IndexRange(bits)){
                            if(bits[idxBits]){
                                X(index[idxBits]);
                            }
                        }

                        MultiplexOperationsFromGenerator(unitaries, LittleEndian(index), [target[0]]);

                        set result = M(target[0]);
                        ResetAll(target);
                        ResetAll(index);
                    }
                }
            }
        
            else{
                using(control = Qubit[nControls]){
                    using(target = Qubit[1]){
                        if(nQubits == 0){
                            let index = new Qubit[0];
                            for(idxControlBits in IndexRange(controlBits)){
                                if(controlBits[idxControlBits]){
                                    X(control[idxControlBits]);
                                }
                            }

                            Controlled (MultiplexOperationsFromGenerator(unitaries, LittleEndian(index), _))(control, [target[0]]);

                            set result = M(target[0]);
                            ResetAll(target);
                            ResetAll(control);
                        
                        }
                        else{
                            using(index = Qubit[nQubits]){
                                for(idxBits in IndexRange(bits)){
                                    if(bits[idxBits]){
                                        X(index[idxBits]);
                                    }
                                }
                                for(idxControlBits in IndexRange(controlBits)){
                                    if(controlBits[idxControlBits]){
                                        X(control[idxControlBits]);
                                    }
                                }

                                Controlled (MultiplexOperationsFromGenerator(unitaries, LittleEndian(index), _))(control, [target[0]]);

                                set result = M(target[0]);
                                ResetAll(target);
                                ResetAll(index);
                                ResetAll(control);
                            }
                        }
                    }
                }
            }
            return result;
        }
    }

    operation MultiplexOperationsFromGeneratorTest() : Unit{
        body (...) {
            mutable result = Zero;

            let nQubits = 3;
            let nIdxMax = 2^nQubits;

            // Test uncontrolled version
            for(idxTarget in 0..nIdxMax-1){
                for(idxTest in 0..nIdxMax-1){
                    set result = MultiplexOperationsFromGeneratorTestHelper(idxTest, idxTarget, nQubits, 0, 0);
                    if(result == One){
                        Message($"MultiplexOperations test. Qubits: {nQubits}; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                        EqualityFactI(idxTarget, idxTest, "MultiplexOperations failed.");
                    }
                }
            }

            // Test Controlled version
            for(idxTarget in 0..nIdxMax-1){
                for(idxTest in 0..nIdxMax-1){
                    set result = MultiplexOperationsFromGeneratorTestHelper(idxTest, idxTarget, nQubits, 0, 1);
                    if(result == One){
                        Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 0; nControls = 1; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                        EqualityFactI(idxTarget, idxTest, "MultiplexOperations failed.");
                    }

                    set result = MultiplexOperationsFromGeneratorTestHelper(idxTest, idxTarget, nQubits, 1, 1);
                    if(result == One){
                        Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 1; nControls = 1; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                        EqualityFactI(idxTarget, idxTest, "MultiplexOperations failed.");
                    }

                    set result = MultiplexOperationsFromGeneratorTestHelper(idxTest, idxTarget, nQubits, 1, 2);
                    if(result == One){
                        Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 1; nControls = 2; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                        EqualityFactI(idxTarget, idxTest, "MultiplexOperations failed.");
                    }

                    set result = MultiplexOperationsFromGeneratorTestHelper(idxTest, idxTarget, nQubits, 3, 2);
                    if(result == One){
                        Message($"Controlled MultiplexOperations test. Qubits: {nQubits}; idxControl = 3; nControls = 2; idxTest {idxTest} of idxTarget {idxTarget} result {result}.");
                        EqualityFactI(idxTarget, idxTest, "MultiplexOperations failed.");
                    }
                }
            }
        }
    }
    
}


