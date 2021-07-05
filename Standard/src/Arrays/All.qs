// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Arrays {

    function _And(left : Bool, right : Bool) : Bool {
        return left and right;
    }

    /// # Summary
    /// Given an array and a predicate that is defined
    /// for the elements of the array, and checks if all elements of the
    /// array satisfy the predicate.
    ///
    /// # Remarks
    /// The function is defined for generic types, i.e., whenever we have
    /// an array `'T[]` and a function `predicate: 'T -> Bool` we can produce
    /// a `Bool` value that indicates if all elements satisfy `predicate`.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type of `array` elements.
    ///
    /// # Input
    /// ## predicate
    /// A function from `'T` to `Bool` that is used to check elements.
    /// ## array
    /// An array of elements over `'T`.
    ///
    /// # Output
    /// A `Bool` value of the AND function of the predicate applied to all elements.
    function All<'T> (predicate : ('T -> Bool), array : 'T[]) : Bool {
       return Fold(_And, true, Mapped(predicate, array));
    }

}
