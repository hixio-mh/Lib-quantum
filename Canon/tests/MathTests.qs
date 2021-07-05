// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Canon {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;
    
    
    function NativeFnsAreCallableTest () : Unit {
        
        let arg = PI() / 2.0;
        AssertAlmostEqual(Sin(arg), 1.0);
        AssertAlmostEqual(Cos(arg), 0.0);
        let arcArg = 1.0;
        AssertAlmostEqual(ArcCos(arcArg), 0.0);
        AssertAlmostEqual(ArcSin(arcArg), arg);
    }
    
    
    function RealModTest () : Unit {
        
        AssertAlmostEqual(RealMod(5.5 * PI(), 2.0 * PI(), 0.0), 1.5 * PI());
        AssertAlmostEqual(RealMod(0.5 * PI(), 2.0 * PI(), -PI() / 2.0), 0.5 * PI());
    }
    
    
    function ArcHyperbolicFnsTest () : Unit {
        
        // These tests were generated using NumPy's implementations
        // of the inverse hyperbolic functions.
        AssertAlmostEqual(ArcTanh(0.3), 0.30951960420311175);
        AssertAlmostEqual(ArcCosh(1.3), 0.75643291085695963);
        AssertAlmostEqual(ArcSinh(-0.7), -0.65266656608235574);
    }
    
    
    function ExtendedGCDTestHelper (a : Int, b : Int, gcd : Int) : Unit {
        
        Message($"Testing {a}, {b}, {gcd} ");
        let (u, v) = ExtendedGCD(a, b);
        let expected = AbsI(gcd);
        let actual = AbsI(u * a + v * b);
        AssertIntEqual(expected, actual, $"Expected absolute value of gcd to be {expected}, got {actual}");
    }
    
    
    function ExtendedGCDTest () : Unit {
        
        let testTuples = [(1, 1, 1), (1, -1, 1), (-1, 1, 1), (-1, -1, 1), (5, 7, 1), (-5, 7, 1), (3, 15, 3)];
        Ignore(Map(ExtendedGCDTestHelper, testTuples));
    }
    
    
    function BitSizeTest () : Unit {
        
        AssertIntEqual(BitSize(3), 2, $"BitSize(3) must be 2");
        AssertIntEqual(BitSize(7), 3, $"BitSize(7) must be 2");
    }
    
    
    function ExpModTest () : Unit {
        
        // this test is generated using Mathematica PowerMod function
        let result = ExpMod(5, 4611686018427387903, 7);
        AssertIntEqual(result, 6, $"The result must be 6, got {result}");
    }
    
    
    function ContinuedFractionConvergentTestHelper (numerator : Int, denominator : Int) : Unit {
        
        let bitSize = 2 * BitSize(denominator);
        let numeratorDyadic = (numerator * 2 ^ bitSize) / denominator;
        let (u, v) = (ContinuedFractionConvergent(Fraction(numeratorDyadic, 2 ^ bitSize), denominator))!;
        AssertBoolEqual(AbsI(u) == numerator && AbsI(v) == denominator, true, $"The result must be ±{numerator}/±{denominator} got {u}/{v}");
    }
    
    
    function ContinuedFractionConvergentEdgeCaseTestHelper (numerator : Int, denominator : Int, bound : Int) : Unit {
        
        let (num, denom) = (ContinuedFractionConvergent(Fraction(numerator, denominator), bound))!;
        AssertBoolEqual(AbsI(num) == numerator && AbsI(denom) == denominator, true, $"The result must be ±{numerator}/±{denominator} got {num}/{denom}");
    }
    
    
    function ContinuedFractionConvergentTest () : Unit {
        
        let testTuples = [(29, 47), (17, 37), (15, 67)];
        Ignore(Map(ContinuedFractionConvergentTestHelper, testTuples));
        let edgeCaseTestTuples = [(1, 4, 512), (3, 4, 512)];
        Ignore(Map(ContinuedFractionConvergentEdgeCaseTestHelper, edgeCaseTestTuples));
    }
    
    
    function ComplexMathTest () : Unit {
        
        mutable complexCases = [(0.123, 0.321), (0.123, -0.321), (-0.123, 0.321), (-0.123, -0.321)];
        
        for (idxCases in 0 .. Length(complexCases) - 1) {
            let (complexRe, complexIm) = complexCases[idxCases];
            let complexAbs = Sqrt(complexRe * complexRe + complexIm * complexIm);
            let complexArg = ArcTan2(complexIm, complexRe);
            let complex = Complex(complexRe, complexIm);
            let complexPolar = ComplexPolar(complexAbs, complexArg);
            AssertAlmostEqual(AbsSquaredComplex(complex), complexAbs * complexAbs);
            AssertAlmostEqual(AbsComplex(complex), complexAbs);
            AssertAlmostEqual(ArgComplex(complex), complexArg);
            AssertAlmostEqual(AbsSquaredComplexPolar(complexPolar), complexAbs * complexAbs);
            AssertAlmostEqual(AbsComplexPolar(complexPolar), complexAbs);
            AssertAlmostEqual(ArgComplexPolar(complexPolar), complexArg);
            let (x, y) = (ComplexPolarToComplex(complexPolar))!;
            AssertAlmostEqual(x, complexRe);
            AssertAlmostEqual(y, complexIm);
            let (r, t) = (ComplexToComplexPolar(complex))!;
            AssertAlmostEqual(r, complexAbs);
            AssertAlmostEqual(t, complexArg);
        }
    }
    
    
    function PNormTest () : Unit {
        
        mutable testCases = [
            (1.0, [-0.1, 0.2, 0.3], 0.6), 
            (1.5, [0.1, -0.2, 0.3], 0.43346228721136096815),
            (2.0, [0.1, 0.2, -0.3], 0.37416573867739413856),
            (3.0, [0.0, 0.0, -0.0], 0.0)
        ];
        
        for (idxTest in 0 .. Length(testCases) - 1) {
            let (p, array, pNormExpected) = testCases[idxTest];
            AssertAlmostEqual(PNorm(p, array), pNormExpected);
            
            // if PNorm fails, PNormalize will fail.
            let arrayNormalized = PNormalize(p, array);
            
            for (idxCoeff in 0 .. Length(array) - 1) {
                AssertAlmostEqual(array[idxCoeff] / pNormExpected, arrayNormalized[idxCoeff]);
            }
        }
    }
    
}


