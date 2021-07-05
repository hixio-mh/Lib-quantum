// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon
{
    
    /// # Summary
    /// Converts a `Result` type to a `Bool` type, where `One` is mapped to
    /// `true` and `Zero` is mapped to `false`.
    ///
    /// # Input
    /// ## input
    /// `Result` to be converted.
    ///
    /// # Output
    /// A `Bool` representing the `input`.
    function BoolFromResult (input : Result) : Bool
    {
        if (input == Zero)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    
    /// # Summary
    /// Converts a `Bool` type to a `Result` type, where `true` is mapped to
    /// `One` and `false` is mapped to `Zero`.
    ///
    /// # Input
    /// ## input
    /// `Bool` to be converted.
    ///
    /// # Output
    /// A `Result` representing the `input`.
    function ResultFromBool (input : Bool) : Result
    {
        if (input == false)
        {
            return Zero;
        }
        else
        {
            return One;
        }
    }
    
    
    /// # Summary
    /// Converts a `Result[]` type to a `Bool[]` type, where `One` is mapped to
    /// `true` and `Zero` is mapped to `false`.
    ///
    /// # Input
    /// ## input
    /// `Result[]` to be converted.
    ///
    /// # Output
    /// A `Bool[]` representing the `input`.
    function BoolArrFromResultArr (input : Result[]) : Bool[]
    {
        let nInput = Length(input);
        mutable output = new Bool[nInput];
        
        for (idx in 0 .. nInput - 1)
        {
            set output[idx] = BoolFromResult(input[idx]);
        }
        
        return output;
    }
    
    
    /// # Summary
    /// Converts a `Bool[]` type to a `Result[]` type, where `true` is mapped to
    /// `One` and `false` is mapped to `Zero`.
    ///
    /// # Input
    /// ## input
    /// `Bool[]` to be converted.
    ///
    /// # Output
    /// A `Result[]` representing the `input`.
    function ResultArrFromBoolArr (input : Bool[]) : Result[]
    {
        let nInput = Length(input);
        mutable output = new Result[nInput];
        
        for (idx in 0 .. nInput - 1)
        {
            set output[idx] = ResultFromBool(input[idx]);
        }
        
        return output;
    }
    
    
    /// # Summary
    /// Produces binary representation of positive integer in little Endian format.
    ///
    /// # Input
    /// ## number
    /// Positive integer.
    /// ## bits
    /// Bits in binary representation of number.
    ///
    /// # Remarks
    /// The input `number` must be at most 2^bits -1.
    function BoolArrFromPositiveInt (number : Int, bits : Int) : Bool[]
    {
        AssertBoolEqual(number >= 0 && number < 2 ^ bits, true, $"`number` must be between 0 and 2^`bits` - 1");
        mutable outputBits = new Bool[bits];
        mutable tempInt = number;
        
        for (idxBit in 0 .. bits - 1)
        {
            if (tempInt % 2 == 0)
            {
                set outputBits[idxBit] = false;
            }
            else
            {
                set outputBits[idxBit] = true;
            }
            
            set tempInt = tempInt / 2;
        }
        
        return outputBits;
    }
    
    
    /// # Summary
    /// Produces a positive integer from a string of bits in little endian format.
    ///
    /// # Input
    /// ## bits
    /// Bits in binary representation of number.
    function PositiveIntFromBoolArr (bits : Bool[]) : Int
    {
        AssertBoolEqual(Length(bits) < 64, true, $"`Length(bits)` must be less than 64");
        mutable number = 0;
        let nBits = Length(bits);
        
        for (idxBit in 0 .. nBits - 1)
        {
            if (bits[idxBit])
            {
                set number = number + 2 ^ idxBit;
            }
        }
        
        return number;
    }
    
    
    /// # Summary
    /// Produces a positive integer from a string of Results in little endian format.
    ///
    /// # Input
    /// ## results
    /// Results in binary representation of number.
    function PositiveIntFromResultArr (results : Result[]) : Int
    {
        return PositiveIntFromBoolArr(BoolArrFromResultArr(results));
    }
    
    
    /// # Summary
    /// Used to cast UDTs that are derived from type `Qubit[]` down to `Qubit[]`.
    /// Handy when used with generic functions like Head and Tail.
    function AsQubitArray (arr : Qubit[]) : Qubit[]
    {
        return arr;
    }
    
    /// # Summary
    /// Calls a function with a given input.
    ///
    /// # Description
    /// Given a function and an input to that function, calls the function
    /// and returns its output.
    ///
    /// # Input
    /// ## fn
    /// A function to be called.
    /// ## input
    /// The input to be passed to the function.
    ///
    /// # Output
    /// The result of calling `fn`.
    ///
    /// # Remarks
    /// This operation is mainly useful for forcing a function to be called
    /// at a specific place within an operation, or for calling a function
    /// where an operation is expected.
    operation Call<'Input, 'Output>(fn : ('Input -> 'Output), input : 'Input) : 'Output {
        return fn(input);
    }

    /// # Summary
    /// Converts functions to operations.
    ///
    /// # Description
    /// Given a function, returns an operation which calls that function,
    /// and which does nothing else.
    ///
    /// # Input
    /// ## fn
    /// A function to be converted to an operation.
    ///
    /// # Output
    /// An operation `op` such that `op(input)` is identical to `fn(input)`
    /// for all `input`.
    ///
    /// # Type Parameters
    /// ## 'Input
    /// Input type of the function to be converted.
    /// ## 'Output
    /// Output type of the function to be converted.
    ///
    /// # Remarks
    /// This is mainly useful for passing functions to functions or operations
    /// which expect an operation as input.
    function ToOperation<'Input, 'Output>(fn : ('Input -> 'Output)) : ('Input => 'Output) {
        return Call(fn, _);
    }
    
}


