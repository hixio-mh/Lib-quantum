// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Math {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    
    
    // DESIGN NOTES:
    //     Q# functions *CANNOT* have side effects. Since random sampling is a side
    //     effect, this immediately implies that any random number generation is modeled
    //     as an operation. That in turn implies that random number generation calls inside
    //     another operation will break adjointability and controllability.
    
    /// # Summary
    /// Generates a random integer uniformly sampled from all integers that can be represented
	/// in a given number of bits.
    ///
    /// # Input
    /// ## maxBits
    /// The number of classical bits required to represent the largest integer
    /// that could be returned by this operation.
    ///
    /// # Output
    /// An integer $x$ uniformly at random from $[0,2^{\texttt{maxBits}}-1]$;
    /// that is, with $\Pr(x) = \frac{1}{2^{\texttt{maxBits}}}$.
    ///
    /// # Remarks
    /// This function calls <xref:microsoft.quantum.intrinsic.random>, so
    /// its randomness depends on the implementation of `Random`.
    operation RandomIntPow2 (maxBits : Int) : Int {
        mutable number = 0;
        
        for (idxBit in 0 .. maxBits - 1) {
            let bit = Random([0.5, 0.5]);
            set number = number + bit * 2 ^ idxBit;
        }
        
        return number;
    }
    
    
    /// # Summary
    /// Generates a uniformly sampled random integer greater than or equal to zero
	/// and less than a provided upper bound.
    ///
    /// # Input
    /// ## maxInt
    /// An integer one larger than the largest integer to be
    /// returned by this operation.
    ///
    /// # Output
    /// An integer $x$ uniformly at random from the given interval;
    /// that is, with $\Pr(x) = \frac{1}{\texttt{maxInt}}$.
    ///
    /// # Remarks
    /// This operation uses postselection of an integer drawn from
    /// a uniform distribution whose maximum is a power of two,
    /// and thus may not make a constant number of calls to the
    /// underlying source of random classical bits.
    ///
    /// # Remarks
    /// This function calls <xref:microsoft.quantum.intrinsic.random>, so
    /// its randomness depends on the implementation of `Random`.
    operation RandomInt (maxInt : Int) : Int
    {
        mutable nBits = 0;
        mutable output = 0;
        set nBits = Ceiling(Lg(IntAsDouble(maxInt)));
        
        repeat
        {
            set output = RandomIntPow2(nBits);
        }
        until (output < maxInt)
        fixup
        {
        }
        
        return output;
    }
    
    
    /// # Summary
    /// Returns a random real number in the interval greater than or equal to zero 
	/// and less than one.
    ///
    /// # Input
    /// ## bitsRandom
    /// The number of bits of precision with which the random number
    /// should be sampled.
    ///
    ///	# Output
    /// A real number $x = k / 2^{\texttt{bitsRandom}}$ for an integer
    /// $k$ sampled from the interval $[0, 2^{\texttt{bitsRandom}})$
    /// with probability $\Pr(k) = 1 / 2^{\texttt{bitsRandom}}$.
    ///
    /// # Remarks
    /// This function calls <xref:microsoft.quantum.intrinsic.random>, so
    /// its randomness depends on the implementation of `Random`.
    operation RandomReal (bitsRandom : Int) : Double
    {
        if (bitsRandom < 1)
        {
            fail $"Number of random bits must be greater than 0.";
        }
        
        return IntAsDouble(RandomIntPow2(bitsRandom)) / PowD(2.0, IntAsDouble(bitsRandom));
    }

    /// # Summary
    /// Returns one of the single-qubit Pauli operators uniformly
    /// at random.
    ///
    /// # Output
    /// A `Pauli` operator that is one of `[PauliI, PauliX, PauliY, PauliZ]`.
    ///
    /// # Remarks
    /// This function calls <xref:microsoft.quantum.intrinsic.random>, so
    /// its randomness depends on the implementation of `Random`.
    operation RandomSingleQubitPauli () : Pauli {
        let probs = [0.5, 0.5, 0.5, 0.5];
        let idxPauli = Random(probs);
        let singleQubitPaulis = [PauliI, PauliX, PauliY, PauliZ];
        return singleQubitPaulis[idxPauli];
    }

}


