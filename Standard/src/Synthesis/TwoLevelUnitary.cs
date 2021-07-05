// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using System.Diagnostics;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Synthesis
{
    /// <summary>
    /// Represents a square matrix which is an identity matrix with elements on positions
    /// (i1, i1), (i1, i2), (i2, i1), (i2, i2) replaced with elements from unitary matrix <c>mx</c>. 
    /// </summary>
    internal class TwoLevelUnitary
    {
        private Complex[,] mx;   // 2x2 non-trivial principal submatrix.
        private int i1, i2;      // Indices of non-trivial submatrix.

        public TwoLevelUnitary(Complex[,] mx, int i1, int i2)
        {
            Debug.Assert(MatrixUtils.IsMatrixUnitary(mx), "Matrix is not unitary");
            this.mx = mx;
            this.i1 = i1;
            this.i2 = i2;
        }

        public void ApplyPermutation(int[] perm)
        {
            i1 = perm[i1];
            i2 = perm[i2];
        }

        // Ensures that index1 < index2.
        public void OrderIndices()
        {
            if (i1 > i2)
            {
                (i1, i2) = (i2, i1);
                (mx[0, 0], mx[1, 1]) = (mx[1, 1], mx[0, 0]);
                (mx[0, 1], mx[1, 0]) = (mx[1, 0], mx[0, 1]);
            }
        }

        // Equivalent to inversion (because matrix is unitary).
        public void ConjugateTranspose()
        {
            mx[0, 0] = Complex.Conjugate(mx[0, 0]);
            mx[1, 1] = Complex.Conjugate(mx[1, 1]);
            (mx[0, 1], mx[1, 0]) = (Complex.Conjugate(mx[1, 0]), Complex.Conjugate(mx[0, 1]));
        }

        // Applies A = A * M, where M is this matrix.
        public void MultiplyRight(Complex[,] A)
        {
            int n = A.GetLength(0);
            for (int i = 0; i < n; i++)
            {
                (A[i, i1], A[i, i2]) = (A[i, i1] * mx[0, 0] + A[i, i2] * mx[1, 0],
                                        A[i, i1] * mx[0, 1] + A[i, i2] * mx[1, 1]);
            }
        }

        public bool IsIdentity(double tol = 1e-10) =>
            (mx[0, 0] - 1).Magnitude < tol && mx[0, 1].Magnitude < tol &&
            mx[1, 0].Magnitude < tol && (mx[1, 1] - 1).Magnitude < tol;

        // Converts to a tuple to be passed to Q#.
        public (IQArray<IQArray<Quantum.Math.Complex>>, long, long) ToQsharp() =>
            (MatrixUtils.MatrixToQs(this.mx), this.i1, this.i2);
    }
}
