// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {

    operation _OperationPow<'T> (op : ('T => Unit), power : Int, target : 'T)
    : Unit {
        for (idxApplication in 0 .. power - 1) {
            op(target);
        }
    }


    operation _OperationPowC<'T> (op : ('T => Unit is Ctl), power : Int, target : 'T)
    : Unit is Ctl {
        for (idxApplication in 0 .. power - 1) {
            op(target);
        }
    }


    operation _OperationPowA<'T> (op : ('T => Unit is Adj), power : Int, target : 'T)
    : Unit is Adj {
        for (idxApplication in 0 .. power - 1) {
            op(target);
        }
    }


    operation _OperationPowCA<'T> (op : ('T => Unit is Adj + Ctl), power : Int, target : 'T)
    : Unit is Adj + Ctl {
        for (idxApplication in 0 .. power - 1) {
            op(target);
        }
    }


    /// # Summary
    /// Raises an operation to a power.
    ///
    /// That is, given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    ///
    /// # Input
    /// ## op
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the operation to be powered.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpowc"
    /// - @"microsoft.quantum.canon.operationpowa"
    /// - @"microsoft.quantum.canon.operationpowca"
    function OperationPow<'T> (op : ('T => Unit), power : Int) : ('T => Unit) {
        return _OperationPow(op, power, _);
    }


    /// # Summary
    /// Raises an operation to a power.
    /// The modifier `C` indicates that the operation is controllable.
    ///
    /// That is, given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    ///
    /// # Input
    /// ## op
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the operation to be powered.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowC<'T> (op : ('T => Unit is Ctl), power : Int) : ('T => Unit is Ctl) {
        return _OperationPowC(op, power, _);
    }


    /// # Summary
    /// Raises an operation to a power.
    /// The modifier `A` indicates that the operation is adjointable.
    ///
    /// That is, given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    ///
    /// # Input
    /// ## op
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the operation to be powered.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowA<'T> (op : ('T => Unit is Adj), power : Int) : ('T => Unit is Adj) {
        return _OperationPowA(op, power, _);
    }


    /// # Summary
    /// Raises an operation to a power.
    /// The modifier `A` indicates that the operation is controllable and adjointable.
    ///
    /// That is, given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    ///
    /// # Input
    /// ## op
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of the operation to be powered.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowCA<'T> (op : ('T => Unit is Ctl + Adj), power : Int) : ('T => Unit is Ctl + Adj) {
        return _OperationPowCA(op, power, _);
    }

}
