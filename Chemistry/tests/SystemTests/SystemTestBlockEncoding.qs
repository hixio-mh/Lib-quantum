// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace SystemTestsBlockEncoding {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Chemistry.JordanWigner;   
    
    //////////////////////////////////////////////////////////////////////////
    // Using BlockEncoding ///////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    
    /// # Summary
    /// This allocates qubits and applies a block-encoding step.
    operation BlockEncodingStep (nSpinOrbitals : Int, data : JWOptimizedHTerms) : Unit {
        
        let generatorSystem = JordanWignerBlockEncodingGeneratorSystem(data);
        let (l1Norm, blockEncodingReflection) = PauliBlockEncoding(generatorSystem);
        let (nTerms, genIdxFunction) = generatorSystem!;
        let systemQubits = nSpinOrbitals;
        let auxillaryQubits = Ceiling(Lg(ToDouble(nTerms)));
        let nQubits = systemQubits + auxillaryQubits;
        
        using (qubits = Qubit[nQubits]) {
            blockEncodingReflection!!(qubits[systemQubits .. Length(qubits) - 1], qubits[0 .. systemQubits - 1]);
            ResetAll(qubits);
        }
    }
    
}


