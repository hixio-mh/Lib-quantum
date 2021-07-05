// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Warnings;

    /// # Deprecated
    /// This function has been removed.
    function AsQubitArray (arr : Qubit[]) : Qubit[] {
        // TODO: add call to _Removed.
        return arr;
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.resultarrayasint".
    function ResultAsInt (results : Result[]) : Int {
        _Renamed("Microsoft.Quantum.Canon.ResultAsInt", "Microsoft.Quantum.Convert.ResultArrayAsInt");
        return ResultArrayAsInt(results);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.resultasbool".
    function BoolFromResult (input : Result) : Bool {
        _Renamed("Microsoft.Quantum.Canon.BoolFromResult", "Microsoft.Quantum.Convert.ResultAsBool");
        return ResultAsBool(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.boolasresult".
    function ResultFromBool (input : Bool) : Result {
        _Renamed("Microsoft.Quantum.Canon.ResultFromBool", "Microsoft.Quantum.Convert.BoolAsResult");
        return BoolAsResult(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.intasboolarray".
    function BoolArrFromPositiveInt (number : Int, bits : Int) : Bool[] {
        _Renamed("Microsoft.Quantum.Canon.BoolArrFromPositiveInt", "Microsoft.Quantum.Convert.IntAsBoolArray");
        return IntAsBoolArray(number, bits);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.resultarrayasboolarray".
    function BoolArrFromResultArr(input : Result[]) : Bool[] {
        _Renamed("Microsoft.Quantum.Canon.BoolArrFromResultArr", "Microsoft.Quantum.Convert.ResultArrayAsBoolArray");
        return ResultArrayAsBoolArray(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.resultarrayasboolarray".
    function ResultArrFromBoolArr(input : Bool[]) : Result[] {
        _Renamed("Microsoft.Quantum.Canon.ResultArrFromBoolArr", "Microsoft.Quantum.Convert.BoolArrayAsResultArray");
        return BoolArrayAsResultArray(input);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.boolarrayasint".
    function PositiveIntFromBoolArr(bits : Bool[]) : Int {
        _Renamed("Microsoft.Quantum.Canon.PositiveIntFromBoolArr", "Microsoft.Quantum.Convert.BoolArrayAsInt");
        return BoolArrayAsInt(bits);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.canon.resultarrayasint".
    function PositiveIntFromResultArr(results : Result[]) : Int {
        _Renamed("Microsoft.Quantum.Canon.PositiveIntFromResultArr", "Microsoft.Quantum.Convert.ResultArrayAsInt");
        return ResultArrayAsInt(results);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.boolarrayaspauli".
    function PauliFromBitString(pauli : Pauli, bitApply : Bool, bits : Bool[]) : Pauli[] {
        _Renamed("Microsoft.Quantum.Canon.PauliFromBitString", "Microsoft.Quantum.Convert.BoolArrayAsPauli");
        return BoolArrayAsPauli(pauli, bitApply, bits);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.rangeasintarray".
    function IntArrayFromRange (range: Range) : Int[] {
        _Renamed("Microsoft.Quantum.Canon.IntArrayFromRange", "Microsoft.Quantum.Convert.RangeAsIntArray");
        return RangeAsIntArray(range);
    }

    /// # Deprecated
    /// Please use @"microsoft.quantum.convert.functionasoperation".
    function ToOperation<'Input, 'Output>(fn : ('Input -> 'Output)) : ('Input => 'Output) {
        _Renamed("Microsoft.Quantum.Canon.ToOperation", "Microsoft.Quantum.Convert.FunctionAsOperation");
        return FunctionAsOperation(fn);
    }

}
