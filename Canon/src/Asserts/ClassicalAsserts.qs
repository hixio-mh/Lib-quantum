// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon
{
    
    /// # Summary
    /// Asserts that a classical floating point variable has the expected value up to a given
    /// absolute tolerance.
    ///
    /// # Input
    /// ## actual
    /// The number to be checked.
    ///
    /// ## expected
    /// The expected value.
    ///
    /// ## tolerance
    /// Absolute tolerance on the difference between actual and expected.
    function AssertAlmostEqualTol (actual : Double, expected : Double, tolerance : Double) : Unit
    {
        let delta = actual - expected;
        
        if (delta > tolerance || delta < -tolerance)
        {
            fail $"Assertion failed. Expected: '{expected}'. Actual: '{actual}'";
        }
    }
    
    
    /// # Summary
    /// Asserts that a classical floating point variable has the expected value up to a
    /// small tolerance of 1e-10.
    ///
    /// # Input
    /// ## actual
    /// The number to be checked.
    ///
    /// ## expected
    /// The expected value.
    ///
    /// # Remarks
    /// This is equivalent to <xref:microsoft.quantum.canon.assertalmostequaltol> with
    /// hardcoded tolerance=1e-10.
    function AssertAlmostEqual (actual : Double, expected : Double) : Unit
    {
        AssertAlmostEqualTol(actual, expected, 1E-10);
    }
    
    
    /// # Summary
    /// Asserts that a classical Int variable has the expected value.
    ///
    /// # Input
    /// ## actual
    /// The number to be checked.
    ///
    /// ## expected
    /// The expected value.
    ///
    /// ## message
    /// Failure message string to be used when the assertion is triggered.
    function AssertIntEqual (actual : Int, expected : Int, message : String) : Unit
    {
        if (actual != expected)
        {
            fail message;
        }
    }
    
    
    /// # Summary
    /// Asserts that a classical Bool variable has the expected value.
    ///
    /// # Input
    /// ## actual
    /// The variable to be checked.
    ///
    /// ## expected
    /// The expected value.
    ///
    /// ## message
    /// Failure message string to be used when the assertion is triggered.
    function AssertBoolEqual (actual : Bool, expected : Bool, message : String) : Unit
    {
        if (actual != expected)
        {
            fail message;
        }
    }
    
    
    /// # Summary
    /// Asserts that a classical Result variable has the expected value.
    ///
    /// # Input
    /// ## actual
    /// The variable to be checked.
    ///
    /// ## expected
    /// The expected value.
    ///
    /// ## message
    /// Failure message string to be used when the assertion is triggered.
    function AssertResultEqual (actual : Result, expected : Result, message : String) : Unit
    {
        if (actual != expected)
        {
            fail message;
        }
    }
    
    
    /// # Summary
    /// Asserts that two arrays of boolean values are equal.
    ///
    /// # Input
    /// ## actual
    /// The array that is produced by a test case of interest.
    /// ## expected
    /// The array that is expected from a test case of interest.
    /// ## message
    /// A message to be printed if the arrays are not equal.
    function AssertBoolArrayEqual (actual : Bool[], expected : Bool[], message : String) : Unit
    {
        let n = Length(actual);
        
        if (n != Length(expected))
        {
            fail message;
        }
        
        for (idx in 0 .. n - 1)
        {
            if (actual[idx] != expected[idx])
            {
                fail message;
            }
        }
    }
    
}


