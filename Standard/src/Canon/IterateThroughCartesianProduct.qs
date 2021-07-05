// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Arrays;
    
    /// # Summary
    /// Iterates a variable, say `arr`, through a Cartesian product
    /// [ 0, bounds[0]-1 ] × [ 0, bounds[1]-1 ] × [ 0, bounds[Length(bounds)-1]-1 ]
    /// and calls op(arr) for every element of the Cartesian product
    operation IterateThroughCartesianProduct (bounds : Int[], op : (Int[] => Unit)) : Unit
    {
        mutable arr = new Int[Length(bounds)];
        mutable finished = false;
        
        repeat
        {
            if (not finished)
            {
                op(arr);
            }
        }
        until (finished)
        fixup
        {
            //computes the next element in the Cartesian product
            set arr w/= 0 <- arr[0] + 1;
            
            for (i in 0 .. Length(arr) - 2)
            {
                if (arr[i] == bounds[i])
                {
                    set arr w/= i + 1 <- arr[i + 1] + 1;
                    set arr w/= i <- 0;
                }
            }
            
            if (arr[Length(arr) - 1] == bounds[Length(arr) - 1])
            {
                set finished = true;
            }
        }
    }
    
    
    /// # Summary
    /// Iterates a variable, say arr, through Cartesian product
    /// [ 0, bound - 1 ] × [ 0, bound - 1 ] × [ 0, bound - 1 ]
    /// and calls op(arr) for every element of the Cartesian product
    operation IterateThroughCartesianPower (power : Int, bound : Int, op : (Int[] => Unit)) : Unit {
        IterateThroughCartesianProduct(ConstantArray(power, bound), op);
    }
    
}


