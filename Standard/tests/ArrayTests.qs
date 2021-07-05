// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Math;

    @Test("QuantumSimulator")
    function TestZipped() : Unit {

        let left = [1, 2, 101];
        let right = [PauliY, PauliI];
        let zipped = Zipped(left, right);
        let (leftActual1, rightActual1) = zipped[0];

        if (leftActual1 != 1 or rightActual1 != PauliY) {
            fail $"Expected (1, PauliY), got ({leftActual1}, {rightActual1}).";
        }

        let (leftActual2, rightActual2) = zipped[1];

        if (leftActual2 != 2 or rightActual2 != PauliI) {
            fail $"Expected (2, PauliI), got ({leftActual2}, {rightActual2}).";
        }
    }

    @Test("QuantumSimulator")
    function UnzippedTest() : Unit {
        let first = [6, 5, 5, 3, 2, 1];
        let second = [true, false, false, false, true, false];

        let (first2, second2) = Unzipped(Zipped(first, second));
        AllEqualityFactI(first2, first, "Unexpected array of integers");
        AllEqualityFactB(second2, second, "Unexpected array of Booleans");
    }


    @Test("QuantumSimulator")
    function TestLookup() : Unit {

        let array = [1, 12, 71, 103];
        let fn = LookupFunction(array);
        EqualityFactI(fn(0), 1, $"fn(0) did not return array[0]");

        // Make sure we can call in random order!
        EqualityFactI(fn(3), 103, $"fn(3) did not return array[3]");
        EqualityFactI(fn(2), 71, $"fn(2) did not return array[2]");
        EqualityFactI(fn(1), 12, $"fn(1) did not return array[1]");
    }

    internal function AllEqualI(expected : Int[], actual : Int[]) : Bool {
        return All(EqualI, Zipped(expected, actual));
    }

    @Test("QuantumSimulator")
    function TestChunks() : Unit {
        let data = [10, 11, 12, 13, 14, 15];

        // 2 × 3 case.
        Fact(All(AllEqualI, Zipped(
            [[10, 11], [12, 13], [14, 15]],
            Chunks(2, data)
        )), "Wrong chunks in 2x3 case.");

        // Case with some leftovers.
        Fact(All(AllEqualI, Zipped(
            [[10, 11, 12, 13], [14, 15]],
            Chunks(4, data)
        )), "Wrong chunks in case with leftover elements.");
    }

    internal function Squared(x : Int) : Int {
        return x * x;
    }

    @Test("QuantumSimulator")
    function ConstantArrayOfDoublesIsCorrect() : Unit {
        let dblArray = ConstantArray(71, 2.17);
        EqualityFactI(Length(dblArray), 71, $"ConstantArray(Int, Double) had the wrong length.");
        let ignore = Mapped(NearEqualityFactD(_, 2.17), dblArray);
    }

    @Test("QuantumSimulator")
    function ConstantArrayOfFunctionsIsCorrect() : Unit {
        // Stress test by making an array of Int -> Int.
        let fnArray = ConstantArray(7, Squared);
        EqualityFactI(Length(fnArray), 7, $"ConstantArray(Int, Int -> Int) had the wrong length.");
        EqualityFactI(fnArray[3](7), 49, $"ConstantArray(Int, Int -> Int) had the wrong value.");
    }

    @Test("QuantumSimulator")
    function SubarrayIsCorrect () : Unit {
        let array0 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let subarrayOdd = Subarray([1, 3, 5, 7, 9], array0);
        let subarrayEven = Subarray([0, 2, 4, 6, 8, 10], array0);
        Fact(All(IsEven, subarrayEven), $"the even elements of [1..10] were not correctly sliced.");
        Fact(not Any(IsEven, subarrayOdd), $"the odd elements of [1..10] were not correctly sliced.");
        let array1 = [10, 11, 12, 13];
        Ignore(Mapped(EqualityFactI(_, _, $"Subarray failed: subpermutation case."), Zipped([12, 11], Subarray([2, 1], array1))));
    }

    @Test("QuantumSimulator")
    function FilteredIsEvenHasNoOdds() : Unit {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let evenArray = Filtered(IsEven, array);
        Fact(All(IsEven, evenArray), $"the even elements of [1..10] were not correctly filtered.");
    }

    @Test("QuantumSimulator")
    function CountOfIsEvenIsCorrect() : Unit {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        let countEvens = Count(IsEven, array);
        EqualityFactI(countEvens, 5, $"the even elements of [1..10] were not correctly counted.");
    }

    @Test("QuantumSimulator")
    function ReversedIsCorrect() : Unit {
        let array = [1, 2, 3];
        Ignore(Mapped(EqualityFactI(_, _, $"Reversed failed."), Zipped([3, 2, 1], Reversed(array))));
    }

    @Test("QuantumSimulator")
    function ExcludingIsCorrect() : Unit {
        let array = [10, 11, 12, 13, 14, 15];
        Ignore(Mapped(EqualityFactI(_, _, $"Excluding failed."), Zipped([10, 11, 13, 14], Excluding([2, 5], array))));
    }

    @Test("QuantumSimulator")
    function PaddedIsCorrect() : Unit {

        mutable arrayTestCase = [(-5, 2, [10, 11, 12], [10, 11, 12, 2, 2]), (5, 2, [10, 11, 12], [2, 2, 10, 11, 12]), (-3, -2, [10, 11, 12], [10, 11, 12])];

        for (idxTest in IndexRange(arrayTestCase)) {
            let (nElementsTotal, defaultElement, inputArray, outputArray) = arrayTestCase[idxTest];
            let paddedArray = Padded(nElementsTotal, defaultElement, inputArray);
            Ignore(Mapped(EqualityFactI(_, _, $"Padded failed."), Zipped(outputArray, paddedArray)));
        }
    }

    @Test("QuantumSimulator")
    function EnumeratedIsCorrect() : Unit  {
        let example = [37, 12];
        let expected = [(0, 37), (1, 12)];
        let actual = Enumerated(example);

        for ((actualElement, expectedElement) in Zipped(actual, expected)) {
            EqualityFactI(Fst(actualElement), Fst(expectedElement), "Indices did not match.");
            EqualityFactI(Snd(actualElement), Snd(expectedElement), "Elements did not match.");
        }
    }

    @Test("QuantumSimulator")
    function SequenceIIsCorrect() : Unit {
        let example = [(0, 3), (23, 29), (-5, -2)];
        let expected = [[0, 1, 2, 3], [23, 24, 25, 26, 27, 28, 29], [-5, -4, -3, -2]];
        let actual = Mapped(SequenceI, example);

        for ((exp, act) in Zipped(expected, actual)) {
            EqualityFactI(Length(exp), Length(act), "Lengths of arrays did not match.");
            for ((i, j) in Zipped(exp, act)) {
                EqualityFactI(i, j, "Elements did not match.");
            }
        }
    }

    @Test("QuantumSimulator")
    function SequenceLIsCorrect() : Unit {
        let example = [(0L, 3L), (23L, 29L), (-5L, -2L)];
        let expected = [[0L, 1L, 2L, 3L], [23L, 24L, 25L, 26L, 27L, 28L, 29L], [-5L, -4L, -3L, -2L]];
        let actual = Mapped(SequenceL, example);

        for ((exp, act) in Zipped(expected, actual)) {
            EqualityFactI(Length(exp), Length(act), "Lengths of arrays did not match.");
            for ((i, j) in Zipped(exp, act)) {
                EqualityFactL(i, j, "Elements did not match.");
            }
        }
    }
    @Test("QuantumSimulator")
    function SequenceForNumbersIsCorrect() : Unit {
        let example = [3, 5, 0];
        let expected = [[0, 1, 2, 3], [0, 1, 2, 3, 4, 5], [0]];
        let actual = Mapped(SequenceI(0, _), example);

        for ((exp, act) in Zipped(expected, actual)) {
            EqualityFactI(Length(exp), Length(act), "Lengths of arrays did not match.");
            for ((i, j) in Zipped(exp, act)) {
                EqualityFactI(i, j, "Elements did not match.");
            }
        }
    }

    @Test("QuantumSimulator")
    function IsEmptyIsCorrect() : Unit {
        Fact(IsEmpty(new Int[0]), "Empty array marked as non-empty.");
        Fact(IsEmpty(new Qubit[0]), "Empty array marked as non-empty.");
        Fact(IsEmpty(new (Double, (Int -> String))[0]), "Empty array marked as non-empty.");
        Fact(not IsEmpty([PauliX, PauliZ]), "Non-empty array marked as empty.");
        Fact(not IsEmpty([""]), "Non-empty array marked as empty.");
    }

    @Test("QuantumSimulator")
    function SwapOrderToPermuteArrayIsCorrect() : Unit {
        let newOrder = [0, 4, 2, 1, 3];
        let expected = [(1, 4), (1, 3)];
        let actual = _SwapOrderToPermuteArray(newOrder);

        EqualityFactI(Length(expected), Length(actual), "Number of swaps does not match");
        for ((exp, act) in Zipped(expected, actual)) {
            let (leftExp, rightExp) = exp;
            let (leftAct, rightAct) = act;

            EqualityFactI(leftExp, leftAct, "SWAP doesn't match");
            EqualityFactI(rightExp, rightAct, "SWAP doesn't match");
        }
    }

    @Test("QuantumSimulator")
    function SwappedIsCorrect() : Unit {
        let example = [2, 4, 6, 8, 10];
        let expected = [2, 8, 6, 4, 10];
        let leftIndex = 1;
        let rightIndex = 3;
        let newArray = Swapped(leftIndex, rightIndex, example);

        EqualityFactI(Length(expected), Length(newArray), "Swapped array is a different size than original");
        for ((exp, act) in Zipped(expected, newArray)) {
            EqualityFactI(exp, act, "Elements did not match");
        }
    }

    @Test("QuantumSimulator")
    function TupleArrayAsNestedArrayIsCorrect() : Unit {
        let example = [(0, 1), (2, 3), (4, 5), (6, 7)];
        let expected = [[0, 1], [2, 3], [4, 5], [6, 7]];

        let actual = TupleArrayAsNestedArray(example);
        EqualityFactI(Length(expected), Length(actual), "Arrays are of different sizes");
        for ((exp, act) in Zipped(expected, actual)) {
            for ((elementExp, elementAct) in Zipped(exp, act)) {
                EqualityFactI(elementExp, elementAct, "Elements did not match");
            }
        }
    }

    @Test("QuantumSimulator")
    function EqualAIsCorrect() : Unit {
        // arrays of integers
        let equalArrays = EqualA(EqualI, [2, 3, 4], [2, 3, 4]);
        Fact(equalArrays, "Equal arrays were not reported as equal");

        // arrays of doubles
        let differentLength = EqualA(EqualD, [2.0, 3.0, 4.0], [2.0, 3.0]);
        Fact(not differentLength, "Arrays of different length were reported as equal");

        // arrays of Results
        let differentElements = EqualA(EqualR, [One, Zero], [One, One]);
        Fact(not differentElements, "Arrays with different elements were reported as equal");
    }

    @Test("QuantumSimulator")
    operation TestInterleaved() : Unit {
        AllEqualityFactI(Interleaved([1, 2, 3], [-1, -2, -3]), [1, -1, 2, -2, 3, -3], "Interleaving failed");
        AllEqualityFactB(Interleaved(ConstantArray(3, false), ConstantArray(2, true)), [false, true, false, true, false], "Interleaving failed");
    }

    @Test("QuantumSimulator")
    operation TestCumulativeFolded() : Unit {
        AllEqualityFactI(CumulativeFolded(PlusI, 0, SequenceI(1, 5)), [1, 3, 6, 10, 15], "CumulativeFolded failed");
    }

    @Test("QuantumSimulator")
    operation TestTransposed() : Unit {
        for ((actual, expected) in Zipped(Transposed([[1, 2, 3], [4, 5, 6]]), [[1, 4], [2, 5], [3, 6]])) {
            AllEqualityFactI(actual, expected, "Transposed failed");
        }
    }

    @Test("QuantumSimulator")
    operation TestColumnAt() : Unit {
        let matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];
        AllEqualityFactI(ColumnAt(0, matrix), [1, 4, 7], "ColumnAt failed");
        AllEqualityFactI(ColumnAt(1, matrix), [2, 5, 8], "ColumnAt failed");
        AllEqualityFactI(ColumnAt(2, matrix), [3, 6, 9], "ColumnAt failed");
    }

    @Test("QuantumSimulator")
    operation TestElementAt() : Unit {
        let lucas = [2, 1, 3, 4, 7, 11, 18, 29, 47, 76];
        let prime = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29];
        let fibonacci = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34];
        let catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862];
        let famous2 = Mapped(ElementAt<Int>(2, _), [lucas, prime, fibonacci, catalan]);
        AllEqualityFactI(famous2, [3, 5, 1, 2], "ElementAt failed");
    }

    @Test("QuantumSimulator")
    operation TestElementsAt() : Unit {
        let lucas = [2, 1, 3, 4, 7, 11, 18, 29, 47, 76];
        let prime = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29];
        let fibonacci = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34];
        let catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862];
        let famousOdd = Mapped(ElementsAt<Int>(0..2..9, _), [lucas, prime, fibonacci, catalan]);
        for ((actual, expected) in Zipped(famousOdd, [[2, 3, 7, 18, 47], [2, 5, 11, 17, 23], [0, 1, 3, 8, 21], [1, 2, 14, 132, 1430]])) {
            AllEqualityFactI(actual, expected, "ElementsAt failed");
        }
    }

    @Test("QuantumSimulator")
    operation TestDiagonal() : Unit {
        AllEqualityFactI(Diagonal([[1, 2, 3], [4, 5, 6], [7, 8, 9]]), [1, 5, 9], "Diagonal failed");
        AllEqualityFactI(Diagonal([[1, 2, 3], [4, 5, 6]]), [1, 5], "Diagonal failed");
        AllEqualityFactI(Diagonal([[1, 2], [4, 5], [7, 8]]), [1, 5], "Diagonal failed");
    }

    @Test("QuantumSimulator")
    operation TestWindows() : Unit {
        let EqualIntA = EqualA<Int>(EqualI, _, _);
        let EqualIntAA = EqualA<Int[]>(EqualIntA, _, _);

        Fact(EqualIntAA(Windows(-1, [1, 2, 3]), new Int[][0]), "unexpected windows");
        Fact(EqualIntAA(Windows(0, [1, 2, 3]), new Int[][0]), "unexpected windows");
        Fact(EqualIntAA(Windows(1, [1, 2, 3]), [[1], [2], [3]]), "unexpected windows");
        Fact(EqualIntAA(Windows(2, [1, 2, 3]), [[1, 2], [2, 3]]), "unexpected windows");
        Fact(EqualIntAA(Windows(3, [1, 2, 3]), [[1, 2, 3]]), "unexpected windows");
        Fact(EqualIntAA(Windows(4, [1, 2, 3]), new Int[][0]), "unexpected windows");
    }

    @Test("QuantumSimulator")
    operation TestPrefixes() : Unit {
        let array = [0, 1, 1, 2, 3, 5];
        let prefixes = Prefixes(array);

        EqualityFactI(Length(prefixes), Length(array), "unexpected length for prefixes");
        AllEqualityFactI(prefixes[0], [0], "unexpected prefix");
        AllEqualityFactI(prefixes[1], [0, 1], "unexpected prefix");
        AllEqualityFactI(prefixes[2], [0, 1, 1], "unexpected prefix");
        AllEqualityFactI(prefixes[3], [0, 1, 1, 2], "unexpected prefix");
        AllEqualityFactI(prefixes[4], [0, 1, 1, 2, 3], "unexpected prefix");
        AllEqualityFactI(prefixes[5], [0, 1, 1, 2, 3, 5], "unexpected prefix");
    }

    @Test("QuantumSimulator")
    operation TestSuccessfulRectangularFact() : Unit {
        RectangularArrayFact([[1, 2], [3, 4]], "Array is not rectangular");
        RectangularArrayFact([[1, 2, 3], [4, 5, 6]], "Array is not rectangular");
    }

    operation RectangularFactTestShouldFail() : Unit {
        RectangularArrayFact([[1, 2], [3, 4, 5]], "Array is not rectangular");
    }

    @Test("QuantumSimulator")
    operation TestSuccessfulSquareFact() : Unit {
        SquareArrayFact([[1, 2], [3, 4]], "Array is not a square");
    }

    operation SquareFact1TestShouldFail() : Unit {
        SquareArrayFact([[1, 2, 3], [4, 5, 6]], "Array is not a square");
    }

    operation SquareFact2TestShouldFail() : Unit {
        SquareArrayFact([[1, 2], [3, 4, 5]], "Array is not a square");
    }
}
