// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    
    /// # Summary
    /// Checks that @"microsoft.quantum.canon.randomint" obeys ranges.
    operation RandomIntRangeTest () : Unit {
        
        let randomInt = RandomInt(45);
        
        if (randomInt > 45 || randomInt < 0) {
            fail $"RandomInt returned an integer outside the allowed range.";
        }
    }
    
    
    /// # Summary
    /// Checks that @"microsoft.quantum.canon.randomintpow2" obeys ranges.
    operation RandomIntPow2RangeTest () : Unit {
        
        let randIntPow2 = RandomIntPow2(7);
        
        if (randIntPow2 > 127 || randIntPow2 < 0) {
            fail $"RandomIntPow2 returned an integer outside the allowed range.";
        }
    }
    
}


