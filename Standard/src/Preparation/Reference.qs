// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Preparation {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;

    /// # Summary
	/// Pairwise entangles two qubit registers.
	///
    /// That is, given two registers, prepares the maximally entangled state
    /// $\frac{1}{\sqrt{2}} \left(\ket{00} + \ket{11} \right)$ between each pair of qubits on the respective registers,
    /// assuming that each register starts in the $\ket{0\cdots 0}$ state.
    ///
    /// # Input
    /// ## left
    /// A qubit array in the $\ket{0\cdots 0}$ state
    /// ## right
    /// A qubit array in the $\ket{0\cdots 0}$ state
    operation PrepareEntangledState (left : Qubit[], right : Qubit[]) : Unit is Adj + Ctl {
        if (Length(left) != Length(right)) {
            fail $"Left and right registers must be the same length.";
        }

        for ((leftQubit, rightQubit) in Zip(left, right)) {
            H(leftQubit);
            Controlled X([leftQubit], rightQubit);
        }
    }

    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation onto given reference
    /// and target registers.
    ///
    /// # Input
    /// ## op
    /// Operation $\Lambda$ whose Choi–Jamiłkowski state $J(\Lambda) / 2^N$
    /// is to be prepared, where $N$ is the number of qubits on which
    /// `op` acts.
    /// ## reference
    /// A register of qubits starting in the $\ket{00\cdots 0}$ state
    /// to be used as a reference for the action of `op`.
    /// ## target
    /// A register of qubits initially in the $\ket{00\cdots 0}$ state
    /// on which `op` is to be applied.
    ///
    /// # Remarks
    /// The Choi–Jamiłkowski state $J(\Lambda)$ of a quantum process is
    /// defined as
    /// $$
    /// \begin{align}
    ///     J(\Lambda) \mathrel{:=} (\boldone \otimes \Lambda)
    ///     (|\boldone\rangle\!\rangle\langle\!\langle\boldone|),
    /// \end{align}
    /// $$
    /// where $|X\rangle\!\rangle$ is the *vectorization* of a matrix $X$
    /// in the column-stacking convention. Learning a classical description
    /// of this state provides full information about the effect of $\Lambda$
    /// acting on arbitrary input states, and forms the foundation of
    /// *quantum process tomography*.
    ///
    /// # See Also
    /// - PrepareChoiStateA
    /// - PrepareChoiStateC
    /// - PrepareChoiStateCA
    operation PrepareChoiState (op : (Qubit[] => Unit), reference : Qubit[], target : Qubit[]) : Unit {
        PrepareEntangledState(reference, target);
        op(target);
    }


    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with a controlled variant onto given reference
    /// and target registers.
    ///
    /// # See Also
    /// - PrepareChoiState
    operation PrepareChoiStateC(op : (Qubit[] => Unit is Ctl), reference : Qubit[], target : Qubit[]) : Unit is Ctl {
        PrepareEntangledState(reference, target);
        op(target);
    }


    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with an adjoint variant onto given reference
    /// and target registers.
    ///
    /// # See Also
    /// - PrepareChoiState
    operation PrepareChoiStateA (op : (Qubit[] => Unit is Adj), reference : Qubit[], target : Qubit[]) : Unit is Adj {
        PrepareEntangledState(reference, target);
        op(target);
    }


    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with both controlled and adjoint variants onto given reference
    /// and target registers.
    ///
    /// # See Also
    /// - PrepareChoiState
    operation PrepareChoiStateCA(op : (Qubit[] => Unit is Adj + Ctl), reference : Qubit[], target : Qubit[]) : Unit is Adj + Ctl {
        PrepareEntangledState(reference, target);
        op(target);
    }

}
