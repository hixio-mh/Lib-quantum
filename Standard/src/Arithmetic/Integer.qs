﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Arithmetic {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Implements a reversible carry gate. Given a carry-in bit encoded in
    /// qubit `carryIn` and two summand bits encoded in `summand1` and `summand2`,
    /// computes the bitwise xor of `carryIn`, `summand1` and `summand2` in the
    /// qubit `summand2` and the carry-out is xored to the qubit `carryOut`.
    ///
    /// # Input
    /// ## carryIn
    /// Carry-in qubit.
    /// ## summand1
    /// First summand qubit.
    /// ## summand2
    /// Second summand qubit, is replaced with the lower bit of the sum of
    /// `summand1` and `summand2`.
    /// ## carryOut
    /// Carry-out qubit, will be xored with the higher bit of the sum.
    operation Carry (carryIn: Qubit, summand1: Qubit, summand2: Qubit, carryOut: Qubit) : Unit is Adj + Ctl {
        CCNOT (summand1, summand2, carryOut);
        CNOT (summand1, summand2);
        CCNOT (carryIn, summand2, carryOut);
    }

    /// # Summary
    /// Implements a reversible sum gate. Given a carry-in bit encoded in
    /// qubit `carryIn` and two summand bits encoded in `summand1` and `summand2`,
    /// computes the bitwise xor of `carryIn`, `summand1` and `summand2` in the qubit
    /// `summand2`.
    ///
    /// # Input
    /// ## carryIn
    /// Carry-in qubit.
    /// ## summand1
    /// First summand qubit.
    /// ## summand2
    /// Second summand qubit, is replaced with the lower bit of the sum of
    /// `summand1` and `summand2`.
    ///
    /// # Remarks
    /// In contrast to the `Carry` operation, this does not compute the carry-out bit.
    operation Sum (carryIn: Qubit, summand1: Qubit, summand2: Qubit) : Unit
    {
        body (...) {
            CNOT (summand1, summand2);
            CNOT (carryIn, summand2);
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Implements a cascade of CNOT gates on neighboring qubits in a given qubit
    /// register, starting from the qubit at position 0 as control to the qubit at 
    /// position 1 as the target, then from the qubit at position 1 as the control to
    /// the qubit at position 2 as the target, etc., ending with the qubit in position
    /// `Length(register)-1` as the target.
    ///
    /// # Input
    /// ## register
    /// Qubit register.
    operation CascadeCNOT (register : Qubit[]) : Unit
    {
        body (...) {
            let nQubits = Length(register);

            for ( idx in 0..(nQubits-2) ) {
                CNOT(register[idx], register[idx+1]);
            }
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Implements a cascade of CCNOT gates controlled on corresponding bits of two 
    /// qubit registers, acting on the next qubit of one of the registers.
    /// Starting from the qubits at position 0 in both registers as controls, CCNOT is
    /// applied to the qubit at position 1 of the target register, then controlled by
    /// the qubits at position 1 acting on the qubit at position 2 in the target register,
    /// etc., ending with an action on the target qubit in position `Length(nQubits)-1`.
    ///
    /// # Input
    /// ## register
    /// Qubit register, only used for controls.
    /// ## target
    /// Qubit register, used for controls and as target.
    ///
    /// # Remarks
    /// The target qubit register must have one qubit more than the other register.
    operation CascadeCCNOT (register : Qubit[], targets : Qubit[]) : Unit
    {
        body (...) {
            let nQubits = Length(targets);

            EqualityFactB(
                nQubits == Length(register)+1, true,
                "Target register must have one more qubit." );

            for ( idx in 0..(nQubits-2) ) {
                CCNOT(register[idx], targets[idx], targets[idx+1]);
            }
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }


    /// # Summary
    /// Reversible, in-place ripple-carry addition of two integers. 
    /// Given two $n$-bit integers encoded in LittleEndian registers `xs` and `ys`,
    /// and a qubit carry, the operation computes the sum of the two integers 
    /// where the $n$ least significant bits of the result are held in `ys` and 
    /// the carry out bit is xored to the qubit `carry`. 
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer summand.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer summand, is 
    /// modified to hold the $n$ least significant bits of the sum.
    /// ## carry
    /// Carry qubit, is xored with the most significant bit of the sum.
    ///
    /// # References
    /// - Thomas G. Draper: "Addition on a Quantum Computer", 2000.
    ///   https://arxiv.org/abs/quant-ph/0008033
    /// 
    /// # Remarks 
    /// The specified controlled operation makes use of symmetry and mutual 
    /// cancellation of operations to improve on the default implementation
    /// that adds a control to every operation.
    operation RippleCarryAdderD (xs : LittleEndian, ys : LittleEndian, carry : Qubit) : Unit
    {
        body (...) {
            (Controlled RippleCarryAdderD) (new Qubit[0], (xs, ys, carry));
        }
        adjoint auto;
        controlled ( controls, ... ) {
            let nQubits = Length(xs!);

            EqualityFactI(
                nQubits, Length(ys!),
                "Input registers must have the same number of qubits."
            );

            using (auxRegister = Qubit[nQubits]) {
                for (idx in 0..(nQubits-2)) {
                    Carry(auxRegister[idx], xs![idx], ys![idx], auxRegister[idx+1]);           // (1)
                }
                (Controlled Carry) (controls, (auxRegister[nQubits-1], xs![nQubits-1], ys![nQubits-1], carry));
                (Controlled CNOT) (controls, (xs![nQubits-1], ys![nQubits-1]));
                (Controlled Sum) (controls, (auxRegister[nQubits-1], xs![nQubits-1], ys![nQubits-1]));
                for (idx in (nQubits-2)..(-1)..0 ) {
                    (Adjoint Carry) (auxRegister[idx], xs![idx], ys![idx], auxRegister[idx+1]); // cancels with (1)
                    (Controlled Sum) (controls, (auxRegister[idx], xs![idx], ys![idx]));
                }
            }
        }
        adjoint controlled auto;
    }
 
    /// # Summary
    /// Reversible, in-place ripple-carry operation that is used in the 
    /// integer addition operation RippleCarryAdderCDKM below. 
    /// Given two qubit registers `xs` and `ys` of the same length, the operation
    /// applies a ripple carry sequence of CNOT and CCNOT gates with qubits
    /// in `xs` and `ys` as the controls and qubits in `xs` as the targets. 
    ///
    /// # Input
    /// ## xs
    /// First qubit register, containing controls and targets.
    /// ## ys
    /// Second qubit register, contributing to the controls.
    /// ## ancilla
    /// The ancilla qubit used in RippleCarryAdderCDKM passed to this operation.
    ///
    /// # References
    /// - Steven A. Cuccaro, Thomas G. Draper, Samuel A. Kutin, David 
    ///   Petrie Moulton: "A new quantum ripple-carry addition circuit", 2004.
    ///   https://arxiv.org/abs/quant-ph/0410184v1
    operation _RippleCDKM (xs : LittleEndian, ys : LittleEndian, ancilla : Qubit) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactI(
                nQubits, Length(ys!),
                "Input registers must have the same number of qubits."
            );

            Fact(
                nQubits >= 3,
                "Need at least 3 qubits per register."
            );

            CNOT (xs![2], xs![1]);
            CCNOT (ancilla, ys![1], xs![1]);
            for ( idx in 2..(nQubits-2) ) {
                CNOT (xs![idx+1], xs![idx]);
                CCNOT (xs![idx-1], ys![idx], xs![idx]);
            }
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// The core operation in the RippleCarryAdderCDKM, used with the above 
    /// _RippleCDKM operation, i.e. conjugated with this operation to obtain 
    /// the inner operation of the RippleCarryAdderCDKM. This operation computes
    /// the carry out qubit and applies a sequence of NOT gates on part of the input `ys`.
    ///
    /// # Input
    /// ## xs
    /// First qubit register.
    /// ## ys
    /// Second qubit register.
    /// ## ancilla
    /// The ancilla qubit used in RippleCarryAdderCDKM passed to this operation.
    /// ## carry
    /// Carry out qubit in the RippleCarryAdderCDKM operation.
    ///
    /// # References
    /// - Steven A. Cuccaro, Thomas G. Draper, Samuel A. Kutin, David 
    ///   Petrie Moulton: "A new quantum ripple-carry addition circuit", 2004.
    ///   https://arxiv.org/abs/quant-ph/0410184v1
    operation _CarryOutCoreCDKM (xs : LittleEndian, ys : LittleEndian,
                                 ancilla : Qubit, carry : Qubit) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            CNOT (xs![nQubits-1], carry);
            CCNOT (xs![nQubits-2], ys![nQubits-1], carry);
            ApplyToEachCA (X, Most(Rest(ys!)));   // X on ys[1..(nQubits-2)]
            CNOT (ancilla, ys![1]) ;
            ApplyToEachCA(CNOT, Zip(Rest(Most(xs!)), Rest(Rest(ys!))));
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Outer operation in the RippleCarryAdderCDKM for use with _InnerCDKM in ApplyWithCA to 
    /// construct RippleCarryAdderCDKM. 
    ///
    /// # Input
    /// ## xs
    /// First qubit register.
    /// ## ys
    /// Second qubit register.
    /// ## ancilla
    /// The ancilla qubit used in RippleCarryAdderCDKM.
    ///
    /// # References
    /// - Steven A. Cuccaro, Thomas G. Draper, Samuel A. Kutin, David 
    ///   Petrie Moulton: "A new quantum ripple-carry addition circuit", 2004.
    ///   https://arxiv.org/abs/quant-ph/0410184v1
    operation _OuterCDKM (xs : LittleEndian, ys : LittleEndian, ancilla : Qubit) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            ApplyToEachCA(CNOT, Zip(Rest(xs!), Rest(ys!)));
            CNOT (xs![1], ancilla);
            CCNOT (xs![0], ys![0], ancilla);
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Inner operation in the RippleCarryAdderCDKM for use with _OuterCDKM in ApplyWithCA to 
    /// construct RippleCarryAdderCDKM. 
    ///
    /// # Input
    /// ## xs
    /// First qubit register.
    /// ## ys
    /// Second qubit register.
    /// ## carry
    /// Carry out qubit used in RippleCarryAdderCDKM.
    /// ## ancilla
    /// The ancilla qubit used in RippleCarryAdderCDKM.
    ///
    /// # References
    /// - Steven A. Cuccaro, Thomas G. Draper, Samuel A. Kutin, David 
    ///   Petrie Moulton: "A new quantum ripple-carry addition circuit", 2004.
    ///   https://arxiv.org/abs/quant-ph/0410184v1
    operation _InnerCDKM (xs : LittleEndian, ys : LittleEndian, carry : Qubit,
                          ancilla : Qubit) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            ApplyWithCA(_RippleCDKM,
                   _CarryOutCoreCDKM(_, _, _, carry), (xs, ys, ancilla));
            ApplyToEachCA (X, Most(Rest(ys!)));   // X on ys[1..(nQubits-2)]
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Reversible, in-place ripple-carry addition of two integers. 
    /// Given two $n$-bit integers encoded in LittleEndian registers `xs` and `ys`,
    /// and a qubit carry, the operation computes the sum of the two integers 
    /// where the $n$ least significant bits of the result are held in `ys` and 
    /// the carry out bit is xored to the qubit `carry`. 
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer summand.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer summand, is 
    /// modified to hold the n least significant bits of the sum.
    /// ## carry
    /// Carry qubit, is xored with the most significant bit of the sum.
    ///
    /// # References
    /// - Steven A. Cuccaro, Thomas G. Draper, Samuel A. Kutin, David 
    ///   Petrie Moulton: "A new quantum ripple-carry addition circuit", 2004.
    ///   https://arxiv.org/abs/quant-ph/0410184v1
    ///
    /// # Remarks 
    /// This operation has the same functionality as RippleCarryAdderD, but 
    /// only uses one ancilla qubit instead of $n$.
    operation RippleCarryAdderCDKM (xs : LittleEndian, ys : LittleEndian, carry : Qubit) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            using ( ancilla = Qubit() ) {
                ApplyWithCA(_OuterCDKM, _InnerCDKM(_, _, carry, _), (xs, ys, ancilla));
                CNOT (xs![0], ys![0]);
            }
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Implements the inner addition function for the operation 
    /// RippleCarryAdderTTK. This is the inner operation that is conjugated
    /// with the outer operation to construct the full adder.
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer summand 
    /// input to RippleCarryAdderTTK.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer summand 
    /// input to RippleCarryAdderTTK.
    /// ## carry
    /// Carry qubit, is xored with the most significant bit of the sum.
    ///
    /// # References
    /// - Yasuhiro Takahashi, Seiichiro Tani, Noboru Kunihiro: "Quantum 
    ///   Addition Circuits and Unbounded Fan-Out", Quantum Information and
    ///   Computation, Vol. 10, 2010.
    ///   https://arxiv.org/abs/0910.2530 
    ///
    /// # Remarks
    /// The specified controlled operation makes use of symmetry and mutual 
    /// cancellation of operations to improve on the default implementation
    /// that adds a control to every operation.
    operation _InnerAddTTK (xs : LittleEndian, ys : LittleEndian, carry : Qubit) : Unit
    {
        body (...) {
            (Controlled _InnerAddTTK) (new Qubit[0], (xs, ys, carry));
        }
        adjoint auto;
        controlled ( controls, ... ) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            for( idx in 0..(nQubits-2) ) {
                CCNOT (xs![idx], ys![idx], xs![idx+1]);
            }
            (Controlled CCNOT) (controls, (xs![nQubits-1], ys![nQubits-1], carry));
            for( idx in (nQubits-1)..(-1)..1 ) {
                (Controlled CNOT) (controls, (xs![idx], ys![idx]));
                CCNOT (xs![idx-1], ys![idx-1], xs![idx]);
            }
        }
        adjoint controlled auto;
    }

    /// # Summary
    /// Implements the outer operation for RippleCarryAdderTTK to conjugate
    /// the inner operation to construct the full adder.
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer summand 
    /// input to RippleCarryAdderTTK.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer summand 
    /// input to RippleCarryAdderTTK.
    ///
    /// # References
    /// - Yasuhiro Takahashi, Seiichiro Tani, Noboru Kunihiro: "Quantum 
    ///   Addition Circuits and Unbounded Fan-Out", Quantum Information and
    ///   Computation, Vol. 10, 2010.
    ///   https://arxiv.org/abs/0910.2530 
    operation _OuterTTK (xs : LittleEndian, ys : LittleEndian) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            ApplyToEachCA(CNOT, Zip(Rest(xs!), Rest(ys!)));
            (Adjoint CascadeCNOT) (Rest(xs!));
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Reversible, in-place ripple-carry addition of two integers. 
    /// Given two $n$-bit integers encoded in LittleEndian registers `xs` and `ys`,
    /// and a qubit carry, the operation computes the sum of the two integers 
    /// where the $n$ least significant bits of the result are held in `ys` and 
    /// the carry out bit is xored to the qubit `carry`. 
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer summand.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer summand, is 
    /// modified to hold the $n$ least significant bits of the sum.
    /// ## carry
    /// Carry qubit, is xored with the most significant bit of the sum.
    ///
    /// # References
    /// - Yasuhiro Takahashi, Seiichiro Tani, Noboru Kunihiro: "Quantum 
    ///   Addition Circuits and Unbounded Fan-Out", Quantum Information and
    ///   Computation, Vol. 10, 2010.
    ///   https://arxiv.org/abs/0910.2530 
    ///
    /// # Remarks 
    /// This operation has the same functionality as RippleCarryAdderD and,
    /// RippleCarryAdderCDKM but does not use any ancilla qubits.
    operation RippleCarryAdderTTK (xs : LittleEndian, ys : LittleEndian, carry : Qubit) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            if (nQubits > 1) {
                CNOT(xs![nQubits-1], carry);
                ApplyWithCA(_OuterTTK, _InnerAddTTK(_, _, carry), (xs, ys));
            }
            else {
                CCNOT(xs![0], ys![0], carry);
            }
            CNOT(xs![0], ys![0]);
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Implements the inner addition function for the operation 
    /// RippleCarryAdderNoCarryTTK. This is the inner operation that is conjugated
    /// with the outer operation to construct the full adder.
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer summand 
    /// input to RippleCarryAdderNoCarryTTK.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer summand 
    /// input to RippleCarryAdderNoCarryTTK.
    ///
    /// # References
    /// - Yasuhiro Takahashi, Seiichiro Tani, Noboru Kunihiro: "Quantum 
    ///   Addition Circuits and Unbounded Fan-Out", Quantum Information and
    ///   Computation, Vol. 10, 2010.
    ///   https://arxiv.org/abs/0910.2530 
    ///
    /// # Remarks
    /// The specified controlled operation makes use of symmetry and mutual 
    /// cancellation of operations to improve on the default implementation
    /// that adds a control to every operation.
    operation _InnerAddNoCarryTTK (xs : LittleEndian, ys : LittleEndian) : Unit
    {
        body (...) {
            (Controlled _InnerAddNoCarryTTK) (new Qubit[0], (xs, ys));
        }
        adjoint auto;
        controlled ( controls, ... ) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            for( idx in 0..(nQubits-2) ) {
                CCNOT (xs![idx], ys![idx], xs![idx+1]);
            }
            for( idx in (nQubits-1)..(-1)..1 ) {
                (Controlled CNOT) (controls, (xs![idx], ys![idx]));
                CCNOT (xs![idx-1], ys![idx-1], xs![idx]);
            }
        }
        adjoint controlled auto;
    }

    /// # Summary
    /// Reversible, in-place ripple-carry addition of two integers without carry out. 
    /// Given two $n$-bit integers encoded in LittleEndian registers `xs` and `ys`,
    /// the operation computes the sum of the two integers modulo $2^n$,
    /// where $n$ is the bit size of the inputs `xs` and `ys`. It does not compute 
    /// the carry out bit. 
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer summand.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer summand, is 
    /// modified to hold the $n$ least significant bits of the sum.
    ///
    /// # References
    /// - Yasuhiro Takahashi, Seiichiro Tani, Noboru Kunihiro: "Quantum 
    ///   Addition Circuits and Unbounded Fan-Out", Quantum Information and
    ///   Computation, Vol. 10, 2010.
    ///   https://arxiv.org/abs/0910.2530 
    ///
    /// # Remarks 
    /// This operation has the same functionality as RippleCarryAdderTTK but does
    /// not return the carry bit.
    operation RippleCarryAdderNoCarryTTK (xs : LittleEndian, ys : LittleEndian) : Unit
    {
        body (...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            if (nQubits > 1) {
                ApplyWithCA(_OuterTTK, _InnerAddNoCarryTTK, (xs, ys));
            }
            CNOT (xs![0], ys![0]);
        }
        adjoint auto;
        controlled auto;
        adjoint controlled auto;
    }

    /// # Summary
    /// Carries out a strictly greater than comparison of two integers $x$ and $y$, encoded
    /// in qubit registers xs and ys. If $x > y$, then the result qubit will be flipped, 
    /// otherwise retain its state.
    ///
    /// # Input
    /// ## xs
    /// LittleEndian qubit register encoding the first integer $x$.
    /// ## ys
    /// LittleEndian qubit register encoding the second integer $y$.
    /// ## result
    /// Single qubit that will be flipped if $x > y$.
    /// 
    /// # References
    /// - Steven A. Cuccaro, Thomas G. Draper, Samuel A. Kutin, David 
    ///   Petrie Moulton: "A new quantum ripple-carry addition circuit", 2004.
    ///   https://arxiv.org/abs/quant-ph/0410184v1
    ///
    /// - Thomas Haener, Martin Roetteler, Krysta M. Svore: "Factoring using 2n+2 qubits
    ///     with Toffoli based modular multiplication", 2016
    ///     https://arxiv.org/abs/1611.07995
    ///
    /// # Remarks
    /// Uses the trick that $x-y = (x'+y)'$, where ' denotes the one's complement.
    operation GreaterThan (xs : LittleEndian, ys : LittleEndian, result : Qubit) : Unit
    {
        body (...) {
            (Controlled GreaterThan) (new Qubit[0], (xs, ys, result));
        }
        adjoint auto;
        controlled (controls, ...) {
            let nQubits = Length(xs!);

            EqualityFactB(
                nQubits == Length(ys!), true,
                "Input registers must have the same number of qubits." );

            if (nQubits == 1) {
                X(ys![0]);
                (Controlled CCNOT)(controls, (xs![0], ys![0], result));
                X(ys![0]);
            }
            else {
                ApplyToEachCA(X, ys!);
                ApplyToEachCA(CNOT, Zip(Rest(xs!),Rest(ys!)));
                (Adjoint CascadeCNOT) (Rest(xs!));
                CascadeCCNOT (Most(ys!), xs!);
                (Controlled CCNOT) (controls, (xs![nQubits-1], ys![nQubits-1], result));
                (Adjoint CascadeCCNOT) (Most(ys!), xs!);
                CascadeCNOT(Rest(xs!));
                (Controlled CNOT) (controls, (xs![nQubits-1], result));
                ApplyToEachCA(CNOT, Zip(Rest(xs!), Rest(ys!)));
                ApplyToEachCA(X, ys!);
            }
        }
        adjoint controlled auto;
    }

}
