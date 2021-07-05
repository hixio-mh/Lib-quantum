// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Combinators for constructing multiply controlled versions of operations
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// The signature type of CCNOT gate.
    newtype CCNOTop = (Apply : ((Qubit, Qubit, Qubit) => Unit is Adj));


    /// # Summary
    /// Applies a multiply controlled version of a singly controlled
    /// operation.
    /// The modifier `C` indicates that the single-qubit operation is controllable.
    ///
    /// # Input
    /// ## singlyControlledOp
    /// An operation controlled on a single qubit.
    /// The first qubit in the argument of the operation is
    /// assumed to be a control and the rest are assumed to be target qubits.
    /// `ApplyMultiControlled` always calls `singlyControlledOp` with an argument of
    /// length at least 1.
    /// ## ccnot
    /// The controlled-controlled-NOT gate to use for the construction.
    /// ## controls
    /// The qubits that `singlyControlledOp` is to be controlled on.
    /// The length of `controls` must be at least 1.
    /// ## targets
    /// The target qubits that `singlyControlledOp` acts upon.
    ///
    /// # Remarks
    /// This operation uses only clean ancilla qubits.
    ///
    /// For the explanation and circuit diagram see Figure 4.10, Section 4.3 in Nielsen & Chuang
    ///
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyMultiControlledCA
    operation ApplyMultiControlledC (singlyControlledOp : (Qubit[] => Unit), ccnot : CCNOTop, controls : Qubit[], targets : Qubit[]) : Unit
    {
        body (...)
        {
            EqualityFactB(Length(controls) >= 1, true, $"Length of controls must be at least 1");

            if (Length(controls) == 1)
            {
                singlyControlledOp(controls + targets);
            }
            else
            {
                using (ancillas = Qubit[Length(controls) - 1])
                {
                    AndLadder(ccnot, controls, ancillas);
                    singlyControlledOp([Tail(ancillas)] + targets);
                    Adjoint AndLadder(ccnot, controls, ancillas);
                }
            }
        }

        controlled (extraControls, ...)
        {
            ApplyMultiControlledC(singlyControlledOp, ccnot, extraControls + controls, targets);
        }
    }


    /// # Summary
    /// Applies a multiply controlled version of a singly controlled
    /// operation.
    /// The modifier `CA` indicates that the single-qubit operation is controllable
    /// and adjointable.
    ///
    /// # Input
    /// ## singlyControlledOp
    /// An operation controlled on a single qubit.
    /// The first qubit in the argument of the operation
    /// assumed to be a control and the rest are assumed to be target qubits.
    /// `ApplyMultiControlled` always calls `singlyControlledOp` with an argument of
    /// length at least 1.
    /// ## ccnot
    /// The controlled-controlled-NOT gate to use for the construction.
    /// ## controls
    /// The qubits that `singlyControlledOp` is to be controlled on.
    /// The length of `controls` must be at least 1.
    /// ## targets
    /// The target qubits that `singlyControlledOp` acts upon.
    ///
    /// # Remarks
    /// This operation uses only clean ancilla qubits.
    ///
    /// For the explanation and circuit diagram see Figure 4.10, Section 4.3 in Nielsen & Chuang
    ///
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.ApplyMultiControlledC
    operation ApplyMultiControlledCA (singlyControlledOp : (Qubit[] => Unit is Adj), ccnot : CCNOTop, controls : Qubit[], targets : Qubit[]) : Unit {
        body (...) {
            Fact(Length(controls) >= 1, $"Length of controls must be at least 1");

            if (Length(controls) == 1) {
                singlyControlledOp(controls + targets);
            } else {
                using (ladderRegister = Qubit[Length(controls) - 1]) {
                    AndLadder(ccnot, controls, ladderRegister);
                    singlyControlledOp([Tail(ladderRegister)] + targets);
                    Adjoint AndLadder(ccnot, controls, ladderRegister);
                }
            }
        }

        adjoint invert;

        controlled (extraControls, ...) {
            ApplyMultiControlledCA(singlyControlledOp, ccnot, extraControls + controls, targets);
        }

        controlled adjoint invert;
    }

    /// # Summary
    /// Performs a controlled "AND ladder" on a register of target qubits.
    ///
    /// # Description
    /// This operation applies a transformation described by the following
    /// mapping of the computational basis,
    /// $$
    /// \begin{align}
    ///     \ket{x\_1, \dots, x\_n} \ket{y\_1, \dots, y\_{n - 1}} \mapsto
    ///     \ket{x\_1, \dots, x\_n} \ket{
    ///         y\_1 \oplus (x\_1 \land x\_2), \dots, y\_{n - 1} \oplus (x\_1 \land x\_2 \land \cdots \land x\_{n - 1}
    ///     },
    /// \end{align}
    /// $$
    /// where $\ket{x\_1, \dots, x\_n}$ refers to the computational basis
    /// states of `controls`, and where $\ket{y\_1, \dots, y\_{n - 1}}$
    /// refers to the computational basis states of `targets`.
    ///
    /// # Input
    /// ## ccnot
    /// The CCNOT gate to use for the construction.
    /// ## controls
    /// A register of qubits to be used as controls for the and ladder.
    /// This operation leaves computational basis states of `controls`
    /// invariant.
    /// The length of `controls` must be at least 2, and must
    /// be equal to one plus the length of `targets`.
    /// ## targets
    /// The length of `targets` must be at least 1 and equal to the length
    /// of `controls` minus one.
    ///
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    ///
    /// # Remarks
    /// - Used as a part of <xref:microsoft.quantum.canon.applymulticontrolledc>
    ///   and <xref:microsoft.quantum.canon.applymulticontrolledca>.
    /// - For the explanation and circuit diagram see Figure 4.10, Section 4.3 in Nielsen & Chuang.
    operation AndLadder (ccnot : CCNOTop, controls : Qubit[], targets : Qubit[]) : Unit is Adj {
        EqualityFactI(Length(controls), Length(targets) + 1, $"Length(controls) must be equal to Length(target) + 1");
        Fact(Length(controls) >= 2, $"The operation is not defined for less than 2 controls");
        ccnot::Apply(controls[0], controls[1], targets[0]);

        for (k in 1 .. Length(targets) - 1) {
            ccnot::Apply(controls[k + 1], targets[k - 1], targets[k]);
        }
    }

}


