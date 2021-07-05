// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.ErrorCorrection;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    
    
    // NB: These tests need to be generalized to allow for unit testing CSS
    //     codes as well. Since the recovery functions look different for CSS
    //     codes, we must test the Steane code more manually.
    operation QeccTestCaseImpl (code : QECC, nScratch : Int, fn : RecoveryFn, error : (Qubit[] => Unit), data : Qubit[]) : Unit {
        
        let (encode, decode, syndMeas) = code!;
        
        using (scratch = Qubit[nScratch]) {
            let logicalRegister = encode!(data, scratch);
            
            // Cause an error.
            error(logicalRegister!);
            Recover(code, fn, logicalRegister);
            let (decodedData, decodedScratch) = decode!(logicalRegister);
            ApplyToEach(Reset, decodedScratch);
        }
    }
    
    
    function QeccTestCase (code : QECC, nScratch : Int, fn : RecoveryFn, error : (Qubit[] => Unit)) : (Qubit[] => Unit) {
        
        return QeccTestCaseImpl(code, nScratch, fn, error, _);
    }
    
    
    operation AssertCodeCorrectsErrorImpl (code : QECC, nLogical : Int, nScratch : Int, fn : RecoveryFn, error : (Qubit[] => Unit)) : Unit {
        
        AssertOperationsEqualReferenced(nLogical, QeccTestCase(code, nScratch, fn, error), NoOp<Qubit[]>);
    }
    
    
    /// # Remarks
    /// This is a function which curries over all but the error to be applied,
    /// and does not explicitly refer to qubits in any way.
    /// Thus, the result of evaluating this function is an operation that can
    /// be passed to ApplyToEach<(Qubit[] => ())> in order to test a *collection* of
    /// errors in a compact way.
    function AssertCodeCorrectsError (code : QECC, nLogical : Int, nScratch : Int, fn : RecoveryFn) : ((Qubit[] => Unit) => Unit) {
        
        return AssertCodeCorrectsErrorImpl(code, nLogical, nScratch, fn, _);
    }
    
    
    /// # Summary
    /// Ensures that the bit flip code can correct a single arbitrary
    /// bit-flip ($X$) error.
    operation BitFlipTest () : Unit {
        
        let code = BitFlipCode();
        let fn = BitFlipRecoveryFn();
        let errors = Mapped(CurriedOp(ApplyPauli), [[PauliX, PauliI, PauliI], [PauliI, PauliX, PauliI], [PauliI, PauliI, PauliX]]);
        let assertionGenerator = AssertCodeCorrectsError(code, 1, 2, fn);
        assertionGenerator(NoOp<Qubit[]>);
        ApplyToEach(assertionGenerator, errors);
    }
    
    
    /// # Summary
    /// Ensures that the 5-qubit perfect code can correct an arbitrary
    /// single-qubit error.
    operation FiveQubitCodeTest () : Unit {
        
        let code = FiveQubitCode();
        let fn = FiveQubitCodeRecoveryFn();
        let assertionGenerator = AssertCodeCorrectsError(code, 1, 4, fn);
        let errors = Mapped(CurriedOp(ApplyPauli), WeightOnePaulis(5));
        assertionGenerator(NoOp<Qubit[]>);
        ApplyToEach(assertionGenerator, errors);
    }
    
    
    // TODO: split this test up into several smaller tests.
    operation FiveQubitTediousTest () : Unit {
        
        let s = SyndromeMeasOp(MeasureStabilizerGenerators([[PauliX, PauliZ, PauliZ, PauliX, PauliI], [PauliI, PauliX, PauliZ, PauliZ, PauliX], [PauliX, PauliI, PauliX, PauliZ, PauliZ], [PauliZ, PauliX, PauliI, PauliX, PauliZ]], _, MeasureWithScratch));
        
        using (anc = Qubit[6]) {
            Ry(PI() / 2.5, anc[0]);
            FiveQubitCodeEncoderImpl([anc[0]], anc[1 .. 4]);
            let m = anc[5];
            mutable n = 0;
            H(m);
            Controlled X([m], anc[0]);
            Controlled Z([m], anc[1]);
            Controlled Z([m], anc[2]);
            Controlled X([m], anc[3]);
            H(m);
            AssertQubit(Zero, m);
            
            if (M(m) == One) {
                set n = n + 1;
                X(m);
            }
            
            H(m);
            Controlled X([m], anc[1]);
            Controlled Z([m], anc[2]);
            Controlled Z([m], anc[3]);
            Controlled X([m], anc[4]);
            H(m);
            
            if (M(m) == One) {
                set n = n + 2;
                X(m);
            }
            
            H(m);
            Controlled X([m], anc[2]);
            Controlled Z([m], anc[3]);
            Controlled Z([m], anc[4]);
            Controlled X([m], anc[0]);
            H(m);
            
            if (M(m) == One) {
                set n = n + 4;
                X(m);
            }
            
            H(m);
            Controlled X([m], anc[3]);
            Controlled Z([m], anc[4]);
            Controlled Z([m], anc[0]);
            Controlled X([m], anc[1]);
            H(m);
            
            if (M(m) == One) {
                set n = n + 8;
                X(m);
            }
            
            EqualityFactI(n, 0, $"syndrome failure");
            
            // Now testing MeasureWithScratch
            if (MeasureWithScratch([PauliX, PauliZ, PauliZ, PauliX, PauliI], anc[0 .. 4]) == One) {
                fail $"stabilizer 1 fail";
            }
            
            if (MeasureWithScratch([PauliI, PauliX, PauliZ, PauliZ, PauliX], anc[0 .. 4]) == One) {
                fail $"stabilizer 2 fail";
            }
            
            if (MeasureWithScratch([PauliX, PauliI, PauliX, PauliZ, PauliZ], anc[0 .. 4]) == One) {
                fail $"stabilizer 3 fail";
            }
            
            if (MeasureWithScratch([PauliZ, PauliX, PauliI, PauliX, PauliZ], anc[0 .. 4]) == One) {
                fail $"stabilizer 4 fail";
            }
            
            ResetAll(anc);
        }
    }
    
    
    operation FiveQubitTest () : Unit {
        
        let s = SyndromeMeasOp(MeasureStabilizerGenerators([[PauliX, PauliZ, PauliZ, PauliX, PauliI], [PauliI, PauliX, PauliZ, PauliZ, PauliX], [PauliX, PauliI, PauliX, PauliZ, PauliZ], [PauliZ, PauliX, PauliI, PauliX, PauliZ]], _, MeasureWithScratch));
        
        // TODO: split this test up into several smaller tests.
        using (anc = Qubit[5]) {
            
            // let's start with an arbitrary logical state.
            Ry(PI() / 2.5, anc[0]);
            FiveQubitCodeEncoderImpl([anc[0]], anc[1 .. 4]);
            let syn = s!(LogicalRegister(anc));
            let a = ResultArrayAsInt(syn!);
            EqualityFactI(a, 0, $"syndrome failure");
            let (encode, decode, syndMeas) = (FiveQubitCode())!;
            let recovery = FiveQubitCodeRecoveryFn();
            
            for (idx in 0 .. 4) {
                X(anc[idx]);
                let syndrome = syndMeas!(LogicalRegister(anc));
                let recoveryOp = recovery!(syndrome);
                ApplyPauli(recoveryOp, anc);
                let ans = ResultArrayAsInt((syndMeas!(LogicalRegister(anc)))!);
                EqualityFactI(ans, 0, $"Correction failure");
            }
            
            for (idx in 0 .. 4) {
                Y(anc[idx]);
                let syndrome = syndMeas!(LogicalRegister(anc));
                let recoveryOp = recovery!(syndrome);
                ApplyPauli(recoveryOp, anc);
                let ans = ResultArrayAsInt((syndMeas!(LogicalRegister(anc)))!);
                EqualityFactI(ans, 0, $"Correction failure");
            }
            
            for (idx in 0 .. 4) {
                Z(anc[idx]);
                let syndrome = syndMeas!(LogicalRegister(anc));
                let recoveryOp = recovery!(syndrome);
                ApplyPauli(recoveryOp, anc);
                let ans = ResultArrayAsInt((syndMeas!(LogicalRegister(anc)))!);
                EqualityFactI(ans, 0, $"Correction failure");
            }
            
            ResetAll(anc);
        }
    }
    
    
    operation SteaneCodeEncoderTest () : Unit {
        
        using (aux = Qubit[7]) {
            SteaneCodeEncoderImpl(aux[0 .. 0], aux[1 .. 6]);
            
            if (MeasureWithScratch([PauliX, PauliI, PauliX, PauliI, PauliX, PauliI, PauliX], aux[0 .. 6]) == One) {
                fail $"Steane code first X stabilizer";
            }
            
            if (MeasureWithScratch([PauliI, PauliX, PauliX, PauliI, PauliI, PauliX, PauliX], aux[0 .. 6]) == One) {
                fail $"Steane code second X stabilizer";
            }
            
            if (MeasureWithScratch([PauliI, PauliI, PauliI, PauliX, PauliX, PauliX, PauliX], aux[0 .. 6]) == One) {
                fail $"Steane code third X stabilizer";
            }
            
            if (MeasureWithScratch([PauliZ, PauliI, PauliZ, PauliI, PauliZ, PauliI, PauliZ], aux[0 .. 6]) == One) {
                fail $"Steane code first Z stabilizer";
            }
            
            if (MeasureWithScratch([PauliI, PauliZ, PauliZ, PauliI, PauliI, PauliZ, PauliZ], aux[0 .. 6]) == One) {
                fail $"Steane code second Z stabilizer";
            }
            
            if (MeasureWithScratch([PauliI, PauliI, PauliI, PauliZ, PauliZ, PauliZ, PauliZ], aux[0 .. 6]) == One) {
                fail $"Steane code third Z stabilizer";
            }
            
            ResetAll(aux);
        }
    }
    
    
    operation Pi4YInjectionTest () : Unit {
        
        using (anc = Qubit[2]) {
            
            // magic state in anc[1]
            Ry(PI() / 4.0, anc[1]);
            let expected = ApplyToEachA(Ry(PI() / 4.0, _), _);
            let actual = ApplyToEach(InjectPi4YRotation(_, anc[1]), _);
            AssertOperationsEqualReferenced(1, actual, expected);
            
            // NB: we explicitly do not reset the
            //     qubit containing the magic state,
            //     so as to test whether the injection
            //     correctly reset for us.
            Assert([PauliZ], [anc[1]], Zero, $"Magic state was not reset to |0〉.");
            Reset(anc[0]);
        }
    }
    
    
    operation Pi4YInjectionAdjointTest () : Unit {
        
        using (anc = Qubit[2]) {
            
            // magic state in anc[1]
            Ry(PI() / 4.0, anc[1]);
            let expected = ApplyToEachA(Ry(-PI() / 4.0, _), _);
            let actual = ApplyToEach(Adjoint InjectPi4YRotation(_, anc[1]), _);
            AssertOperationsEqualReferenced(1, actual, expected);
            
            // NB: we explicitly do not reset the
            //     qubit containing the magic state,
            //     so as to test whether the injection
            //     correctly reset for us.
            Assert([PauliZ], [anc[1]], Zero, $"Magic state was not reset to |0〉.");
            Reset(anc[0]);
        }
    }
    
    
    /// # Summary
    /// Applies logical operators before and after the encoding circuit,
    /// that as a whole acts as identity.
    operation KDLogicalOperatorTest () : Unit {
        
        using (anc = Qubit[7]) {
            X(anc[0]);
            SteaneCodeEncoderImpl(anc[0 .. 0], anc[1 .. 6]);
            
            // The logical qubit here is in One
            X(anc[0]);
            X(anc[1]);
            X(anc[2]);
            
            // The logical qubit here is in Zero
            Z(anc[1]);
            Z(anc[3]);
            Z(anc[5]);
            
            // Z logical operator does nothing.
            let (logicalQubit, xsyn, zsyn) = _ExtractLogicalQubitFromSteaneCode(LogicalRegister(anc));
            
            // The logical qubit must be in Zero
            EqualityFactI(xsyn, -1, $"X syndrome detected!");
            EqualityFactI(zsyn, -1, $"Z syndrome detected!");
            AssertQubit(Zero, anc[0]);
            ResetAll(anc);
        }
    }
    
    
    operation KDSyndromeTest () : Unit {
        
        using (anc = Qubit[7]) {
            
            for (idx in 0 .. 6) {
                ResetAll(anc);
                SteaneCodeEncoderImpl(anc[0 .. 0], anc[1 .. 6]);
                Z(anc[idx]);
                let (logiQ, xsyn, zsyn) = _ExtractLogicalQubitFromSteaneCode(LogicalRegister(anc));
                EqualityFactI(idx, xsyn, $"wrong X syndrome");
                ResetAll(anc);
                SteaneCodeEncoderImpl(anc[0 .. 0], anc[1 .. 6]);
                X(anc[idx]);
                let (logiQ2, xsyn2, zsyn2) = _ExtractLogicalQubitFromSteaneCode(LogicalRegister(anc));
                EqualityFactI(idx, zsyn2, $"wrong Z syndrome");
            }
            
            ResetAll(anc);
        }
    }
    
    
    operation KnillDistillationNoErrorTest () : Unit {
        
        using (register = Qubit[15]) {
            
            // Prepare the perfect magic states.
            ApplyToEach(Ry(PI() / 4.0, _), register);
            let accept = KnillDistill(register);
            Ry(-PI() / 4.0, register[0]);
            EqualityFactB(true, accept, $"Distillation failure");
            ApplyToEach(AssertQubit(Zero, _), register);
            // NB: no need to reset, we just asserted everything
            //     was returned to |0〉.
        }
    }
    
    
    /// # Summary
    /// Tests if the distillation routine works as intended.
    /// This protocol is supposed to catch any weight 2 errors
    /// on the input magic states, assuming perfect Cliffords.
    /// Here we do not attempt to correct detected errors,
    /// since corrections would make the output magic state
    /// less accurate, compared to post-selection on zero syndrome.
    operation KDTest () : Unit {
        
        using (rm = Qubit[15]) {
            ApplyToEach(Ry(PI() / 4.0, _), rm);
            let acc = KnillDistill(rm);
            
            // Check that the rough magic states were
            // successfully reset to |0〉.
            ApplyToEach(AssertQubit(Zero, _), Rest(rm));
            Ry(-PI() / 4.0, rm[0]);
            EqualityFactB(true, acc, $"Distillation failure");
            AssertQubit(Zero, rm[0]);
            
            // Cases where a single magic state is wrong
            for (idx in 0 .. 14) {
                ResetAll(rm);
                ApplyToEach(Ry(PI() / 4.0, _), rm);
                Y(rm[idx]);
                let acc1 = KnillDistill(rm);
                
                // Check that the rough magic states were
                // successfully reset to |0〉.
                ApplyToEach(AssertQubit(Zero, _), Rest(rm));
                EqualityFactB(false, acc1, $"Distillation missed an error");
            }
            
            // Cases where two magic states are wrong
            for (idxFirst in 0 .. 13) {
                
                for (idxSecond in idxFirst + 1 .. 14) {
                    ResetAll(rm);
                    ApplyToEach(Ry(PI() / 4.0, _), rm);
                    Y(rm[idxFirst]);
                    Y(rm[idxSecond]);
                    let acc1 = KnillDistill(rm);
                    
                    // Check that the rough magic states were
                    // successfully reset to |0〉.
                    ApplyToEach(AssertQubit(Zero, _), Rest(rm));
                    EqualityFactB(false, acc1, $"Distillation missed a pair error");
                }
            }
            
            ResetAll(rm);
        }
    }
    
    
    operation CSSTestCaseImpl (code : CSS, nScratch : Int, fnX : RecoveryFn, fnZ : RecoveryFn, error : (Qubit[] => Unit), data : Qubit[]) : Unit {
        
        let (encode, decode, syndMeasX, syndMeasZ) = code!;
        
        using (scratch = Qubit[nScratch]) {
            let logicalRegister = encode!(data, scratch);
            
            // Cause an error.
            Message($"Applying error {error}.");
            error(logicalRegister!);
            RecoverCSS(code, fnX, fnZ, logicalRegister);
            let (decodedData, decodedScratch) = decode!(logicalRegister);
            ApplyToEach(Reset, decodedScratch);
        }
    }
    
    
    function CSSTestCase (code : CSS, nScratch : Int, fnX : RecoveryFn, fnZ : RecoveryFn, error : (Qubit[] => Unit)) : (Qubit[] => Unit) {
        
        return CSSTestCaseImpl(code, nScratch, fnX, fnZ, error, _);
    }
    
    
    operation AssertCSSCodeCorrectsErrorImpl (code : CSS, nLogical : Int, nScratch : Int, fnX : RecoveryFn, fnZ : RecoveryFn, error : (Qubit[] => Unit)) : Unit {
        AssertOperationsEqualReferenced(nLogical, CSSTestCase(code, nScratch, fnX, fnZ, error), NoOp<Qubit[]>);
    }
    
    
    function AssertCSSCodeCorrectsError (code : CSS, nLogical : Int, nScratch : Int, fnX : RecoveryFn, fnZ : RecoveryFn) : ((Qubit[] => Unit) => Unit) {
        
        return AssertCSSCodeCorrectsErrorImpl(code, nLogical, nScratch, fnX, fnZ, _);
    }
    
    
    /// # Summary
    /// Ensures that the 7-qubit Steane code can correct an arbitrary
    /// single-qubit error.
    operation SteaneCodeTest () : Unit {
        
        let code = SteaneCode();
        let (fnX, fnZ) = SteaneCodeRecoveryFns();
        let assertionGenerator = AssertCSSCodeCorrectsError(code, 1, 6, fnX, fnZ);
        let errors = Mapped(CurriedOp(ApplyPauli), WeightOnePaulis(7));
        assertionGenerator(NoOp<Qubit[]>);
        ApplyToEach(assertionGenerator, errors);
    }
    
}


