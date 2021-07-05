// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon
{
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;
    
    
    /// # Summary
	/// Jointly measures a register of qubits in the Pauli Z basis.
	/// 
    /// In other words, measures the operation $Z \otimes Z \otimes \cdots \otimes Z$ on
    /// a given register.
    ///
    /// # Input
    /// ## register
    /// The register to be measured.
    ///
    /// # Output
    /// The result of measuring $Z \otimes Z \otimes \cdots \otimes Z$.
    operation MeasureAllZ (register : Qubit[]) : Result
    {
        let nQubits = Length(register);
        mutable allZMeasurement = new Pauli[nQubits];
        
        for (idxQubit in 0 .. nQubits - 1)
        {
            set allZMeasurement[idxQubit] = PauliZ;
        }
        
        return Measure(allZMeasurement, register);
    }
    
    
    /// # Summary
    /// Measures the identity operator on a register
    /// of qubits.
    ///
    /// # Input
    /// ## register
    /// The register to be measured.
    ///
    /// # Output
    /// The result value `Zero`.
    ///
    /// # Remarks
    /// Since $\boldone$ has only the eigenvalue $1$, and does not
    /// have a negative eigenvalue, this operation always returns
    /// `Zero`, corresponding to the eigenvalue $+1 = (-1)^0$,
    /// and does not cause a collapse of the state of `register`.
    ///
    /// On its own, this operation is not useful, but is helpful
    /// in the context of process tomography, as it provides
    /// information about the trace preservation of a quantum process.
    /// In particular, a target machine with lossy measurement should
    /// replace this operation by an actual measurement of $\boldone$.
    operation MeasureIdentity (register : Qubit[]) : Result
    {
        return Zero;
    }
    
    
    /// # Summary
	/// Prepares a qubit in the maximally mixed state.
	/// 
    /// It prepares the given qubit in the $\boldone / 2$ state by applying the depolarizing channel
    /// $$
    /// \begin{align}
    ///     \Omega(\rho) \mathrel{:=} \frac{1}{4} \sum_{\mu \in \{0, 1, 2, 3\}} \sigma\_{\mu} \rho \sigma\_{\mu}^{\dagger},
    /// \end{align}
    /// $$
    /// where $\sigma\_i$ is the $i$th Pauli operator, and where
    /// $\rho$ is a density operator representing a mixed state.
    ///
    /// # Input
    /// ## qubit
    /// A qubit whose state is to be depolarized in the manner
    /// described above.
    ///
    /// # Remarks
    /// The mixed state $\boldone / 2$ describing the result of
    /// applying this operation to a state implicitly describes
    /// an expectation value over random choices made in this operation.
    /// Thus, for any single application, this operation maps pure states
    /// to pure states, but it acts as described in expectation.
    /// In particular, this operation can be used in process tomography
    /// to measure the *non-unital* components of a channel.
    operation PrepareSingleQubitIdentity (qubit : Qubit) : Unit
    {
        ApplyPauli([RandomSingleQubitPauli()], [qubit]);
    }
    
    
    /// # Summary
    /// Given a register, prepares that register in the maximally mixed state.
	/// 
    /// The register is prepared in the $\boldone / 2^N$ state by applying the 
	/// complete depolarizing
    /// channel to each qubit, where $N$ is the length of the register.
    ///
    /// # Input
    /// ## register
    /// A register whose state is to be depolarized in the manner
    /// described above.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.preparesinglequbitidentity"
    operation PrepareIdentity (register : Qubit[]) : Unit
    {
        ApplyToEach(PrepareSingleQubitIdentity, register);
    }
    
    
    /// # Summary
    /// Given a preparation and measurement, estimates the frequency
    /// with which that measurement succeeds (returns `Zero`) by
    /// performing a given number of trials.
    ///
    /// # Input
    /// ## preparation
    /// An operation $P$ that prepares a given state $\rho$ on
    /// its input register.
    /// ## measurement
    /// An operation $M$ representing the measurement of interest.
    /// ## nQubits
    /// The number of qubits on which the preparation and measurement
    /// each act.
    /// ## nMeasurements
    /// The number of times that the measurement should be performed
    /// in order to estimate the frequency of interest.
    ///
    /// # Output
    /// An estimate $\hat{p}$ of the frequency with which
    /// $M(P(\ket{00 \cdots 0}\bra{00 \cdots 0}))$ returns `Zero`,
    /// obtained using the unbiased binomial estimator $\hat{p} =
    /// n\_{\uparrow} / n\_{\text{measurements}}$, where $n\_{\uparrow}$ is
    /// the number of `Zero` results observed.
    ///
    /// This is particularly important on target machines which respect
    /// physical limitations, such that probabilities cannot be measured.
    operation EstimateFrequency (preparation : (Qubit[] => Unit), measurement : (Qubit[] => Result), nQubits : Int, nMeasurements : Int) : Double
    {
        mutable nUp = 0;
        
        for (idxMeasurement in 0 .. nMeasurements - 1)
        {
            using (register = Qubit[nQubits])
            {
                preparation(register);
                let result = measurement(register);
                
                if (result == Zero)
                {
                    // NB!!!!! This reverses Zero and One to use conventions
                    //         common in the QCVV community. That is confusing
                    //         but is confusing with an actual purpose.
                    set nUp = nUp + 1;
                }
                
                // NB: We absolutely must reset here, since preparation()
                //     and measurement() can each use randomness internally.
                ApplyToEach(Reset, register);
            }
        }
        
        return ToDouble(nUp) / ToDouble(nMeasurements);
    }
    
    
    /// # Summary
	/// Prepares a qubit in the +1 (`Zero`) eigenstate of the given Pauli operator.
	/// If the identity operator is given, then the qubit is prepared in the maximally 
	/// mixed state.
	/// 
    /// If the qubit was initially in the $\ket{0}$ state, this operation prepares the
    /// qubit in the $+1$ eigenstate of a given Pauli operator, or, for `PauliI`,
    /// in the maximally mixed state instead (see <xref:microsoft.quantum.canon.preparesinglequbitidentity>).
    /// 
    /// If the qubit was in a state other than $\ket{0}$, this operation applies the following gates:
    /// $H$ for `PauliX`, $HS$ for `PauliY`, $I$ for `PauliZ` and 
    /// <xref:microsoft.quantum.canon.preparesinglequbitidentity> for `PauliI`.
    ///
    /// # Input
    /// ## basis
    /// A Pauli operator $P$.
    /// ## qubit
    /// A qubit to be prepared.
    operation PrepareQubit (basis : Pauli, qubit : Qubit) : Unit
    {
        if (basis == PauliI)
        {
            PrepareSingleQubitIdentity(qubit);
        }
        elif (basis == PauliX)
        {
            H(qubit);
        }
        elif (basis == PauliY)
        {
            H(qubit);
            S(qubit);
        }
    }
    
    
    /// # Summary
	/// Pairwise entangles two qubit registers.
	/// 
    /// That is, given two registers, prepares the maximally entangled state
    /// $\bra{\beta_{00}}\ket{\beta_{00}}$ between each pair of qubits on the respective registers,
    /// assuming that each register starts in the $\ket{0\cdots 0}$ state.
    ///
    /// # Input
    /// ## left
    /// A qubit array in the $\ket{0\cdots 0}$ state
    /// ## right
    /// A qubit array in the $\ket{0\cdots 0}$ state
    operation PrepareEntangledState (left : Qubit[], right : Qubit[]) : Unit
    {
        body (...)
        {
            if (Length(left) != Length(right))
            {
                fail $"Left and right registers must be the same length.";
            }
            
            for (idxQubit in 0 .. Length(left) - 1)
            {
                H(left[idxQubit]);
                Controlled X([left[idxQubit]], right[idxQubit]);
            }
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
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
    /// - @"microsoft.quantum.canon.preparechoistatec"
    /// - @"microsoft.quantum.canon.preparechoistatea"
    /// - @"microsoft.quantum.canon.preparechoistateca"
    operation PrepareChoiState (op : (Qubit[] => Unit), reference : Qubit[], target : Qubit[]) : Unit
    {
        PrepareEntangledState(reference, target);
        op(target);
    }
    
    
    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with a controlled variant onto given reference
    /// and target registers.
    /// # See Also
    /// - @"microsoft.quantum.canon.preparechoistate"
    operation PrepareChoiStateC (op : (Qubit[] => Unit : Controlled), reference : Qubit[], target : Qubit[]) : Unit
    {
        body (...)
        {
            PrepareEntangledState(reference, target);
            op(target);
        }
        
        controlled distribute;
    }
    
    
    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with an adjoint variant onto given reference
    /// and target registers.
    /// # See Also
    /// - @"microsoft.quantum.canon.preparechoistate"
    operation PrepareChoiStateA (op : (Qubit[] => Unit : Adjoint), reference : Qubit[], target : Qubit[]) : Unit
    {
        body (...)
        {
            PrepareEntangledState(reference, target);
            op(target);
        }
        
        adjoint invert;
    }
    
    
    /// # Summary
    /// Prepares the Choi–Jamiłkowski state for a given operation with both controlled and adjoint variants onto given reference
    /// and target registers.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.preparechoistate"
    operation PrepareChoiStateCA (op : (Qubit[] => Unit : Controlled, Adjoint), reference : Qubit[], target : Qubit[]) : Unit
    {
        body (...)
        {
            PrepareEntangledState(reference, target);
            op(target);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
    
    /// # Summary
    /// Performs a single-qubit process tomography measurement in the Pauli
    /// basis, given a particular channel of interest.
    ///
    /// # Input
    /// ## preparation
    /// The Pauli basis element $P$ in which a qubit is to be prepared.
    /// ## measurement
    /// The Pauli basis element $Q$ in which a qubit is to be measured.
    /// ## channel
    /// A single qubit channel $\Lambda$ whose behavior is being estimated
    /// with process tomography.
    ///
    /// # Output
    /// The Result `Zero` with probability
    /// $$
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \Lambda; P, Q) = \operatorname{Tr}\left(
    ///         \frac{\boldone + Q}{2} \Lambda\left[
    ///             \frac{\boldone + P}{2}
    ///         \right]
    ///     \right).
    /// \end{align}
    /// $$
    ///
    /// # Remarks
    /// The distribution over results returned by this operation is a special
    /// case of two-qubit state tomography. Let $\rho = J(\Lambda) / 2$ be
    /// the Choi–Jamiłkowski state for $\Lambda$. Then, the distribution above
    /// is identical to
    /// $$
    /// \begin{align}
    ///     \Pr(\texttt{Zero} | \rho; M) = \operatorname{Tr}(M \rho),
    /// \end{align}
    /// $$
    /// where $M = 2 (\boldone + P)^\mathrm{T} / 2 \cdot (\boldone + Q) / 2$
    /// is the effective measurement corresponding to $P$ and $Q$.
    operation SingleQubitProcessTomographyMeasurement (preparation : Pauli, measurement : Pauli, channel : (Qubit => Unit)) : Result
    {
        mutable result = Zero;
        
        using (register = Qubit[1])
        {
            let qubit = register[0];
            PrepareQubit(preparation, qubit);
            channel(qubit);
            set result = Measure([measurement], [qubit]);
            Reset(qubit);
        }
        
        return result;
    }
    
}


