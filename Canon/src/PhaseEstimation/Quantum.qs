// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon
{
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Testing;
    
    
    /// # Summary
    /// Performs the quantum phase estimation algorithm for a given oracle U and targetState,
    /// reading the phase into a big-endian quantum register.
    ///
    /// # Input
    /// ## oracle
    /// An operation implementing $U^m$ for given integer powers m.
    /// ## targetState
    /// A quantum register representing the state $\ket{\phi}$ acted on by $U$. If $\ket{\phi}$ is an
    /// eigenstate of $U$, $U\ket{\phi} = e^{i\phi} \ket{\phi}$ for $\phi \in [0, 2\pi)$ an unknown phase.
    /// ## controlRegister
    /// A big-endian representation integer register that can be used
    /// to control the provided oracle, and that will contain the a representation of $\phi$ following
    /// the application of this operation. The controlRegister is assumed to start in the initial
    /// state $\ket{00\cdots 0}$, where the length of the register indicates the desired precision.
    operation QuantumPhaseEstimation (oracle : DiscreteOracle, targetState : Qubit[], controlRegister : BigEndian) : Unit
    {
        body (...)
        {
            let nQubits = Length(controlRegister!);
            AssertAllZeroTol(controlRegister!, 1E-10);
            ApplyToEachCA(H, controlRegister!);
            
            for (idxControlQubit in 0 .. nQubits - 1)
            {
                let control = (controlRegister!)[idxControlQubit];
                let power = 2 ^ ((nQubits - idxControlQubit) - 1);
                Controlled oracle!([control], (power, targetState));
            }
            
            Adjoint QFT(controlRegister);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
}


